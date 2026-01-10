#!/usr/bin/env bash

set -e

DOTFILES_DIR="$HOME/.dotfiles"
STOW_TARGET="$HOME"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Dotfiles Installation ===${NC}\n"

# Check if stow is installed
if ! command -v stow &> /dev/null; then
    echo -e "${RED}Error: GNU Stow is not installed${NC}"
    echo "Install it first:"
    echo "  macOS: brew install stow"
    echo "  Linux: sudo apt install stow"
    exit 1
fi

# Change to dotfiles directory
cd "$DOTFILES_DIR" || exit 1

# Function to install a package
install_package() {
    local package=$1
    echo -e "${YELLOW}Installing ${package}...${NC}"
    if stow -v -t "$STOW_TARGET" "$package" 2>&1 | grep -q "LINK"; then
        echo -e "${GREEN}✓ ${package} installed${NC}"
    else
        echo -e "${RED}✗ ${package} failed or already linked${NC}"
    fi
}

# Check for selective installation
if [ $# -eq 0 ]; then
    echo "Installing all configurations..."
    echo -e "${YELLOW}Tip: You can install specific configs with: ./install.sh nvim tmux${NC}\n"
    
    # Install all directories
    for dir in */; do
        package="${dir%/}"
        # Skip non-config directories
        if [[ "$package" != "scripts" ]]; then
            install_package "$package"
        fi
    done
else
    # Install only specified packages
    echo "Installing selected configurations: $*"
    for package in "$@"; do
        if [ -d "$package" ]; then
            install_package "$package"
        else
            echo -e "${RED}✗ ${package} not found${NC}"
        fi
    done
fi

echo -e "\n${GREEN}=== Installation Complete ===${NC}"
echo -e "\nTo uninstall: ${YELLOW}stow -D -t ~ <package>${NC}"
echo -e "To see what would be linked: ${YELLOW}stow -n -v -t ~ <package>${NC}"
