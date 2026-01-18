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

# Helper: Stow a single package
stow_package() {
    local pkg="$1"
    # Check if package exists in STOW_DIR
    if [[ -d "$STOW_DIR/$pkg" ]]; then
        echo "  - Stowing $pkg"
        # We need to run stow from the stow directory or use -d
        pushd "$STOW_DIR" >/dev/null
        stow -R --no-folding -t "$TARGET_DIR" "$pkg"
        popd >/dev/null
    else
        echo "Warning: Package '$pkg' not found in $STOW_DIR"
    fi
}

# 2. Handle VSCode (Special Case)
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

# 3. Install Packages
install_packages() {
    if [[ -f "$DOTFILES_DIR/Brewfile" ]]; then
        echo "Installing Homebrew bundle..."
        brew bundle --file="$DOTFILES_DIR/Brewfile"
    fi
}

# Main Execution
install_dependencies

if [[ $# -eq 0 ]]; then
    # No arguments: Install everything
    echo "Stowing all dotfiles..."
    
    # Iterate over directories in STOW_DIR
    for package_path in "$STOW_DIR"/*; do
        package_name=$(basename "$package_path")
        
        if [[ -d "$package_path" && "$package_name" != "vscode" ]]; then
            stow_package "$package_name"
        fi
    done

    setup_vscode
    install_packages
else
    # Arguments provided: Install specific packages
    for target in "$@"; do
        if [[ "$target" == "vscode" ]]; then
            setup_vscode
        elif [[ "$target" == "brew" ]]; then
            install_packages
        else
            stow_package "$target"
        fi
    done
fi

echo "Done!"
