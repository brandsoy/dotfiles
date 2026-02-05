#!/usr/bin/env bash
set -e

# Configuration
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SHARED_DIR="$DOTFILES_DIR/shared"
MAC_DIR="$DOTFILES_DIR/mac"
LINUX_DIR="$DOTFILES_DIR/linux"
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
        OS="redhat"
    else
        echo "Warning: Unsupported OS ($OSTYPE). Assuming generic Linux."
        OS="linux"
    fi
    echo "Detected OS: $OS"
}

# Helper: Check command existence
has_cmd() { command -v "$1" >/dev/null 2>&1; }

# Install Dependencies
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

# Helper: Stow a single package from a directory
stow_package() {
    local stow_dir="$1"
    local pkg="$2"
    if [[ -d "$stow_dir/$pkg" ]]; then
        echo "  - Stowing $pkg"
        pushd "$stow_dir" >/dev/null
        stow -R -t "$TARGET_DIR" "$pkg"
        popd >/dev/null
    else
        echo "Warning: Package '$pkg' not found in $stow_dir"
    fi
}

# Stow all packages from a directory
stow_all_from() {
    local stow_dir="$1"
    local skip_pattern="$2"

    if [[ ! -d "$stow_dir" ]]; then
        echo "Warning: Directory '$stow_dir' not found"
        return
    fi

    for package_path in "$stow_dir"/*; do
        [[ -d "$package_path" ]] || continue
        local package_name=$(basename "$package_path")

        # Skip if matches pattern
        if [[ -n "$skip_pattern" && "$package_name" =~ $skip_pattern ]]; then
            continue
        fi

        stow_package "$stow_dir" "$package_name"
    done
}

# Install Packages
install_packages() {
    if [[ "$OS" == "macos" ]]; then
        if [[ -f "$MAC_DIR/Brewfile" ]]; then
            echo "Installing Homebrew bundle..."
            brew bundle --file="$MAC_DIR/Brewfile"
        fi
        # Configure git credential helper for macOS
        git config --global credential.helper osxkeychain

    elif [[ "$OS" == "arch" ]]; then
        echo "Installing Arch packages from Archfile..."

        if [[ -f "$LINUX_DIR/Archfile" ]]; then
            # Install pacman packages (exclude comments and AUR lines)
            local packages=($(grep -v '^#' "$LINUX_DIR/Archfile" | grep -v '^AUR:' | grep -v '^$' | xargs))
            if [ ${#packages[@]} -gt 0 ]; then
                sudo pacman -S --needed --noconfirm "${packages[@]}"
            fi

            # Check for AUR helper and install AUR packages
            if has_cmd paru; then
                local aur_packages=($(grep '^AUR:' "$LINUX_DIR/Archfile" | sed 's/^AUR: //' | xargs))
                if [ ${#aur_packages[@]} -gt 0 ]; then
                    echo "Installing AUR packages..."
                    paru -S --needed --noconfirm "${aur_packages[@]}"
                fi
            elif has_cmd yay; then
                local aur_packages=($(grep '^AUR:' "$LINUX_DIR/Archfile" | sed 's/^AUR: //' | xargs))
                if [ ${#aur_packages[@]} -gt 0 ]; then
                    echo "Installing AUR packages..."
                    yay -S --needed --noconfirm "${aur_packages[@]}"
                fi
            else
                echo "Warning: No AUR helper (paru/yay) found. Install one to get AUR packages."
            fi
        fi

        git config --global credential.helper cache
        echo "Arch package installation complete."

    elif [[ "$OS" == "debian" ]]; then
        echo "Installing recommended Debian packages..."
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

    elif [[ "$OS" == "redhat" ]]; then
        echo "Installing recommended Fedora/RHEL packages..."
        local packages=(
            tmux neovim ripgrep fzf bat jq unzip tree
            htop btop fd-find zoxide
        )

        sudo dnf install -y "${packages[@]}"

        # Install Starship (Shell prompt)
        if ! has_cmd starship; then
            echo "Installing Starship..."
            curl -sS https://starship.rs/install.sh | sh -s -- -y
        fi

        git config --global credential.helper cache
        echo "Fedora/RHEL package installation complete."
    fi
}

# Install extra tools (lazydocker, lazygit, gh)
install_extra_tools() {
    echo ""
    echo "Checking extra tools (lazydocker, lazygit, gh)..."

    # gh CLI
    if ! has_cmd gh; then
        echo "Installing GitHub CLI..."
        if [[ "$OS" == "macos" ]]; then
            brew install gh
        elif [[ "$OS" == "arch" ]]; then
            sudo pacman -S --needed --noconfirm github-cli
        elif [[ "$OS" == "debian" ]]; then
            curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
            sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
            sudo apt-get update
            sudo apt-get install -y gh
        elif [[ "$OS" == "redhat" ]]; then
            sudo dnf install -y gh
        fi
    fi

    # lazygit
    if ! has_cmd lazygit; then
        echo "Installing lazygit..."
        if [[ "$OS" == "macos" ]]; then
            brew install lazygit
        elif [[ "$OS" == "arch" ]]; then
            sudo pacman -S --needed --noconfirm lazygit
        else
            LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
            curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
            tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
            sudo install /tmp/lazygit /usr/local/bin
            rm -f /tmp/lazygit /tmp/lazygit.tar.gz
        fi
    fi

    # lazydocker
    if ! has_cmd lazydocker; then
        echo "Installing lazydocker..."
        if [[ "$OS" == "macos" ]]; then
            brew install lazydocker
        elif [[ "$OS" == "arch" ]]; then
            if has_cmd paru; then
                paru -S --needed --noconfirm lazydocker
            elif has_cmd yay; then
                yay -S --needed --noconfirm lazydocker
            else
                echo "Warning: No AUR helper (paru/yay) found. Cannot install lazydocker on Arch without one."
            fi
        else
            LAZYDOCKER_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazydocker/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
            curl -Lo /tmp/lazydocker.tar.gz "https://github.com/jesseduffield/lazydocker/releases/latest/download/lazydocker_${LAZYDOCKER_VERSION}_Linux_x86_64.tar.gz"
            tar xf /tmp/lazydocker.tar.gz -C /tmp lazydocker
            sudo install /tmp/lazydocker /usr/local/bin
            rm -f /tmp/lazydocker /tmp/lazydocker.tar.gz
        fi
    fi

    # mise (mise-en-place)
    if ! has_cmd mise; then
        echo "Installing mise..."
        if [[ "$OS" == "macos" ]]; then
            brew install mise
        else
            curl https://mise.run | sh
        fi
    fi
}

# Main Execution
detect_os
install_dependencies

if [[ $# -eq 0 ]]; then
    # No arguments: Install everything
    echo ""
    echo "Stowing shared dotfiles..."
    stow_all_from "$SHARED_DIR"

    echo ""
    if [[ "$OS" == "macos" ]]; then
        echo "Stowing macOS-specific dotfiles..."
        stow_all_from "$MAC_DIR" "Brewfile"
    else
        echo "Stowing Linux-specific dotfiles..."
        stow_all_from "$LINUX_DIR" "Archfile"
    fi

    install_packages
    install_extra_tools
else
    # Arguments provided: Install specific packages
    for target in "$@"; do
        if [[ "$target" == "packages" || "$target" == "brew" ]]; then
            install_packages
        elif [[ "$target" == "tools" ]]; then
            install_extra_tools
        elif [[ "$target" == "shared" ]]; then
            echo "Stowing shared dotfiles..."
            stow_all_from "$SHARED_DIR"
        elif [[ "$target" == "mac" ]]; then
            echo "Stowing macOS dotfiles..."
            stow_all_from "$MAC_DIR" "Brewfile"
        elif [[ "$target" == "linux" ]]; then
            echo "Stowing Linux dotfiles..."
            stow_all_from "$LINUX_DIR" "Archfile"
        else
            # Try to find the package in shared, mac, or linux
            if [[ -d "$SHARED_DIR/$target" ]]; then
                stow_package "$SHARED_DIR" "$target"
            elif [[ -d "$MAC_DIR/$target" ]]; then
                stow_package "$MAC_DIR" "$target"
            elif [[ -d "$LINUX_DIR/$target" ]]; then
                stow_package "$LINUX_DIR" "$target"
            else
                echo "Warning: Package '$target' not found in shared, mac, or linux"
            fi
        fi
    done
fi

# Install TPM (Tmux Plugin Manager)
if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
    echo "Installing Tmux Plugin Manager..."
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    echo "TPM installed. Start tmux and press Ctrl+b I (capital i) to install plugins."
else
    echo "TPM already installed."
fi

# Set zsh as default shell if not already set
if [[ "$SHELL" != *"zsh"* ]] && has_cmd zsh; then
    echo "Setting zsh as default shell..."
    chsh -s "$(which zsh)"
    echo "Shell changed to zsh. Log out and back in for changes to take effect."
fi

echo ""
echo "Done! Relaunch your shell to see changes."
