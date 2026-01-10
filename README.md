# Dotfiles

Personal configuration files for macOS/Linux development environment.

## Prerequisites

The install script will automatically install missing prerequisites, but you can also install manually:

- [GNU Stow](https://www.gnu.org/software/stow/) - Symlink manager
- [Homebrew](https://brew.sh/) (macOS only) - Package manager

Manual installation:
```bash
# macOS
brew install stow

# Debian/Ubuntu
sudo apt install stow

# Arch Linux (as root or with sudo)
pacman -S stow
```

## Quick Start

Clone and install all configs (auto-installs prerequisites):
```bash
git clone <your-repo-url> ~/.dotfiles
cd ~/.dotfiles
./scripts/install.sh
```

The install script will automatically:
- Detect your OS (macOS, Debian, Arch, etc.)
- Install Homebrew if needed (macOS only)
- Install GNU Stow if needed
- Symlink all configurations

Or use the Makefile:
```bash
make install
```

Or manually with stow:
```bash
stow -v -t ~ */
```

## Selective Installation

Install specific configs only:
```bash
# Install just neovim and tmux
./scripts/install.sh nvim tmux

# Install terminal configs
./scripts/install.sh alacritty kitty ghostty wezterm
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

## Brewfile Management

Keep your Brewfile in sync with installed packages:

```bash
# Preview and install packages from Brewfile (with confirmation)
make install-brew
# or
./scripts/install-brew.sh

# Update Brewfile with currently installed packages (with confirmation)
make sync-brew
# or
./scripts/sync-brewfile.sh
```

**install-brew** script will:
- Show what packages would be installed/upgraded
- List changes by category (taps, formulae, casks, etc.)
- Prompt for confirmation before installing

**sync-brew** script will:
- Create a backup of your current Brewfile
- Generate a new Brewfile from installed packages
- Show a diff of changes
- Prompt for confirmation before updating
- Preserve descriptions for packages

## Uninstalling

Remove all symlinks:
```bash
make uninstall
```

Or manually remove specific configs:
```bash
stow -D -v -t ~ nvim tmux
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
- Install script supports Debian/Ubuntu, Arch Linux, and macOS
- Works with or without sudo on Arch systems
