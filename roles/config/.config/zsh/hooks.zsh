# Automatically run ls when changing directories
autoload -Uz add-zsh-hook
auto_ls_on_cd() {
    emulate -L zsh
    la
}
add-zsh-hook chpwd auto_ls_on_cd

# Keep the Brewfile in sync after package changes.
# Use `command brew` so we always call the real Homebrew binary.
brew_sync_brewfile() {
    emulate -L zsh

    local dotfiles_dir="${DOTFILES_DIR:-$HOME/dotfiles}"
    local brewfile="$dotfiles_dir/roles/packages-macos/Brewfile"
    local legacy_brewfile="$dotfiles_dir/homebrew/Brewfile"

    if [[ -f "$brewfile" ]]; then
        command brew bundle dump --force --file="$brewfile" >/dev/null
    elif [[ -f "$legacy_brewfile" ]]; then
        command brew bundle dump --force --file="$legacy_brewfile" >/dev/null
    fi
}

brew() {
    emulate -L zsh

    local subcommand="${1:-}"
    local sync_needed=0

    case "$subcommand" in
        install|uninstall|remove|tap|untap)
            sync_needed=1
            ;;
    esac

    command brew "$@"
    local status=$?

    if [[ $status -eq 0 && $sync_needed -eq 1 ]]; then
        brew_sync_brewfile
    fi

    return $status
}
