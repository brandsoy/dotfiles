# ~/.bashrc

# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source ~/.local/share/omarchy/default/bash/rc

# Add your own exports, aliases, and functions here.
#
# Make an alias for invoking commands you use constantly
# alias p='python'

# --- Path helpers ---------------------------------------------------------
path_prepend() {
  local dir="$1"
  [[ -n "$dir" && -d "$dir" ]] || return
  case ":$PATH:" in
    *":$dir:"*) ;;
    *) PATH="$dir:$PATH" ;;
  esac
}

path_append() {
  local dir="$1"
  [[ -n "$dir" && -d "$dir" ]] || return
  case ":$PATH:" in
    *":$dir:"*) ;;
    *) PATH="$PATH:$dir" ;;
  esac
}

append_prompt_command() {
  local cmd="$1"
  if [[ -z "$PROMPT_COMMAND" ]]; then
    PROMPT_COMMAND="$cmd"
  else
    PROMPT_COMMAND="$cmd;${PROMPT_COMMAND}"
  fi
}

# --- Shell behaviour ------------------------------------------------------
HISTSIZE=10000
HISTFILESIZE=20000
HISTFILE="${HISTFILE:-$HOME/.bash_history}"
HISTCONTROL=ignoreboth:erasedups

shopt -s histappend cmdhist lithist checkwinsize
shopt -s extglob progcomp
shopt -s histverify 2>/dev/null
append_prompt_command 'history -a; history -n'

# Readline bindings mirroring the zsh keybinds
bind -m emacs-standard '"\C-p": history-search-backward'
bind -m emacs-standard '"\C-n": history-search-forward'
bind -m emacs-standard '"\ee\C-w": kill-region'

# --- Prompt ---------------------------------------------------------------
if command -v starship &>/dev/null; then
  eval "$(starship init bash)"
fi

# --- fzf completion & key-bindings ----------------------------------------
if command -v fzf &>/dev/null; then
  eval "$(fzf --bash)"
fi

# --- Aliases & helpers ----------------------------------------------------
alias ls='ls --color=auto'
alias l='ls -lah --color=auto'
alias c='clear'
alias ld='lazydocker'
alias lg='lazygit'
alias vim='nvim'
alias ff="fd --type f --hidden --exclude .git | fzf --preview 'bat --color=always {}'"

vf() {
  local file
  file=$(fzf --preview 'bat --color=always {}') || return
  [[ -n "$file" ]] || return
  nvim "$file"
}

fdnav() {
  local dir
  dir=$(find . -maxdepth 1 -mindepth 1 -type d 2>/dev/null | sed 's|^\./||' | fzf --height 40% --reverse --preview 'tree -C {}' 2>/dev/null) || return
  [[ -n "$dir" ]] || return
  cd "$dir"
}

fh() {
  history | fzf --tac --no-sort --prompt='  ' --header='Command History'
}

fgl() {
  git log --oneline --graph --color=always | fzf --ansi --preview 'git show --color=always {1}'
}

fgb() {
  local branch
  branch=$(git branch --all | fzf --header 'Switch Branch') || return
  [[ -n "$branch" ]] || return
  git checkout "${branch##* }"
}

fkill() {
  local pid
  pid=$(ps -ef | fzf --header='Kill Process' | awk '{print $2}') || return
  [[ -n "$pid" ]] || return
  kill "$pid"
}

# --- Tool integrations ----------------------------------------------------
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init --cmd cd bash)"
fi

if command -v go &>/dev/null; then
  export GOPATH="$(go env GOPATH 2>/dev/null || printf '%s/go' "$HOME")"
  path_append "$GOPATH/bin"
fi

export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
if command -v brew &>/dev/null; then
  NVM_SH="$(brew --prefix nvm 2>/dev/null)/nvm.sh"
  [[ -s "$NVM_SH" ]] && source "$NVM_SH"
  unset NVM_SH
fi

if command -v mise &>/dev/null; then
  eval "$(mise activate bash)"
fi

# --- OS specific ----------------------------------------------------------
case "$(uname -s)" in
  Darwin)
    [[ -x "/opt/homebrew/bin/brew" ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
    path_prepend "/Users/mattis/Library/pnpm"
    if command -v brew &>/dev/null; then
      LIBPQ_BIN="$(brew --prefix libpq 2>/dev/null)/bin"
      path_prepend "$LIBPQ_BIN"
      unset LIBPQ_BIN
    else
      path_prepend "/usr/local/opt/libpq/bin"
    fi
    ;;
  Linux)
    [[ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    path_prepend "${XDG_DATA_HOME:-$HOME/.local/share}/pnpm"
    ;;
esac

# --- Local tool paths -----------------------------------------------------
path_prepend "/Users/mattis/.tsp/bin"
path_prepend "/home/mattis/.opencode/bin"
path_append "$HOME/.cargo/bin"
