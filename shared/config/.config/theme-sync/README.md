# theme-sync

Single source of truth for terminal theme selection.

Note: the executable lives in `~/dotfiles/scripts/theme-sync.sh`.

## Layout

- `current` - active theme name
- `current.env` - shell-friendly exports used by `.zshrc`
- `themes/<name>/theme.env` - app mapping for a theme
- `themes/<name>/alacritty.toml` - Alacritty theme file (centralized)
- `themes/<name>/kitty.conf` - Kitty theme file (centralized)
- `themes/<name>/fzf.sh` - fzf color script (centralized)

## Commands

```bash
theme-sync            # open TUI
theme-sync tui
theme-sync list
theme-sync current
theme-sync set tokyonight-night
theme-sync apply

# configure automatic light/dark switching
theme-sync mode-set light <light-theme>
theme-sync mode-set dark <dark-theme>

# apply based on current system appearance (macOS)
theme-sync auto

# keep watching and auto-apply on changes
theme-sync auto --watch 5
```

## Managed targets

- `~/.config/ghostty/auto/theme.ghostty`
- `~/.config/alacritty/alacritty.toml`
- `~/.config/kitty/kitty.conf`
- `~/.config/bat/config`
- `~/.config/btop/btop.conf`
- `~/.local/state/nvim/theme.txt`

Automatic mode configuration is stored in `mode.env`:

```bash
THEME_LIGHT="..."
THEME_DARK="..."
```

(You can also override with env vars `THEME_SYNC_LIGHT_THEME` and `THEME_SYNC_DARK_THEME`.)

Optional per-theme file copies are supported by adding these files inside `themes/<name>/`:

- `lazygit.yml` -> `~/.config/lazygit/config.yml`
- `yazi.theme.toml` -> `~/.config/yazi/theme.toml`
- `eza.theme.yml` -> `~/.config/eza/theme.yml`
- `tmux.theme.conf` -> `~/.config/tmux/theme.conf`
- `opencode.theme.json` -> `~/.config/opencode/theme.json`
