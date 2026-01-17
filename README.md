# Dotfiles

Personal configuration files for macOS.

## Structure

```
dotfiles/
├── home/          # User home directory configs (stow packages)
│   ├── bashrc/    # Bash shell configuration
│   ├── bin/       # Personal scripts
│   ├── config/    # XDG config directory (~/.config/)
│   ├── vscode/    # VSCode settings (handled specially)
│   └── ...
├── install.sh     # Main installation script
└── Brewfile       # Homebrew package list (macOS)
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
-   Install dependencies (Homebrew, `stow`).
-   Symlink configuration files using GNU Stow.
-   Configure VSCode settings.
-   Install Homebrew packages from the Brewfile.

## Uninstalling

To remove symlinks, you can use `stow` manually:

```bash
cd ~/dotfiles/home
stow -D -t ~ <package_name>
```

Example:
```bash
cd ~/dotfiles/home
stow -D -t ~ bashrc
```