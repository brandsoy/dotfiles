# Dotfiles

Personal configuration files for macOS/Linux development environment.

## Structure

```
dotfiles/
├── brew/          # Homebrew package management
│   ├── Brewfile   # Package list
│   ├── install-brew.sh
│   └── sync-brewfile.sh
├── home/          # User home directory configs
│   ├── bashrc/    # Bash shell configuration
│   ├── bin/       # Personal scripts
│   ├── config/    # XDG config directory (~/.config/)
│   ├── tmux/      # Terminal multiplexer config
│   └── zshrc/     # Zsh shell configuration
├── install.sh     # Main installation script
└── Makefile       # Convenience commands
```

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
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles
./install.sh
```

The install script will automatically:
- Detect your OS (macOS, Debian, Arch, etc.)
- Install Homebrew if needed (macOS only)
- Install GNU Stow if needed
- Symlink all configurations

Or use the Makefile:
```bash
make install       # Install all configurations
make check         # Preview what would be installed
make uninstall     # Remove all symlinks
```

## Selective Installation

Install specific configs only:
```bash
# Install just specific packages
./install.sh config bin

# Install shell configs
./install.sh bashrc zshrc
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

### Personal Scripts
- **update-blocklist.sh** - Update hosts file with ad/tracker blocklist

## Brewfile Management

Keep your Brewfile in sync with installed packages:

```bash
# Preview and install packages from Brewfile (with confirmation)
make brew-install
# or
./brew/install-brew.sh

# Update Brewfile with currently installed packages (with confirmation)
make brew-sync
# or
./brew/sync-brewfile.sh
```

**brew-install** script will:
- Show what packages would be installed/upgraded
- List changes by category (taps, formulae, casks, etc.)
- Prompt for confirmation before installing

**brew-sync** script will:
- Create a backup of your current Brewfile
- Generate a new Brewfile from installed packages
- Show a diff of changes
- Prompt for confirmation before updating
- Preserve descriptions for packages

## Management Commands

```bash
make help          # Show all available commands
make install       # Install all configurations
make check         # Preview what would be installed
make uninstall     # Remove all symlinks
make brew-install  # Install Homebrew packages
make brew-sync     # Update Brewfile with current packages
make clean         # Remove temporary files and caches
```

## Uninstalling

Remove all symlinks:
```bash
make uninstall
```

Or manually remove specific configs:
```bash
cd ~/dotfiles/home
stow -D -v -t ~ config bin bashrc
```

## Clean Reinstall

Remove existing data before installing:
```bash
# Neovim
rm -rf ~/.config/nvim ~/.local/state/nvim ~/.local/share/nvim

# All configs
make uninstall
make install
```

## Notes

- Sensitive files (tokens, logs, caches) are excluded via `.gitignore`
- Some configs are macOS-specific (aerospace, raycast, karabiner)
- Some configs are Linux-specific (hypr, waybar)
- Install script supports Debian/Ubuntu, Arch Linux, and macOS
- Works with or without sudo on Arch systems
- All user scripts in `home/bin/` are symlinked to `~/bin/`
