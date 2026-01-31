#!/usr/bin/env bash
set -e

# Configuration
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
STOW_DIR="$DOTFILES_DIR/home"
TARGET_DIR="$HOME"
OS=""

# OS Detection
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    elif [[ -f /etc/arch-release ]]; then
        OS="arch"
    elif [[ -f /etc/debian_version ]]; then
        OS="debian"
    elif [[ -f /etc/redhat-release ]]; then
        OS="redhat" # Basic support
    else
        echo "Warning: Unsupported OS ($OSTYPE). Assuming generic Linux."
        OS="linux"
    fi
    echo "Detected OS: $OS"
}

# Helper: Check command existence
has_cmd() { command -v "$1" >/dev/null 2>&1; }

# 1. Install Dependencies
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
        echo "Updating pacman..."
        sudo pacman -Syu --noconfirm
        echo "Installing core dependencies..."
        # git and base-devel are usually present if running this, but good to ensure
        sudo pacman -S --needed --noconfirm stow git curl base-devel zsh
    elif [[ "$OS" == "debian" ]]; then
        echo "Updating apt..."
        sudo apt-get update -y
        echo "Installing core dependencies..."
        sudo apt-get install -y stow git curl build-essential zsh
    elif [[ "$OS" == "redhat" ]]; then
        sudo dnf install -y stow git curl zsh
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
        stow -R -t "$TARGET_DIR" "$pkg"
        popd >/dev/null
    else
        echo "Warning: Package '$pkg' not found in $STOW_DIR"
    fi
}

# 2. Install Packages
install_packages() {
    if [[ "$OS" == "macos" ]]; then
        if [[ -f "$DOTFILES_DIR/Brewfile" ]]; then
            echo "Installing Homebrew bundle..."
            brew bundle --file="$DOTFILES_DIR/Brewfile"
        fi
        # Configure git credential helper for macOS
        git config --global credential.helper osxkeychain
    elif [[ "$OS" == "arch" ]]; then
        echo "Installing Arch packages from Archfile..."
        
        if [[ -f "$DOTFILES_DIR/Archfile" ]]; then
            # Install pacman packages (exclude comments and AUR lines)
            local packages=($(grep -v '^#' "$DOTFILES_DIR/Archfile" | grep -v '^AUR:' | grep -v '^$' | xargs))
            if [ ${#packages[@]} -gt 0 ]; then
                sudo pacman -S --needed --noconfirm "${packages[@]}"
            fi
            
            # Check for AUR helper and install AUR packages
            if has_cmd paru; then
                local aur_packages=($(grep '^AUR:' "$DOTFILES_DIR/Archfile" | sed 's/^AUR: //' | xargs))
                if [ ${#aur_packages[@]} -gt 0 ]; then
                    echo "Installing AUR packages..."
                    paru -S --needed --noconfirm "${aur_packages[@]}"
                fi
            elif has_cmd yay; then
                local aur_packages=($(grep '^AUR:' "$DOTFILES_DIR/Archfile" | sed 's/^AUR: //' | xargs))
                if [ ${#aur_packages[@]} -gt 0 ]; then
                    echo "Installing AUR packages..."
                    yay -S --needed --noconfirm "${aur_packages[@]}"
                fi
            else
                echo "Warning: No AUR helper (paru/yay) found. Install one to get AUR packages."
            fi
        fi
        
        # Configure git credential helper
        git config --global credential.helper cache
        
        echo "Arch package installation complete."
    elif [[ "$OS" == "debian" ]]; then
        echo "Installing recommended Debian packages..."
        # List of common tools from Brewfile that are in apt
        local packages=(
            tmux neovim ripgrep fzf bat jq unzip tree
            htop btop fd-find
        )
        
        sudo apt-get install -y "${packages[@]}"

        # Install Starship (Shell prompt)
        if ! has_cmd starship; then
            echo "Installing Starship..."
            curl -sS https://starship.rs/install.sh | sh -s -- -y
        fi

        # Install zoxide
        if ! has_cmd zoxide; then
            echo "Installing zoxide..."
            curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
        fi
        
        # Bat on debian is sometimes 'batcat', let's fix alias if needed
        if command -v batcat &>/dev/null && ! command -v bat &>/dev/null; then
             mkdir -p ~/.local/bin
             ln -sf /usr/bin/batcat ~/.local/bin/bat
             echo "Aliased batcat to bat in ~/.local/bin/bat"
        fi
        
        git config --global credential.helper cache
        echo "Debian package installation complete."
    fi
}

# Main Execution
detect_os
install_dependencies

if [[ $# -eq 0 ]]; then
    # No arguments: Install everything
    echo "Stowing all dotfiles..."
    
    # Iterate over directories in STOW_DIR
    for package_path in "$STOW_DIR"/*; do
        package_name=$(basename "$package_path")

        # Skip macOS-specific packages on Linux
        if [[ "$OS" != "macos" ]]; then
            case "$package_name" in
                aerospace|karabiner|raycast)
                    continue
                    ;;
            esac
        fi
        
        stow_package "$package_name"
    done

    install_packages
else
    # Arguments provided: Install specific packages
    for target in "$@"; do
        if [[ "$target" == "packages" || "$target" == "brew" ]]; then
            install_packages
        else
            stow_package "$target"
        fi
    done
fi

# Install TPM (Tmux Plugin Manager)
if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
    echo "Installing Tmux Plugin Manager..."
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    echo "TPM installed. Start tmux and press Ctrl+s I (capital i) to install plugins."
else
    echo "TPM already installed."
fi

# Set zsh as default shell if not already set
if [[ "$SHELL" != *"zsh"* ]] && has_cmd zsh; then
    echo "Setting zsh as default shell..."
    chsh -s "$(which zsh)"
    echo "Shell changed to zsh. Log out and back in for changes to take effect."
fi

echo "Done! Relaunch your shell to see changes."
