#!/usr/bin/env bash

set -e

DOTFILES_DIR="$HOME/.dotfiles"
BREWFILE="$DOTFILES_DIR/Brewfile"
BREWFILE_BACKUP="$DOTFILES_DIR/Brewfile.backup"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Brewfile Sync ===${NC}\n"

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo -e "${RED}Error: Homebrew is not installed${NC}"
    echo "Install from: https://brew.sh"
    exit 1
fi

# Check if in dotfiles directory
if [ ! -f "$BREWFILE" ]; then
    echo -e "${RED}Error: Brewfile not found at $BREWFILE${NC}"
    echo "Are you in the dotfiles directory?"
    exit 1
fi

# Create backup of current Brewfile
echo -e "${YELLOW}Creating backup of current Brewfile...${NC}"
cp "$BREWFILE" "$BREWFILE_BACKUP"
echo -e "${GREEN}✓ Backup created: Brewfile.backup${NC}\n"

# Generate new Brewfile
echo -e "${YELLOW}Generating new Brewfile from current brew installation...${NC}"
cd "$DOTFILES_DIR"

if brew bundle dump --describe --force --file="$BREWFILE"; then
    echo -e "${GREEN}✓ Brewfile updated successfully${NC}\n"
    
    # Show differences
    echo -e "${BLUE}Changes detected:${NC}"
    if diff -u "$BREWFILE_BACKUP" "$BREWFILE" | tail -n +3; then
        echo -e "\n${GREEN}No changes detected${NC}"
        rm "$BREWFILE_BACKUP"
    else
        echo -e "\n${YELLOW}Summary:${NC}"
        
        # Count changes
        ADDED=$(diff "$BREWFILE_BACKUP" "$BREWFILE" | grep "^+" | grep -v "^+++" | wc -l | tr -d ' ')
        REMOVED=$(diff "$BREWFILE_BACKUP" "$BREWFILE" | grep "^-" | grep -v "^---" | wc -l | tr -d ' ')
        
        echo -e "${GREEN}  + $ADDED new entries${NC}"
        echo -e "${RED}  - $REMOVED removed entries${NC}"
        
        # Ask to keep backup
        echo -e "\n${YELLOW}Backup kept at: Brewfile.backup${NC}"
        echo -e "To restore: ${BLUE}mv Brewfile.backup Brewfile${NC}"
    fi
    
    # Suggest git commit
    if git -C "$DOTFILES_DIR" rev-parse --git-dir > /dev/null 2>&1; then
        echo -e "\n${YELLOW}Don't forget to commit changes:${NC}"
        echo -e "  ${BLUE}git add Brewfile${NC}"
        echo -e "  ${BLUE}git commit -m 'chore: update Brewfile'${NC}"
    fi
else
    echo -e "${RED}✗ Failed to generate Brewfile${NC}"
    echo -e "${YELLOW}Restoring backup...${NC}"
    mv "$BREWFILE_BACKUP" "$BREWFILE"
    exit 1
fi
