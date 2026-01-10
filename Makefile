.PHONY: help install uninstall install-brew sync-brew check clean

# Default target
help:
	@echo "Dotfiles Management"
	@echo ""
	@echo "Usage:"
	@echo "  make install          Install all configurations"
	@echo "  make brew-install     Install Homebrew packages from Brewfile"
	@echo "  make brew-sync        Update Brewfile with current brew packages"
	@echo "  make uninstall        Remove all symlinks"
	@echo "  make check            Show what would be installed"
	@echo "  make clean            Remove caches and temporary files"
	@echo ""
	@echo "Selective installation:"
	@echo "  ./install.sh nvim tmux  Install only specific configs"

# Install all configurations
install:
	@./scripts/install.sh

# Install Homebrew packages
brew-install:
	@./scripts/install-brew.sh

# Sync Brewfile with current brew packages
brew-sync:
	@./scripts/sync-brewfile.sh

# Uninstall all configurations
uninstall:
	@echo "Removing all symlinks..."
	@stow -D -v -t ~ */

# Check what would be installed (dry run)
check:
	@echo "Checking what would be installed..."
	@stow -n -v -t ~ */

# Clean temporary and cache files
clean:
	@echo "Cleaning temporary files..."
	@find . -type f -name "*.log" -delete
	@find . -type f -name ".DS_Store" -delete
	@find . -type d -name ".cache" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name ".state" -exec rm -rf {} + 2>/dev/null || true
	@echo "Clean complete"
