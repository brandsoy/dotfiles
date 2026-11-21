# theme-switcher

Edit `themes/<name>.json`: one source of truth per theme for managed app colors
and native theme mappings. Shared app templates live in `templates/<app>/`.
The executable is `~/dotfiles/scripts/theme/theme-switcher.sh` (or `theme-switcher` after
linking `bin`). Rendering requires Python 3.9+; no Python packages are needed.

## Commands

```bash
theme-switcher                         # interactive menu
theme-switcher list
theme-switcher current
theme-switcher set tokyonight-night
theme-switcher set terminal-defaults   # remove the switcher's terminal palette
theme-switcher apply                   # regenerate after editing the current theme
theme-switcher apps terminal           # use the terminal's ANSI palette in apps
theme-switcher apps themed             # restore per-app themes
theme-switcher apps                    # show the saved app color setting
theme-switcher mode-set light <theme>
theme-switcher mode-set dark <theme>
theme-switcher auto                     # macOS system appearance
theme-switcher auto --watch 5
```

`THEME_SWITCHER_ROOT` overrides the definitions/templates root.
`THEME_SWITCHER_LIGHT_THEME` and `THEME_SWITCHER_DARK_THEME` override saved mode choices.

## App colors

Select **Terminal defaults** in the picker and press Enter to use the terminal's
default palette and ANSI colors in supported apps. This option stays active
until you select a named theme, even if automatic light/dark switching is enabled.

Press `a` in the interactive menu or run `theme-switcher apps terminal` to
use terminal colors with a named theme. Ghostty and Kitty get their palettes
from that theme. This app setting persists across theme switches, including automatic
light/dark changes. The default is `themed`.

Terminal mode uses ANSI colors for Neovim, Bat, FZF, Starship, lazygit and tmux,
and drops the custom Yazi and eza overlays. In the configured Zsh shell, btop uses
its 16-color TTY mode. Yazi can still use its own colors for icons and previews.
Open a new shell and restart affected apps after toggling.

## Editing and adding themes

Each JSON definition has three sections:

- `palette`: named hex colors, or aliases such as `"surface": "@background"`.
- `mappings`: native app theme names.
- `files`: generated outputs, their shared template, and per-app variable bindings.

For example, these bindings connect a Kitty template to the palette:

```json
"palette": {
  "background": "#00182d",
  "foreground": "#e8f1fa",
  "blue": "#8ebae5"
},
"files": {
  "kitty.conf": {
    "template": "kitty/rwth-dark.conf",
    "values": {
      "background": "@background",
      "foreground": "@foreground"
    }
  }
}
```

This is an excerpt, not a complete definition: the selected template requires
bindings for its other variables too. Templates use `{{variable}}` placeholders;
values can reference any palette color with `@name`. Palette names are also
available directly to templates. Shell/Starship `$variables` are left untouched.

Change a palette color once, then run `theme-switcher apply`. All bindings that
reference that color update together. App-specific differences are explicit:
RWTH's Ghostty and Kitty ANSI color 8, for example, intentionally differ.
Existing GitHub monochrome FZF/btop overrides are retained rather than silently
recolored. Remove an optional entry from `files` to stop generating that overlay.

To add a theme:

1. Copy an existing JSON definition to `themes/<new-name>.json`.
2. Change its palette and mappings.
3. From the repository root, run `./install.sh links config` to link the definition.
4. Run `theme-switcher set <new-name>`.

No registry needs updating. Reuse an existing template variant unless the app
layout or settings differ. Templates contain app syntax, not theme color literals.

Neovim and built-in Bat syntax themes remain native mappings; their full
highlight rules belong to their upstream plugins/themes. SupaTheme's custom
Bat, terminal, prompt and lazygit files are generated from
`themes/SupaTheme.json`. Its upstream submodule is left unchanged and is not
used as the renderer's color source. `scripts/theme/generate-supatheme.sh` is now a
compatibility shortcut for `theme-switcher set SupaTheme`.

Personal themes using the old `themes/<name>/theme.env` layout still work.
A JSON definition takes precedence when both layouts exist.

## Local state and generated output

`$XDG_STATE_HOME/theme-switcher/` (default `~/.local/state/theme-switcher/`) contains:

- `current`: active theme name
- `current.env`: shell exports for Bat, FZF, Starship, and lazygit
- `mode.env`: preferred light/dark theme names
- `apps`: preferred app color mode
- `generated/<name>/`: rendered assets and machine-local `theme.env`
- `lazygit.yml`: optional overlay, merged with the tracked lazygit config

Definitions and templates are never rewritten by theme switching. Rendering
validates all colors, aliases, bindings and template paths before writing files.
Each rendered file is replaced atomically; this is not a transaction across all
applications. A render validation failure leaves the active configs/state intact.

Legacy `current` and `mode.env` in the definitions directory are imported once.
Exports are regenerated using this machine's paths. After updating an existing
installation, run these commands from the repository root:

```bash
./install.sh links config           # link the new JSON definitions and templates
theme-switcher apply                   # regenerate the current theme's app files
```

Without relinking, obsolete file-level Stow links can leave only SupaTheme
visible. Open a new shell after switching to load the updated Bat, FZF, Starship
and lazygit exports.

Application preferences stay tracked. Theme-sync writes generated includes:

- `~/.config/ghostty/auto/theme.ghostty`
- `~/.config/kitty/auto/theme.conf`
- `~/.config/btop/themes/dotfiles.theme`
- `~/.config/tmux/theme.conf`
- `~/.config/yazi/theme.toml` (optional)
- `~/.config/eza/theme.yml` (optional)
- `~/.config/bat/themes/SupaTheme.tmTheme` (custom Bat theme; cache rebuilt)
- `~/.local/state/nvim/theme.txt`

Ghostty, Kitty, btop, tmux and FZF are generated for all bundled themes.
Optional overlays are removed when switching to a theme without them or when
removing them from a definition. The switcher refreshes Kitty and tmux when
available. Other apps may require a reload or restart.

Config/state paths respect `XDG_CONFIG_HOME` and `XDG_STATE_HOME`. Stow itself
links application configs under `~/.config`. Generated output is not stowed or
tracked.

## Checks

```bash
python3 tests/test_dotfiles.py       # from the repository root
```

The offline checks switch through all bundled themes in a temporary home,
verify shared palette edits and app overrides, reject invalid definitions
without changing the active theme, and check optional-overlay cleanup.
