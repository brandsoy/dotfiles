# Dotfiles

Personal configuration files for macOS/Linux development environment.

## Prerequisites

- [GNU Stow](https://www.gnu.org/software/stow/) - Symlink manager
- [Homebrew](https://brew.sh/) (macOS) - Package manager

Install prerequisites:
```bash
# macOS
brew install stow

# Linux (Debian/Ubuntu)
sudo apt install stow
```

## Quick Start

Clone and install all configs:
```bash
git clone <your-repo-url> ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

Or manually with stow:
```bash
stow -v -t ~ */
```

## Selective Installation

Install specific configs only:
```bash
# Install just neovim and tmux
stow -v -t ~ nvim tmux

# Install terminal configs
stow -v -t ~ alacritty kitty ghostty wezterm
```

## Configurations Included

### Editors & IDEs
- **nvim** - Neovim with lazy.nvim plugin manager
- **helix** - Terminal-based editor
- **zed** - Modern code editor

### Terminal Emulators
- **alacritty** - GPU-accelerated terminal
- **kitty** - Feature-rich terminal
- **ghostty** - Fast terminal emulator
- **wezterm** - Terminal with multiplexing

### Shell & Prompt
- **zshrc** - Zsh configuration
- **bashrc** - Bash configuration
- **starship** - Cross-shell prompt

### Terminal Tools
- **tmux** - Terminal multiplexer
- **yazi** - File manager
- **lazygit** - Git TUI
- **lazydocker** - Docker TUI
- **btop** / **htop** - System monitors
- **bat** - Better cat with syntax highlighting

### Window Management
- **aerospace** - Tiling window manager (macOS)
- **hypr** - Hyprland compositor (Linux)
- **waybar** - Status bar (Linux)

### Utilities
- **raycast** - Productivity launcher (macOS)
- **karabiner** - Keyboard customization (macOS)
- **mise** - Runtime version manager
- **pgcli** - PostgreSQL CLI

### Package Management
- **Brewfile** - Homebrew packages list

## Uninstalling

Remove symlinks for specific configs:
```bash
stow -D -v -t ~ nvim tmux
```

Remove all symlinks:
```bash
stow -D -v -t ~ */
```

## Clean Reinstall

Remove existing Neovim data before installing:
```bash
rm -rf ~/.config/nvim
rm -rf ~/.local/state/nvim
rm -rf ~/.local/share/nvim
```

## Notes

- Sensitive files (tokens, logs, caches) are excluded via `.gitignore`
- Some configs are macOS-specific (aerospace, raycast, karabiner)
- Some configs are Linux-specific (hypr, waybar)
