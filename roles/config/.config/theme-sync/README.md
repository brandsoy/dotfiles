# theme-sync

Theme definitions live in `themes/<name>/`. The executable is
`~/dotfiles/scripts/theme-sync.sh` (or `theme-sync` after linking `bin`).

## Commands

```bash
theme-sync                         # interactive menu
theme-sync list
theme-sync current
theme-sync set tokyonight-night
theme-sync apply
theme-sync mode-set light <theme>
theme-sync mode-set dark <theme>
theme-sync auto                     # macOS system appearance
theme-sync auto --watch 5
```

`THEME_SYNC_ROOT` overrides the definitions directory. `THEME_SYNC_LIGHT_THEME`
and `THEME_SYNC_DARK_THEME` override the saved mode choices.

## Local state and generated output

`$XDG_STATE_HOME/theme-sync/` (default `~/.local/state/theme-sync/`) contains:

- `current`: active theme name
- `current.env`: shell exports for Bat, FZF, Starship, and lazygit
- `mode.env`: preferred light/dark theme names
- `lazygit.yml`: optional theme overlay, merged with the tracked lazygit config

Legacy `current` and `mode.env` in the definitions directory are imported once.
Exports are regenerated using this machine's paths. Open a new shell after
switching themes to load them.

Application preferences stay tracked. Theme-sync only writes generated files:

- `~/.config/ghostty/auto/theme.ghostty`
- `~/.config/alacritty/auto/theme.toml`
- `~/.config/kitty/auto/theme.conf`
- `~/.config/btop/themes/dotfiles.theme`
- `~/.config/yazi/theme.toml`
- `~/.config/eza/theme.yml`
- `~/.config/tmux/theme.conf`
- `~/.config/opencode/theme.json`
- `~/.local/state/nvim/theme.txt`

Config/state paths respect `XDG_CONFIG_HOME` and `XDG_STATE_HOME`. Stow itself
links application configs under `~/.config`. Generated output is not stowed or
tracked; optional overlays are removed when the next theme does not supply one.
Apps use their baseline/default colors until a theme is applied.

## Theme definitions

Each theme has a `theme.env` with app mappings. Optional generated overlays come
from `lazygit.yml`, `yazi.theme.toml`, `eza.theme.yml`, `tmux.theme.conf`, and
`opencode.theme.json` inside its directory. Custom Bat themes may be copied into
Bat's theme directory and its cache rebuilt.

VS Code settings are never modified, including JSONC files with comments. Use
VS Code's `window.autoDetectColorScheme`, `workbench.preferredLightColorTheme`,
and `workbench.preferredDarkColorTheme` settings instead. `VSCODE_THEME` mappings
are retained only as suggestions shown by `theme-sync current`.
