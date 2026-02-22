# ~/.zshrc

# --- Path helpers ---------------------------------------------------------
function path_prepend {
  local dir="$1"
  [[ -n "$dir" && -d "$dir" ]] || return
  case ":$PATH:" in
    *":$dir:"*) ;; # Skip if already in PATH
    *) PATH="$dir:$PATH" ;;
  esac
}

function path_append {
  local dir="$1"
  [[ -n "$dir" && -d "$dir" ]] || return
  case ":$PATH:" in
    *":$dir:"*) ;; # Skip if already in PATH
    *) PATH="$PATH:$dir" ;;
  esac
}

typeset -U PATH path

# --- Homebrew & Paths -----------------------------------------------------
# Try Apple Silicon path first, then Intel
if [[ -x "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x "/usr/local/bin/brew" ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

path_prepend "$HOME/.local/share/pnpm"
path_prepend "$HOME/Library/pnpm"

# LibPQ check after brew might be in path
if command -v brew &>/dev/null; then
  LIBPQ_BIN="$(brew --prefix libpq 2>/dev/null)/bin"
  [[ -d "$LIBPQ_BIN" ]] && path_prepend "$LIBPQ_BIN"
  unset LIBPQ_BIN
elif [[ -d "/usr/local/opt/libpq/bin" ]]; then
  path_prepend "/usr/local/opt/libpq/bin"
fi

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
  # Fail silently or log if non-interactive?
  # printf 'zinit: unable to source %s/zinit.zsh\n' "$ZINIT_HOME" >&2
  return 1
fi

# --- Plugins (Turbo Mode) -------------------------------------------------
# Load completions and snippets asynchronously for faster startup
zinit ice wait lucid
zinit light zsh-users/zsh-completions

zinit ice wait lucid
zinit light zsh-users/zsh-autosuggestions

zinit ice wait lucid
zinit light Aloxaf/fzf-tab

zinit ice wait lucid
zinit snippet OMZL::git.zsh

zinit ice wait lucid
zinit snippet OMZP::git

zinit ice wait lucid
zinit snippet OMZP::sudo

zinit ice wait lucid if'[[ -f /etc/arch-release ]]'
zinit snippet OMZP::archlinux

zinit ice wait lucid
zinit snippet OMZP::command-not-found

# Syntax highlighting should load last, but in turbo mode, we ensure it wraps up nicely
zinit ice wait lucid atinit"zpcompinit; zicdreplay"
zinit light zsh-users/zsh-syntax-highlighting

# --- Completion System (Optimized) ----------------------------------------
autoload -Uz compinit
# Only regenerate compdump once a day
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# --- Prompt ---------------------------------------------------------------
if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
fi

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

if command -v mise &>/dev/null; then
  eval "$(mise activate zsh)"
fi

export EDITOR=nvim
export VISUAL=nvim

 #--- Shell behaviour ------------------------------------------------------
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

# --- Aliases & helpers ----------------------------------------------------
# Cross-platform ls color support & fzf-preview
if ls --color > /dev/null 2>&1; then
  alias ls='ls --color=auto'
  zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
  zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
else
  alias ls='ls -G'
  zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls -G $realpath'
  zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls -G $realpath'
fi

alias l='ls -lah'
alias c='clear'
alias ld='lazydocker'
alias lg='lazygit'
alias v='nvim'
alias vim='nvim'
alias ff="fd --type f --hidden --exclude .git | fzf --preview 'bat --color=always {}'"

# Clipboard aliases
if [[ "$OSTYPE" == "darwin"* ]]; then
  alias copy='pbcopy'
  alias paste='pbpaste'
elif command -v xclip &>/dev/null; then
  alias copy='xclip -selection clipboard'
  alias paste='xclip -selection clipboard -o'
elif command -v wl-copy &>/dev/null; then
  alias copy='wl-copy'
  alias paste='wl-paste'
fi

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

# --- Local tool paths -----------------------------------------------------
path_prepend "$HOME/.tsp/bin"
path_prepend "$HOME/.opencode/bin"

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# --- Print ip information ---------------------------------------------------
myip() {
    echo "----------------------------"
    local wan_ip=$(curl -s --max-time 2 ifconfig.co || echo "Offline")
    local lan_ip=""
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        local iface=$(route -n get default 2>/dev/null | awk '/interface: / {print $2}')
        [[ -n "$iface" ]] && lan_ip=$(ipconfig getifaddr "$iface")
    else
        # Linux / generic
        lan_ip=$(hostname -I 2>/dev/null | awk '{print $1}')
    fi

    echo "  WAN:  ${wan_ip}"
    echo "  LAN:  ${lan_ip:-'Not connected'}"
    echo "----------------------------"
}

# Only alias 'ip' to 'myip' on MacOS where 'ip' command is typically missing
if [[ "$OSTYPE" == "darwin"* ]]; then
    alias ip='myip'
fi
export PATH="/home/mattis/.local/bin:$PATH"

alias wifistat="watch -n 1 'iwctl station wlan0 show | grep -E \"(Connected BSSID|RSSI|Frequency|Tx-Rate)\"'"

# Make NMTUI greate again
# alias nmtui='NEWT_COLORS="root=lavender,crust border=sapphire,base window=overlay0,base title=rosewater,crust button=surface2,lavender button_active=crust,maroon" nmtui'   

# Lenovo x13 tweaks
export MESA_LOG_LEVEL=error
# Arch Dark Mode
export QT_QPA_PLATFORMTHEME=qt5ct

eval "$(/home/mattis/.local/bin/mise activate zsh)" # added by https://mise.run/zsh

# opencode
export PATH=/home/mattis/.opencode/bin:$PATH
export PATH=/home/mattis/.cargo/bin:$PATH
export XDG_DATA_DIRS=$XDG_DATA_DIRS:/var/lib/flatpak/exports/share:/home/$USER/.local/share/flatpak/exports/share
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/mattis/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions

# Added by get-aspire-cli.sh
export PATH="$HOME/.aspire/bin:$PATH"
