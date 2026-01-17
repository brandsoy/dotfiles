# ~/.bashrc

# Comments
#
# install bash completions brew install bash-completion@2
# 
# Add ~/.bash_profile
# [[ -f ~/.bashrc ]] && source ~/.bashrc

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

# --- Shell behaviour ------------------------------------------------------
# Bash-specific options
shopt -s histappend
shopt -s checkwinsize
shopt -s globstar 2>/dev/null
shopt -s cmdhist

# Emacs keybindings
set -o emacs
bind '"\C-p": history-search-backward'
bind '"\C-n": history-search-forward'
bind '"\ew": kill-region'

HISTSIZE=10000
HISTFILESIZE=20000
HISTFILE="${HISTFILE:-$HOME/.bash_history}"
HISTCONTROL=ignoredups:ignorespace
HISTTIMEFORMAT="%F %T "

# --- Prompt ---------------------------------------------------------------
if command -v starship &>/dev/null; then
  eval "$(starship init bash)"
fi

# --- Completion setup -----------------------------------------------------
if ! shopt -oq posix; then
  if [[ -f /usr/share/bash-completion/bash_completion ]]; then
    . /usr/share/bash-completion/bash_completion
  elif [[ -f /etc/bash_completion ]]; then
    . /etc/bash_completion
  fi
  
  # Homebrew bash-completion (macOS)
  if command -v brew &>/dev/null; then
    BASH_COMPLETION_PREFIX="$(brew --prefix)/etc/bash_completion.d"
    if [[ -r "${BASH_COMPLETION_PREFIX}/bash_completion" ]]; then
      . "${BASH_COMPLETION_PREFIX}/bash_completion"
    fi
    unset BASH_COMPLETION_PREFIX
  fi
fi

# Case-insensitive completion
bind 'set completion-ignore-case on'
bind 'set show-all-if-ambiguous on'
bind 'set colored-stats on'
bind 'set visible-stats on'
bind 'set mark-symlinked-directories on'
bind 'set colored-completion-prefix on'
bind 'set menu-complete-display-prefix on'

# --- Aliases & helpers ----------------------------------------------------
alias ls='ls --color=auto'
alias l='ls -lah --color=auto'
alias c='clear'
alias ld='lazydocker'
alias lg='lazygit'
alias v='nvim'
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
  builtin cd "$dir" || return
}

fh() {
  history | fzf --tac --no-sort --prompt='  ' --header='Command History'
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
if command -v fzf &>/dev/null; then
  eval "$(fzf --bash)"
fi

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
  NVM_COMPLETION="$(brew --prefix nvm 2>/dev/null)/etc/bash_completion.d/nvm"
  [[ -s "$NVM_SH" ]] && source "$NVM_SH"
  [[ -s "$NVM_COMPLETION" ]] && source "$NVM_COMPLETION"
  unset NVM_SH NVM_COMPLETION
fi

if command -v mise &>/dev/null; then
  eval "$(mise activate bash)"
fi

# --- Homebrew & Paths -----------------------------------------------------
[[ -x "/opt/homebrew/bin/brew" ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
path_prepend "$HOME/Library/pnpm"
if command -v brew &>/dev/null; then
  LIBPQ_BIN="$(brew --prefix libpq 2>/dev/null)/bin"
  path_prepend "$LIBPQ_BIN"
  unset LIBPQ_BIN
else
  path_prepend "/usr/local/opt/libpq/bin"
fi

# --- Local tool paths -----------------------------------------------------
path_prepend "$HOME/.tsp/bin"
path_prepend "$HOME/.opencode/bin"
path_append "$HOME/.cargo/bin"

# --- API keys -------------------------------------------------------------
# export GEMINI_API_KEY="${GEMINI_API_KEY:-AIzaSyAK1EWAqybtchh-k5uNCmWvnSIRhUqJcgc}"
