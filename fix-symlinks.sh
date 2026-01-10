#!/usr/bin/env zsh

set -e

TARGET="$HOME"
OLD_DIR=".dotfiles"

echo "Fixing symlinks..."

echo "Looking for broken symlinks pointing to $OLD_DIR..."

# Find and delete symlinks pointing to the old directory
# Using -maxdepth 2 to cover ~ and ~/.config/ (and ~/bin/)
# Suppress stderr to hide "Operation not permitted" warnings
# OR true to prevent script exit on permission errors (common with find in home)

find "$TARGET" -maxdepth 2 -type l -lname "*$OLD_DIR*" -print -delete 2>/dev/null || true

echo "Broken symlinks removed."

# Ensure we are in the correct directory
cd "$HOME/dotfiles/home"

# Remove any remaining stale links from stow's perspective (if any valid ones match the current structure)
stow -D -t "$TARGET" bashrc bin config tmux zshrc 2>/dev/null || true

# Recreate symlinks with new path
echo "Stowing packages to $TARGET..."
stow -t "$TARGET" bashrc bin config tmux zshrc

echo "✓ Symlinks updated!"
echo ""
echo "Testing symlinks:"
ls -la ~ | grep -E "(bashrc|zshrc|tmux|bin)" | head -5
echo ""
ls -la ~/.config/ | grep dotfiles | head -5