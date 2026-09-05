# Keep a partially installed shell usable.
if (( $+commands[eza] )); then
  alias ls='eza --icons'
  alias ll='eza -lh --icons --git'
  alias la='eza -lah --icons --git'
  alias tree='eza --tree --icons'
  compdef eza=ls
else
  alias ll='ls -lh'
  alias la='ls -lah'
fi

(( $+commands[bat] )) && alias cat='bat'

# =========================================================
# Core utilities
# =========================================================

# Apple Silicon-aware system summary (configured in ~/.config/fastfetch)
alias ff='fastfetch'

# Keep grep/diff semantics portable; use rg explicitly.
alias df='df -h'

# =========================================================
# Navigation
# =========================================================

alias -- -='cd -'  # -- prevents - being parsed as a flag; cd - jumps to previous directory

# =========================================================
# Editor
# =========================================================

alias v='nvim'
alias vim='nvim'

# =========================================================
# Git
# =========================================================

alias glog='PAGER="less -F -X" git log'                              # -F quit if one screen, -X no clear on exit
alias gadog='PAGER="less -F -X" git log --all --decorate --oneline --graph'
alias lg='lazygit'

# =========================================================
# Docker
# =========================================================
alias ld='lazydocker'

# =========================================================
# Searching
# =========================================================
function fv {
  local file
  file=$(fzf --preview 'bat --color=always {}') || return
  [[ -n "$file" ]] || return
  nvim "$file"
}

function fdnav {
  local dir
  dir=$(find . -maxdepth 1 -mindepth 1 -type d 2>/dev/null | sed 's|^\./||' | fzf --height 40% --reverse --preview 'tree -C {}' 2>/dev/null) || return
  [[ -n "$dir" ]] || return
  builtin cd "$dir" || return
}

function fh {
  history | fzf --tac --no-sort --prompt='  ' --header='Command History'
}

function fgl {
  git log --oneline --graph --color=always | fzf --ansi --preview 'git show --color=always {1}'
}

function fgb {
  local branch
  branch=$(git branch --all | fzf --header 'Switch Branch') || return
  [[ -n "$branch" ]] || return
  git checkout "${branch##* }"
}

function fkill {
  local pid
  pid=$(ps -ef | fzf --header='Kill Process' | awk '{print $2}') || return
  [[ -n "$pid" ]] || return
  kill "$pid"
}


