# Automatically run ls when changing directories
auto_ls_on_cd() {
    emulate -L zsh
    la
}
add-zsh-hook chpwd auto_ls_on_cd
