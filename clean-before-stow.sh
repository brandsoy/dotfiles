#!/usr/bin/env bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="${HOME_DIR:-$HOME}"
DRY_RUN=false

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Remove local config files that exist in dotfiles repo to prepare for stow.

OPTIONS:
    -d, --dry-run    Show what would be removed without actually removing
    -h, --help       Show this help message

EXAMPLE:
    # Preview what would be removed
    $(basename "$0") --dry-run

    # Actually remove the files
    $(basename "$0")
EOF
}

log_info() {
    echo -e "${GREEN}[INFO]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

if [[ "$DRY_RUN" == true ]]; then
    log_warn "DRY RUN MODE - No files will be removed"
fi

# Find all files in home/ directory (stow packages)
cd "$DOTFILES_DIR/home"

removed_count=0
skipped_count=0

# Process each stow package directory
for package in */; do
    package="${package%/}"
    
    # Find all files in this package
    while IFS= read -r -d '' file; do
        # Remove leading "./" and package name to get the home-relative path
        relative_path="${file#./}"
        target_path="$HOME_DIR/$relative_path"
        
        # Skip if target doesn't exist
        if [[ ! -e "$target_path" && ! -L "$target_path" ]]; then
            continue
        fi
        
        # Skip if it's already a symlink
        if [[ -L "$target_path" ]]; then
            log_info "Already a symlink: $target_path"
            skipped_count=$((skipped_count + 1))
            continue
        fi
        
        # Remove the file/directory
        if [[ "$DRY_RUN" == true ]]; then
            if [[ -d "$target_path" ]]; then
                log_warn "Would remove directory: $target_path"
            else
                log_warn "Would remove file: $target_path"
            fi
            removed_count=$((removed_count + 1))
        else
            if [[ -d "$target_path" ]]; then
                log_info "Removing directory: $target_path"
                rm -rf "$target_path"
            else
                log_info "Removing file: $target_path"
                rm -f "$target_path"
            fi
            removed_count=$((removed_count + 1))
        fi
    done < <(cd "$package" && find . -type f -o -type d -mindepth 1 | tr '\n' '\0')
done

echo ""
log_info "Summary:"
echo "  - Files/directories processed: $removed_count"
echo "  - Already symlinks (skipped): $skipped_count"

if [[ "$DRY_RUN" == true ]]; then
    echo ""
    log_warn "This was a dry run. Run without --dry-run to actually remove files."
else
    echo ""
    log_info "Done! You can now run 'stow' to create symlinks."
    echo "  Example: cd $DOTFILES_DIR/home && stow -v -t ~ *"
fi
