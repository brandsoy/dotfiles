#!/usr/bin/env bash

set -e

DOTFILES_DIR="$HOME/dotfiles"
STOW_TARGET="$HOME"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Dotfiles Installation ===${NC}\n"

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
else
    OS="unknown"
fi

# Check and install Homebrew (macOS only)
if [[ "$OS" == "macos" ]]; then
    if ! command -v brew &> /dev/null; then
        echo -e "${YELLOW}Homebrew not found. Installing Homebrew...${NC}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Check if installation succeeded
        if ! command -v brew &> /dev/null; then
            echo -e "${RED}Error: Homebrew installation failed${NC}"
            exit 1
        fi
        echo -e "${GREEN}✓ Homebrew installed${NC}\n"
    else
        echo -e "${GREEN}✓ Homebrew found${NC}"
    fi
fi

# Check and install stow
if ! command -v stow &> /dev/null; then
    echo -e "${YELLOW}GNU Stow not found. Installing...${NC}"
    
    # Detect if running as root or if sudo is available
    if [[ $EUID -eq 0 ]]; then
        SUDO=""
    elif command -v sudo &> /dev/null; then
        SUDO="sudo"
    else
        SUDO=""
        echo -e "${YELLOW}Note: Running without sudo (may require root)${NC}"
    fi
    
    if [[ "$OS" == "macos" ]]; then
        brew install stow
    elif [[ "$OS" == "linux" ]]; then
        if command -v apt &> /dev/null; then
            $SUDO apt update && $SUDO apt install -y stow
        elif command -v dnf &> /dev/null; then
            $SUDO dnf install -y stow
        elif command -v pacman &> /dev/null; then
            $SUDO pacman -S --noconfirm stow
        else
            echo -e "${RED}Error: Cannot detect package manager${NC}"
            echo "Please install stow manually"
            exit 1
        fi
    else
        echo -e "${RED}Error: Unsupported OS${NC}"
        exit 1
    fi
    
    # Verify installation
    if ! command -v stow &> /dev/null; then
        echo -e "${RED}Error: Stow installation failed${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ GNU Stow installed${NC}\n"
else
    echo -e "${GREEN}✓ GNU Stow found${NC}\n"
fi

# Change to dotfiles directory
cd "$DOTFILES_DIR" || exit 1

# Define packages to install
HOME_PACKAGES=("bashrc" "bin" "config" "git" "ssh" "tmux" "vscode" "zshrc")

# Function to install a package
install_package() {
    local package=$1
    
    if [ "$package" = "config" ]; then
        echo -e "${YELLOW}Installing ${package}/ → ~/.config/...${NC}"
        
        # List what's inside config before stowing
        if [ -d "$package/.config" ]; then
            echo -e "  Contents:"
            ls "$package/.config" | while read -r item; do
                echo -e "    ${BLUE}•${NC} ${item}"
            done
        fi
        
        # Stow the package
        if stow -v -t "$STOW_TARGET" "$package" 2>&1 | grep -q "LINK"; then
            echo -e "${GREEN}✓ ${package} installed${NC}"
        else
            echo -e "${RED}✗ ${package} failed or already linked${NC}"
        fi
    elif [ "$package" = "vscode" ]; then
        if [[ "$OS" == "macos" ]]; then
            VSCODE_TARGET="$HOME/Library/Application Support/Code/User"
        else
            VSCODE_TARGET="$HOME/.config/Code/User"
        fi
        echo -e "${YELLOW}Installing ${package} → ${VSCODE_TARGET}...${NC}"
        
        mkdir -p "$VSCODE_TARGET"
        
        if stow -v -t "$VSCODE_TARGET" "$package" 2>&1 | grep -q "LINK"; then
            echo -e "${GREEN}✓ ${package} installed${NC}"
        else
            echo -e "${RED}✗ ${package} failed or already linked${NC}"
        fi
    elif [ "$package" = "bin" ]; then
        echo -e "${YELLOW}Installing ${package}/ → ~/bin/...${NC}"
        
        # List scripts in bin
        if [ -d "$package" ]; then
            local count=$(ls -1 "$package" 2>/dev/null | wc -l | tr -d ' ')
            if [ "$count" -gt 0 ]; then
                echo -e "  Scripts: ${count}"
                ls "$package" | while read -r item; do
                    echo -e "    ${BLUE}•${NC} ${item}"
                done
            fi
        fi
        
        # Stow the package
        if stow -v -t "$STOW_TARGET" "$package" 2>&1 | grep -q "LINK"; then
            echo -e "${GREEN}✓ ${package} installed${NC}"
        else
            echo -e "${RED}✗ ${package} failed or already linked${NC}"
        fi
    else
        echo -e "${YELLOW}Installing ${package}...${NC}"
        if stow -v -t "$STOW_TARGET" "$package" 2>&1 | grep -q "LINK"; then
            echo -e "${GREEN}✓ ${package} installed${NC}"
        else
            echo -e "${RED}✗ ${package} failed or already linked${NC}"
        fi
    fi
}

# Check for selective installation
if [ $# -eq 0 ]; then
    echo "Installing all configurations..."
    echo -e "${YELLOW}Tip: You can install specific configs with: ./install.sh bashrc bin config${NC}\n"
    
    # Install home packages
    echo -e "\n${GREEN}=== Installing home directory configs ===${NC}"
    cd home
    for package in "${HOME_PACKAGES[@]}"; do
        install_package "$package"
    done
    cd "$DOTFILES_DIR"
else
    # Install only specified packages
    echo "Installing selected configurations: $*"
    for package in "$@"; do
        if [ -d "home/$package" ]; then
            cd home
            install_package "$package"
            cd "$DOTFILES_DIR"
        else
            echo -e "${RED}✗ ${package} not found${NC}"
        fi
    done
fi

echo -e "\n${GREEN}=== Installation Complete ===${NC}"
echo -e "\nTo uninstall: ${YELLOW}stow -D -t ~ <package>${NC}"
echo -e "To see what would be linked: ${YELLOW}stow -n -v -t ~ <package>${NC}"
