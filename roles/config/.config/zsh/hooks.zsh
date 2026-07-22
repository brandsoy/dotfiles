# Automatically run ls when changing directories
autoload -Uz add-zsh-hook
auto_ls_on_cd() {
    emulate -L zsh
    la
}
add-zsh-hook chpwd auto_ls_on_cd

# Homebrew syncing now happens via the ~/.local/bin/brew shim.
# That keeps Brewfile updates working in both interactive shells and scripts,
# as long as ~/.local/bin is ahead of the real Homebrew binary in PATH.
