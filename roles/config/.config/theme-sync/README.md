# theme-sync

Edit `themes/<name>.json`: one source of truth per theme for managed app colors
and native theme mappings. Shared app templates live in `templates/<app>/`.
The executable is `~/dotfiles/scripts/theme/theme-sync.sh` (or `theme-sync` after
linking `bin`). Rendering requires Python 3.9+; no Python packages are needed.

## Commands

```bash
theme-sync                         # interactive menu
theme-sync list
theme-sync current
theme-sync set tokyonight-night
theme-sync apply                   # regenerate after editing the current theme
theme-sync mode-set light <theme>
theme-sync mode-set dark <theme>
theme-sync auto                     # macOS system appearance
theme-sync auto --watch 5
```

`THEME_SYNC_ROOT` overrides the definitions/templates root.
`THEME_SYNC_LIGHT_THEME` and `THEME_SYNC_DARK_THEME` override saved mode choices.

## Editing and adding themes

Each JSON definition has three sections:

- `palette`: named hex colors, or aliases such as `"surface": "@background"`.
- `mappings`: native Neovim/Bat theme names and an optional VS Code suggestion.
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

Change a palette color once, then run `theme-sync apply`. All bindings that
reference that color update together. App-specific differences are explicit:
RWTH's Ghostty and Kitty ANSI color 8, for example, intentionally differ.
Existing GitHub monochrome FZF/btop overrides are retained rather than silently
recolored. Remove an optional entry from `files` to stop generating that overlay.

To add a theme, copy an existing JSON definition to `themes/<new-name>.json`,
change its palette/mappings, then run `./install.sh links config` from the repo
root to link the new definition, followed by `theme-sync set <new-name>`. No
registry needs updating. Reuse an existing template variant unless the app layout or
settings actually differ. Templates contain app syntax, not theme color literals.

Neovim and built-in Bat syntax themes remain native mappings; their full
highlight rules belong to their upstream plugins/themes. SupaTheme's custom
Bat, terminal, prompt, lazygit and OpenCode files are generated from
`themes/SupaTheme.json`. Its upstream submodule is left unchanged and is not
used as the renderer's color source. `scripts/theme/generate-supatheme.sh` is now a
compatibility shortcut for `theme-sync set SupaTheme`.

Personal themes using the old `themes/<name>/theme.env` layout still work.
A JSON definition takes precedence when both layouts exist.

## Local state and generated output

`$XDG_STATE_HOME/theme-sync/` (default `~/.local/state/theme-sync/`) contains:

- `current`: active theme name
- `current.env`: shell exports for Bat, FZF, Starship, and lazygit
- `mode.env`: preferred light/dark theme names
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
theme-sync apply                   # regenerate the current theme's app files
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
- `~/.config/opencode/theme.json` (optional)
- `~/.config/bat/themes/SupaTheme.tmTheme` (custom Bat theme; cache rebuilt)
- `~/.local/state/nvim/theme.txt`

Ghostty, Kitty, btop, tmux and FZF are generated for all 16 bundled themes.
Other overlays retain their existing theme coverage. Optional overlays are
removed when switching to a theme without them, or when removing them from a
definition. Kitty/tmux are refreshed when available; other apps may require a
reload or restart. Apps use their defaults until a theme is applied.

Config/state paths respect `XDG_CONFIG_HOME` and `XDG_STATE_HOME`. Stow itself
links application configs under `~/.config`. Generated output is not stowed or
tracked.

VS Code settings are never modified, including JSONC files with comments. Use
`window.autoDetectColorScheme`, `workbench.preferredLightColorTheme`, and
`workbench.preferredDarkColorTheme` instead. `VSCODE_THEME` mappings are retained
only as suggestions shown by `theme-sync current`.

## Checks

```bash
python3 tests/test_dotfiles.py       # from the repository root
```

The offline checks switch through all bundled themes in a temporary home,
verify shared palette edits and app overrides, reject invalid definitions
without changing the active theme, and check optional-overlay cleanup.
