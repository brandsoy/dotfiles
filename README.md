# Dotfiles

Personal configuration files for macOS and Linux (Arch/Debian).

## Structure

```
dotfiles/
├── shared/            # Cross-platform configs (stow packages)
│   ├── bin/           # Personal scripts
│   ├── config/        # Shared .config (nvim, alacritty, bat, etc.)
│   ├── git/           # Git configuration
│   ├── ssh/           # SSH keys
│   ├── tmux/          # Tmux configuration
│   └── zshrc/         # Zsh configuration
├── mac/               # macOS-specific configs
│   ├── config/        # aerospace, karabiner, raycast
│   └── Brewfile       # Homebrew packages
├── linux/             # Linux-specific configs
│   ├── config/        # hypr, waybar, keyd, swaync, gtk, etc.
│   ├── scripts/       # Linux scripts
│   └── Archfile       # Arch Linux packages
└── install.sh         # Auto-detecting installation script
```

## Quick Start

1.  Clone the repository:
    ```bash
    git clone <your-repo-url> ~/dotfiles
    cd ~/dotfiles
    ```

2.  Run the installation script:
    ```bash
    ./install.sh
    ```

This script will:
-   **Detect OS** (macOS, Arch, Debian, or generic Linux)
-   **Install dependencies** (stow, git, curl, zsh, etc.)
-   **Symlink shared configs** using GNU Stow
-   **Symlink OS-specific configs** based on detected OS
-   **Install packages**:
    -   macOS: Installs from `mac/Brewfile`
    -   Arch: Installs from `linux/Archfile` (pacman + AUR)
    -   Debian: Installs common tools via apt

## Selective Installation

```bash
# Install only shared configs
./install.sh shared

# Install only OS-specific configs
./install.sh mac
./install.sh linux

# Install a specific package
./install.sh config
./install.sh nvim

# Only install packages (no stow)
./install.sh packages
```

## Uninstalling

To remove symlinks:

```bash
# Shared packages
cd ~/dotfiles/shared && stow -D -t ~ <package>

# Mac packages
cd ~/dotfiles/mac && stow -D -t ~ config

# Linux packages
cd ~/dotfiles/linux && stow -D -t ~ config
```
