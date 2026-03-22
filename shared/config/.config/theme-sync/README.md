# theme-sync

Single source of truth for terminal theme selection.

## Layout

- `current` - active theme name
- `current.env` - shell-friendly exports used by `.zshrc`
- `themes/<name>/theme.env` - app mapping for a theme

## Commands

```bash
theme-sync list
theme-sync current
theme-sync set tokyonight-night
theme-sync apply
```

## Managed targets

- `~/.config/ghostty/auto/theme.ghostty`
- `~/.config/alacritty/alacritty.toml`
- `~/.config/kitty/kitty.conf`
- `~/.config/bat/config`
- `~/.config/btop/btop.conf`
- `~/.local/state/nvim/theme.txt`

Optional per-theme file copies are supported by adding these files inside `themes/<name>/`:

- `lazygit.yml` -> `~/.config/lazygit/config.yml`
- `yazi.theme.toml` -> `~/.config/yazi/theme.toml`
- `eza.theme.yml` -> `~/.config/eza/theme.yml`
