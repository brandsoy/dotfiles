#!/usr/bin/env bash
set -e

# Configuration
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
STOW_DIR="$DOTFILES_DIR/home"
TARGET_DIR="$HOME"

# OS Detection
OS="unknown"
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [ -f /etc/arch-release ]; then
    OS="arch"
fi

echo "Detected OS: $OS"

# Helper: Check command existence
has_cmd() { command -v "$1" >/dev/null 2>&1; }

# 1. Install Dependencies (Stow, Brew/Pacman)
install_dependencies() {
    echo "Checking dependencies..."
    if [[ "$OS" == "macos" ]]; then
        if ! has_cmd brew; then
            echo "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        if ! has_cmd stow; then
            echo "Installing stow..."
            brew install stow
        fi
    elif [[ "$OS" == "arch" ]]; then
        if ! has_cmd stow; then
            echo "Installing stow..."
            sudo pacman -S --noconfirm stow
        fi
        if ! has_cmd git; then
            sudo pacman -S --noconfirm git
        fi
    fi
}

# 2. Stow Packages
stow_dotfiles() {
    echo "Stowing dotfiles..."
    cd "$STOW_DIR"
    
    for package in *; do
        if [[ -d "$package" && "$package" != "vscode" ]]; then
            echo "  - Stowing $package"
            stow -R --no-folding -t "$TARGET_DIR" "$package"
        fi
    done
}

# 3. Handle VSCode (Special Case)
setup_vscode() {
    echo "Configuring VSCode..."
    local vscode_src="$STOW_DIR/vscode/settings.json"
    local vscode_dest=""

    if [[ "$OS" == "macos" ]]; then
        vscode_dest="$HOME/Library/Application Support/Code/User/settings.json"
    elif [[ "$OS" == "arch" ]]; then
        vscode_dest="$HOME/.config/Code/User/settings.json"
    fi

    if [[ -n "$vscode_dest" && -f "$vscode_src" ]]; then
        mkdir -p "$(dirname "$vscode_dest")"
        ln -sf "$vscode_src" "$vscode_dest"
        echo "  - VSCode settings linked."
    else
        echo "  - VSCode setup skipped (not found or unknown OS)."
    fi
}

# 4. Install Packages (Brewfile for Mac)
install_packages() {
    if [[ "$OS" == "macos" && -f "$DOTFILES_DIR/Brewfile" ]]; then
        echo "Installing Homebrew bundle..."
        brew bundle --file="$DOTFILES_DIR/Brewfile"
    fi
}

# Main Execution
install_dependencies
stow_dotfiles
setup_vscode
install_packages

echo "Done!"