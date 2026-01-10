.PHONY: help install uninstall install-brew sync-brew check clean clean-local

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
	@echo "  make clean-local      Remove local configs to prepare for stow"
	@echo ""
	@echo "Selective installation:"
	@echo "  ./install.sh config bin  Install only specific packages"

# Install all configurations
install:
	@./install.sh

# Install Homebrew packages
brew-install:
	@./brew/install-brew.sh

# Sync Brewfile with current brew packages
brew-sync:
	@./brew/sync-brewfile.sh

# Uninstall all configurations
uninstall:
	@echo "Removing all symlinks..."
	@cd home && stow -D -v -t ~ bashrc bin config tmux zshrc

# Check what would be installed (dry run)
check:
	@echo "Checking what would be installed..."
	@echo "\n--- All home directory configs ---"
	@cd home && stow -n -vv -t ~ bashrc bin config tmux zshrc 2>&1 | grep "LINK:" || echo "✓ All configs already installed"

# Clean temporary and cache files
clean:
	@echo "Cleaning temporary files..."
	@find . -type f -name "*.log" -delete
	@find . -type f -name ".DS_Store" -delete
	@find . -type d -name ".cache" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name ".state" -exec rm -rf {} + 2>/dev/null || true
	@echo "Clean complete"

# Remove local config files that exist in dotfiles repo (prep for stow)
clean-local:
	@./clean-before-stow.sh --dry-run
	@echo ""
	@read -p "Do you want to proceed with removing these files? (y/N) " -n 1 -r; \
	echo ""; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		./clean-before-stow.sh; \
	else \
		echo "Cancelled."; \
	fi
