#!/usr/bin/env bash
set -e

# Configuration
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
STOW_DIR="$DOTFILES_DIR/home"
TARGET_DIR="$HOME"

# OS Detection
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "This dotfiles repo is for macOS only."
    exit 1
fi

echo "Detected OS: macOS"

# Helper: Check command existence
has_cmd() { command -v "$1" >/dev/null 2>&1; }

# 1. Install Dependencies
install_dependencies() {
    echo "Checking dependencies..."
    if ! has_cmd brew; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    if ! has_cmd stow; then
        echo "Installing stow..."
        brew install stow
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
    local vscode_dest="$HOME/Library/Application Support/Code/User/settings.json"

    if [[ -f "$vscode_src" ]]; then
        mkdir -p "$(dirname "$vscode_dest")"
        ln -sf "$vscode_src" "$vscode_dest"
        echo "  - VSCode settings linked."
    else
        echo "  - VSCode setup skipped (settings.json not found)."
    fi
}

# 4. Install Packages
install_packages() {
    if [[ -f "$DOTFILES_DIR/Brewfile" ]]; then
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