# ~/.zshrc

# --- Path helpers ---------------------------------------------------------
function path_prepend {
  local dir="$1"
  [[ -n "$dir" && -d "$dir" ]] || return
  case ":$PATH:" in
    *":$dir:"*) ;;
    *) PATH="$dir:$PATH" ;;
  esac
}

function path_append {
  local dir="$1"
  [[ -n "$dir" && -d "$dir" ]] || return
  case ":$PATH:" in
    *":$dir:"*) ;;
    *) PATH="$PATH:$dir" ;;
  esac
}

typeset -U PATH path

# --- Zinit bootstrap ------------------------------------------------------
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME" ]]; then
  if command -v git &>/dev/null; then
    mkdir -p "$(dirname "$ZINIT_HOME")"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
  else
    printf 'zinit: git not available, skipping installation.\n' >&2
  fi
fi

if [[ -f "${ZINIT_HOME}/zinit.zsh" ]]; then
  source "${ZINIT_HOME}/zinit.zsh"
else
  printf 'zinit: unable to source %s/zinit.zsh\n' "$ZINIT_HOME" >&2
  return 1
fi

# Plugins & snippets
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab
zinit snippet OMZL::git.zsh
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::command-not-found

autoload -Uz compinit && compinit
zinit cdreplay -q

# Prompt
if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
fi

# --- Shell behaviour ------------------------------------------------------
bindkey -e
bindkey '^p' history-beginning-search-backward
bindkey '^n' history-beginning-search-forward
bindkey '^[w' kill-region

HISTSIZE=10000
SAVEHIST=10000
HISTFILE="${HISTFILE:-$HOME/.zsh_history}"

setopt appendhistory
setopt extended_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_verify
setopt inc_append_history
setopt share_history
setopt hist_find_no_dups

# --- Completion styling ---------------------------------------------------
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# --- Aliases & helpers ----------------------------------------------------
alias ls='ls --color=auto'
alias l='ls -lah --color=auto'
alias c='clear'
alias ld='lazydocker'
alias lg='lazygit'
alias v='nvim'
alias vim='nvim'
alias ff="fd --type f --hidden --exclude .git | fzf --preview 'bat --color=always {}'"

function vf {
  local file
  file=$(fzf --preview 'bat --color=always {}') || return
  [[ -n "$file" ]] || return
  nvim "$file"
}

function fdnav {
  local dir
  dir=$(find . -maxdepth 1 -mindepth 1 -type d 2>/dev/null | sed 's|^\./||' | fzf --height 40% --reverse --preview 'tree -C {}' 2>/dev/null) || return
  [[ -n "$dir" ]] || return
  builtin cd "$dir"
}

function fh {
  history | fzf --tac --no-sort --prompt='  ' --header='Command History'
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

# --- Tool integrations ----------------------------------------------------
if command -v fzf &>/dev/null; then
  eval "$(fzf --zsh)"
fi

if command -v zoxide &>/dev/null; then
  eval "$(zoxide init --cmd cd zsh)"
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
  eval "$(mise activate zsh)"
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

# --- API keys -------------------------------------------------------------
# export GEMINI_API_KEY="${GEMINI_API_KEY:-AIzaSyAK1EWAqybtchh-k5uNCmWvnSIRhUqJcgc}"

# bun completions
[ -s "/Users/mattis/.bun/_bun" ] && source "/Users/mattis/.bun/_bun"
