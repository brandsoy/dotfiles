# Dotfiles

Personal configuration files for macOS and Linux (Debian).

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
-   **Detect OS** (macOS or Debian).
-   **Install dependencies**:
    -   macOS: Homebrew, `stow`.
    -   Debian: `stow`, `git`, `curl`, `zsh`, `build-essential`.
-   **Symlink configuration files** using GNU Stow.
-   **Configure VSCode settings**.
-   **Install Packages**:
    -   macOS: Installs from `Brewfile`.
    -   Debian: Installs common tools (`neovim`, `tmux`, `ripgrep`, `fzf`, etc.) and `starship`/`zoxide`.

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
