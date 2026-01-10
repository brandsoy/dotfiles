#!/usr/bin/env bash

set -e

DOTFILES_DIR="$HOME/.dotfiles"
BREWFILE="$DOTFILES_DIR/Brewfile"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Brewfile Install Preview ===${NC}\n"

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo -e "${RED}Error: Homebrew is not installed${NC}"
    echo "Install from: https://brew.sh"
    exit 1
fi

# Check if Brewfile exists
if [ ! -f "$BREWFILE" ]; then
    echo -e "${RED}Error: Brewfile not found at $BREWFILE${NC}"
    exit 1
fi

cd "$DOTFILES_DIR"

# Check what would be installed/upgraded/removed
echo -e "${YELLOW}Checking what would be installed...${NC}\n"

# Run brew bundle check to see what's missing
if brew bundle check --file="$BREWFILE" > /dev/null 2>&1; then
    echo -e "${GREEN}✓ All packages are already installed${NC}"
    exit 0
fi

# Show detailed list of changes
echo -e "${BLUE}The following changes would be made:${NC}\n"

# Create temp file for output
TEMP_OUTPUT=$(mktemp)

# Capture brew bundle list
brew bundle list --file="$BREWFILE" > "$TEMP_OUTPUT"

# Check each category
echo -e "${YELLOW}Taps:${NC}"
while IFS= read -r tap; do
    if ! brew tap | grep -q "^${tap}$"; then
        echo -e "  ${GREEN}+ ${tap}${NC}"
    fi
done < <(brew bundle list --taps --file="$BREWFILE" 2>/dev/null || true)

echo -e "\n${YELLOW}Formulae (brew):${NC}"
while IFS= read -r formula; do
    if ! brew list --formula | grep -q "^${formula}$"; then
        echo -e "  ${GREEN}+ ${formula}${NC}"
    fi
done < <(brew bundle list --brews --file="$BREWFILE" 2>/dev/null || true)

echo -e "\n${YELLOW}Casks (applications):${NC}"
while IFS= read -r cask; do
    if ! brew list --cask | grep -q "^${cask}$"; then
        echo -e "  ${GREEN}+ ${cask}${NC}"
    fi
done < <(brew bundle list --casks --file="$BREWFILE" 2>/dev/null || true)

echo -e "\n${YELLOW}Mac App Store apps:${NC}"
while IFS= read -r mas; do
    mas_id=$(echo "$mas" | awk '{print $1}')
    if ! mas list | grep -q "^${mas_id}"; then
        echo -e "  ${GREEN}+ ${mas}${NC}"
    fi
done < <(brew bundle list --mas --file="$BREWFILE" 2>/dev/null || true)

echo -e "\n${YELLOW}VS Code extensions:${NC}"
while IFS= read -r vscode; do
    if ! code --list-extensions 2>/dev/null | grep -q "^${vscode}$"; then
        echo -e "  ${GREEN}+ ${vscode}${NC}"
    fi
done < <(brew bundle list --vscode --file="$BREWFILE" 2>/dev/null || true)

rm -f "$TEMP_OUTPUT"

# Prompt user
echo -e "\n${YELLOW}Proceed with installation?${NC}"
echo -e "${BLUE}This will run: brew bundle --file=$BREWFILE${NC}"
read -p "Continue? [y/N] " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Cancelled. No packages were installed.${NC}"
    exit 0
fi

# Run brew bundle
echo -e "\n${GREEN}Installing packages...${NC}\n"
brew bundle --file="$BREWFILE"

echo -e "\n${GREEN}=== Installation Complete ===${NC}"
