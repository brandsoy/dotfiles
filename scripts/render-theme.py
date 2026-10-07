#!/usr/bin/env python3
"""Render theme-sync definitions. Python standard library only."""
import json
import os
from pathlib import Path
import re
import shlex
import sys
import tempfile

TOKEN = re.compile(r"\{\{([a-zA-Z0-9_]+)\}\}")
NAME = re.compile(r"[a-zA-Z0-9][a-zA-Z0-9_-]*")
OUTPUTS = {
    "ghostty": "GHOSTTY_THEME_FILE",
    "kitty.conf": "KITTY_INCLUDE",
    "fzf.sh": "FZF_THEME_FILE",
    "btop.theme": "BTOP_THEME",
    "lazygit.yml": "LAZYGIT_THEME_FILE",
    "starship.toml": "STARSHIP_CONFIG",
    "opencode.theme.json": "OPENCODE_THEME_FILE",
    "bat.tmTheme": "BAT_THEME_FILE",
    "tmux.theme.conf": None,
    "yazi.theme.toml": None,
    "eza.theme.yml": None,
}
MAPPINGS = {"GHOSTTY_THEME", "NVIM_THEME", "BAT_THEME", "BTOP_THEME", "VSCODE_THEME"}


def render(root, name, config_home):
    if not NAME.fullmatch(name):
        raise ValueError(f"Invalid theme name: {name!r}")
    definition = json.loads((root / "themes" / f"{name}.json").read_text())
    if not isinstance(definition, dict):
        raise ValueError("Theme definition must be an object")
    palette = definition["palette"]
    if not isinstance(palette, dict) or not isinstance(definition["files"], dict):
        raise ValueError("palette and files must be objects")

    def resolve(value, trail=()):
        if not isinstance(value, str) or "\n" in value or "\r" in value:
            raise ValueError("Theme values must be single-line strings")
        if value.startswith("@"):
            key = value[1:]
            if key in trail:
                raise ValueError(f"Cyclic palette reference: {key}")
            return resolve(palette[key], (*trail, key))
        return value

    colors = {key: resolve(value, (key,)) for key, value in palette.items()}
    for key, value in colors.items():
        if not re.fullmatch(r"#[0-9a-fA-F]{6}", value):
            raise ValueError(f"Invalid palette color {key}: {value!r}")
    mappings = definition["mappings"]
    if not isinstance(mappings, dict):
        raise ValueError("mappings must be an object")
    if set(mappings) - MAPPINGS:
        raise ValueError("Unknown application mapping")
    for key in ("GHOSTTY_THEME", "NVIM_THEME", "BAT_THEME"):
        if key not in mappings:
            raise ValueError(f"Missing mapping: {key}")
    env = {key: resolve(value).replace("{{config_home}}", str(config_home))
           for key, value in mappings.items()}
    outputs = {}
    templates = root / "templates"
    for filename, spec in definition["files"].items():
        if filename not in OUTPUTS:
            raise ValueError(f"Unknown output: {filename}")
        if not isinstance(spec, dict) or not isinstance(spec.get("values", {}), dict):
            raise ValueError(f"Output {filename} must contain a template and a values object")
        template_name = Path(spec["template"])
        if template_name.is_absolute() or ".." in template_name.parts:
            raise ValueError(f"Template outside templates directory: {template_name}")
        # Stow links individual files to the repository, outside this directory.
        # Reject path traversal, but allow those trusted template symlinks.
        template = templates / template_name
        values = {**colors, **{key: resolve(value) for key, value in spec.get("values", {}).items()}}
        outputs[filename] = TOKEN.sub(lambda match: values[match[1]], template.read_text())
        if "{{" in outputs[filename]:
            raise ValueError(f"Invalid template variable in {filename}")
    if "kitty.conf" not in outputs:
        raise ValueError("Theme must generate kitty.conf")
    return outputs, env


def generate(root, name, destination, config_home):
    # Validate/render everything before changing generated files or active configs.
    outputs, env = render(root, name, config_home)
    destination.mkdir(parents=True, exist_ok=True)
    for filename, variable in OUTPUTS.items():
        if filename in outputs and variable:
            env[variable] = str(destination / filename)
    # Preserve the custom Bat theme's display name and cache filename.
    if "bat.tmTheme" in outputs:
        bat_name = f"{name}.tmTheme"
        outputs[bat_name] = outputs.pop("bat.tmTheme")
        env["BAT_THEME_FILE"] = str(destination / bat_name)
    outputs["theme.env"] = "".join(f"{key}={shlex.quote(value)}\n" for key, value in env.items())
    with tempfile.TemporaryDirectory(prefix=".render-", dir=destination) as temporary:
        stage = Path(temporary)
        for filename, content in outputs.items():
            (stage / filename).write_text(content)
        for filename in outputs:
            os.replace(stage / filename, destination / filename)
    # Removed overlays must not survive a definition edit.
    for filename in OUTPUTS:
        if filename not in outputs:
            (destination / filename).unlink(missing_ok=True)


if __name__ == "__main__":
    try:
        if len(sys.argv) != 5:
            raise ValueError("Usage: render-theme.py <root> <theme> <destination> <config-home>")
        generate(Path(sys.argv[1]), sys.argv[2], Path(sys.argv[3]), Path(sys.argv[4]))
    except (OSError, ValueError, KeyError, TypeError) as error:
        sys.exit(f"error: Cannot render theme: {error}")
