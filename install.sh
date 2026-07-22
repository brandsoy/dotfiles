#!/usr/bin/env bash
set -e

# Configuration
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROLES_DIR="$DOTFILES_DIR/roles"
HOSTS_DIR="$DOTFILES_DIR/hosts"
TARGET_DIR="$HOME"
OS=""
HOSTNAME_SHORT="$(hostname -s 2>/dev/null || hostname)"

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

        if [[ "$pkg" == "bin" ]]; then
            # Keep ~/.local/bin as a real directory and symlink files inside it.
            mkdir -p "$TARGET_DIR/.local/bin"
            stow -R --no-folding -t "$TARGET_DIR" "$pkg"
        else
            stow -R -t "$TARGET_DIR" "$pkg"
        fi

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
        local package_name
        package_name=$(basename "$package_path")

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
        if [[ -f "$ROLES_DIR/packages-macos/Brewfile" ]]; then
            echo "Installing Homebrew bundle..."
            brew bundle --file="$ROLES_DIR/packages-macos/Brewfile"
        fi
        # Configure git credential helper for macOS
        git config --global credential.helper osxkeychain

    elif [[ "$OS" == "arch" ]]; then
        echo "Installing Arch packages from Archfile..."

        if [[ -f "$ROLES_DIR/packages-arch/Archfile" ]]; then
            # Install pacman packages (exclude comments and AUR lines)
            local packages=()
            while IFS= read -r pkg; do
                packages+=("$pkg")
            done < <(
                awk '!/^#/ && !/^AUR:/ && NF { for (i=1;i<=NF;i++) print $i }' "$ROLES_DIR/packages-arch/Archfile"
            )

            if ((${#packages[@]} > 0)); then
                sudo pacman -S --needed --noconfirm "${packages[@]}"
            fi

            local aur_packages=()
            while IFS= read -r pkg; do
                aur_packages+=("$pkg")
            done < <(
                awk '/^AUR:/ { sub(/^AUR:[[:space:]]*/, ""); for (i=1;i<=NF;i++) print $i }' "$ROLES_DIR/packages-arch/Archfile"
            )

            # Check for AUR helper and install AUR packages
            if ((${#aur_packages[@]} > 0)); then
                if has_cmd paru; then
                    echo "Installing AUR packages..."
                    paru -S --needed --noconfirm "${aur_packages[@]}"
                elif has_cmd yay; then
                    echo "Installing AUR packages..."
                    yay -S --needed --noconfirm "${aur_packages[@]}"
                else
                    echo "Warning: No AUR helper (paru/yay) found. Install one to get AUR packages."
                fi
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
        echo "Installing Fedora/RHEL packages..."

        if [[ -f "$ROLES_DIR/packages-redhat/Redhatfile" ]]; then
            local packages=()
            while IFS= read -r pkg; do
                packages+=("$pkg")
            done < <(
                awk '!/^#/ && NF { for (i=1;i<=NF;i++) print $i }' "$ROLES_DIR/packages-redhat/Redhatfile"
            )

            # Avoid common Fedora conflicts/missing packages.
            local filtered=()
            for pkg in "${packages[@]}"; do
                case "$pkg" in
                    docker|docker-compose)
                        if rpm -q podman-docker >/dev/null 2>&1; then
                            echo "Skipping $pkg (podman-docker is installed and conflicts with moby-engine)."
                            continue
                        fi
                        if has_cmd docker; then
                            echo "Skipping $pkg (docker command already available)."
                            continue
                        fi
                        ;;
                esac
                filtered+=("$pkg")
            done

            if ((${#filtered[@]} > 0)); then
                # --skip-unavailable prevents hard failure on packages not in current repos.
                sudo dnf install -y --skip-unavailable "${filtered[@]}"
            fi
        else
            local packages=(
                tmux neovim ripgrep fzf bat jq unzip tree
                htop btop fd-find zoxide
            )

            sudo dnf install -y --skip-unavailable "${packages[@]}"
        fi

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
    # On macOS these tools, including mise, are declared in the Brewfile.
    # Installing them here as well would let this imperative code drift from it.
    if [[ "$OS" == "macos" ]]; then
        echo "macOS extra tools are managed by roles/packages-macos/Brewfile."
        return 0
    fi

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

apply_host_overrides() {
    local host_dir="$HOSTS_DIR/$HOSTNAME_SHORT"
    [[ -d "$host_dir" ]] || { echo "No host overrides for $HOSTNAME_SHORT"; return 0; }

    # Stow host packages except `config` to avoid clashes with roles/config.
    stow_all_from "$host_dir" "^config$"

    # Apply host-specific theme-sync state files by copy (not symlink).
    local src_theme_dir="$host_dir/config/.config/theme-sync"
    if [[ -d "$src_theme_dir" ]]; then
        mkdir -p "$HOME/.config/theme-sync"
        for f in current current.env mode.env; do
            [[ -f "$src_theme_dir/$f" ]] && cp "$src_theme_dir/$f" "$HOME/.config/theme-sync/$f"
        done
        echo "Applied host theme-sync state for: $HOSTNAME_SHORT"
    fi
}

run_target() {
    local target="$1"

    if [[ "$target" == "packages" || "$target" == "brew" ]]; then
        install_packages
    elif [[ "$target" == "tools" ]]; then
        install_extra_tools
    elif [[ "$target" == "roles" || "$target" == "shared" ]]; then
        stow_all_from "$ROLES_DIR" "^(packages-macos|packages-arch|packages-redhat|macos-config|linux-config)$"
    elif [[ "$target" == "hosts" ]]; then
        apply_host_overrides
    elif [[ "$target" == "mac" ]]; then
        stow_package "$ROLES_DIR" "macos-config"
    elif [[ "$target" == "linux" ]]; then
        stow_package "$ROLES_DIR" "linux-config"
    elif [[ "$target" == "all" ]]; then
        echo ""
        echo "Stowing role packages..."
        stow_all_from "$ROLES_DIR" "^(packages-macos|packages-arch|packages-redhat|macos-config|linux-config)$"

        echo ""
        if [[ "$OS" == "macos" ]]; then
            stow_package "$ROLES_DIR" "macos-config"
        else
            stow_package "$ROLES_DIR" "linux-config"
        fi

        if [[ -d "$HOSTS_DIR/$HOSTNAME_SHORT" ]]; then
            echo ""
            echo "Applying host overrides for: $HOSTNAME_SHORT"
            apply_host_overrides
        fi

        install_packages
        install_extra_tools
    else
        if [[ -d "$ROLES_DIR/$target" ]]; then
            stow_package "$ROLES_DIR" "$target"
        elif [[ -d "$HOSTS_DIR/$HOSTNAME_SHORT/$target" ]]; then
            stow_package "$HOSTS_DIR/$HOSTNAME_SHORT" "$target"
        else
            echo "Warning: Package '$target' not found in roles or hosts/$HOSTNAME_SHORT"
        fi
    fi
}

apply_profile() {
    local profile="$1"

    case "$profile" in
        linux-server)
            run_target roles
            run_target hosts
            run_target packages
            run_target tools
            ;;
        linux-desktop)
            run_target roles
            run_target linux
            run_target hosts
            run_target packages
            run_target tools
            ;;
        macbook)
            run_target roles
            run_target mac
            run_target hosts
            run_target packages
            run_target tools
            ;;
        *)
            echo "Unknown profile: $profile"
            echo "Available profiles: linux-server, linux-desktop, macbook"
            return 1
            ;;
    esac
}

interactive_menu() {
    local choice

    echo ""
    echo "Available profiles:"
    echo "  1) linux-server"
    echo "  2) linux-desktop"
    echo "  3) macbook"
    echo "  4) quit"

    read -r -p "Choose machine profile [1-4]: " choice
    case "$choice" in
        1) apply_profile "linux-server" ;;
        2) apply_profile "linux-desktop" ;;
        3) apply_profile "macbook" ;;
        4) return 0 ;;
        *)
            echo "Invalid selection"
            return 1
            ;;
    esac
}

# Main Execution
detect_os
install_dependencies

if [[ $# -eq 0 ]]; then
    interactive_menu
elif [[ "${1:-}" == "menu" ]]; then
    interactive_menu
elif [[ "${1:-}" == "profile" ]]; then
    apply_profile "${2:-}"
else
    for target in "$@"; do
        run_target "$target"
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
