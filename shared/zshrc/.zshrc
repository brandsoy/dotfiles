# ~/.zshrc

# shellcheck shell=bash

# --- Homebrew wrapper -------------------------------------------------------
# Auto update Brewfile when installing or removing packages
brew() {
  command brew "$@" || return $?

  # Only run dump if the command was install, uninstall, or reinstall
  if [[ "$1" == "install" || "$1" == "uninstall" || "$1" == "remove" || "$1" == "rm" || "$1" == "reinstall" || "$1" == "upgrade" ]]; then
    echo "Updating Brewfile..."
    command brew bundle dump --force --file=~/dotfiles/homebrew/Brewfile
  fi
}

# --- Zinit bootstrap --------------------------------------------------------
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
  # shellcheck disable=SC1091
  source "${ZINIT_HOME}/zinit.zsh"
else
  return 1
fi

# --- Plugins (Turbo Mode) ---------------------------------------------------
# Load completions and snippets asynchronously for faster startup
zinit ice wait lucid
zinit light zsh-users/zsh-completions

zinit ice wait lucid
zinit light zsh-users/zsh-autosuggestions

zinit ice wait lucid
zinit light Aloxaf/fzf-tab

zinit ice wait lucid
zinit snippet OMZP::sudo

zinit ice wait lucid if '[[ -f /etc/arch-release ]]'
zinit snippet OMZP::archlinux

# Syntax highlighting should load last, but in turbo mode, we ensure it wraps up nicely
zinit ice wait lucid atinit"zpcompinit; zicdreplay"
zinit light zdharma-continuum/fast-syntax-highlighting

# --- Docker completions ------------------------------------------------------
if [[ -d "$HOME/.docker/completions" ]]; then
  fpath=("$HOME/.docker/completions" "${fpath[@]}")
fi

# --- Orbstack completions ------------------------------------------------------
if [[ -d "$HOME/.zsh/completions" ]]; then
  fpath=(~/.zsh/completion $fpath)
fi

if command -v brew >/dev/null 2>&1; then
  docker_site_functions="$(brew --prefix)/share/zsh/site-functions"
  if [[ -d "$docker_site_functions" ]]; then
    fpath=("$docker_site_functions" "${fpath[@]}")
  fi
fi

# --- Completion System (Optimized) ------------------------------------------
autoload -Uz compinit
# Only regenerate compdump once a day
compdump="${ZDOTDIR:-$HOME}/.zcompdump"
mtime=0
if [[ -f "$compdump" ]]; then
  mtime=$(stat -f %m "$compdump" 2>/dev/null || stat -c %Y "$compdump" 2>/dev/null || echo 0)
fi
now=$(date +%s)
age=$(( now - mtime ))

if [[ ! -f "$compdump" || $age -gt 86400 ]]; then
  compinit
else
  compinit -C
fi

# --- Prompt -----------------------------------------------------------------
if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
fi

# --- Tool integrations ------------------------------------------------------
if [[ -f "$HOME/.config/theme-sync/current.env" ]]; then
  # shellcheck disable=SC1091
  source "$HOME/.config/theme-sync/current.env"
fi

if command -v fzf &>/dev/null; then
  eval "$(fzf --zsh)"
  if [[ -n "$FZF_THEME_FILE" && -f "$FZF_THEME_FILE" ]]; then
    # shellcheck disable=SC1090
    source "$FZF_THEME_FILE"
  elif [[ -f "$HOME/.config/fzf/tokyonight_night.sh" ]]; then
    # shellcheck disable=SC1091
    source "$HOME/.config/fzf/tokyonight_night.sh"
  fi
fi

if command -v zoxide &>/dev/null; then
  eval "$(zoxide init --cmd cd zsh)"
fi

if command -v mise &>/dev/null; then
  eval "$(mise activate zsh)"
fi

# --- Shell behaviour --------------------------------------------------------
bindkey -e
## Vim Motions in terminal prompt
bindkey -v
export KEYTIMEOUT=1

bindkey '^p' history-beginning-search-backward
bindkey '^n' history-beginning-search-forward
bindkey '^[w' kill-region

HISTSIZE=10000
# shellcheck disable=SC2034
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

# --- Completion styling -----------------------------------------------------
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
# shellcheck disable=SC2296
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no

# --- Aliases & helpers ------------------------------------------------------
# Cross-platform ls color support & fzf-preview
if ls --color > /dev/null 2>&1; then
  alias ls='ls --color=auto'
  # shellcheck disable=SC2016
  zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
  # shellcheck disable=SC2016
  zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
else
  alias ls='ls -G'
  # shellcheck disable=SC2016
  zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls -G $realpath'
  # shellcheck disable=SC2016
  zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls -G $realpath'
fi

alias l='ls -lah'
alias c='clear'
alias ld='lazydocker'
alias lg='lazygit'
alias theme-sync='$HOME/.config/theme-sync/theme-sync'
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

# --- Print ip information ---------------------------------------------------
myip() {
    echo "----------------------------"
    local wan_ip
    wan_ip=$(curl -s --max-time 2 ifconfig.co || echo "Offline")
    local lan_ip=""

    if [[ "$OSTYPE" == "darwin"* ]]; then
        local iface
        iface=$(route -n get default 2>/dev/null | awk '/interface: / {print $2}')
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

# --- OS-specific (Linux only) -----------------------------------------------
if [[ "$OSTYPE" == linux* ]]; then
  alias wifistat="watch -n 1 'iwctl station wlan0 show | grep -E \"(Connected BSSID|RSSI|Frequency|Tx-Rate)\"'"
fi


# --- Set Nvim as default editor ------------------------------------------------
export EDITOR='nvim'
export VISUAL='nvim'

# --- YAZI shell wrapper -----------------------------------------------------
function y() {
	local tmp
	local cwd
	tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	if [ "$cwd" != "$PWD" ] && [ -d "$cwd" ]; then
		builtin cd -- "$cwd" || return
	fi
	rm -f -- "$tmp"
}

# Added by get-aspire-cli.sh
export PATH="$HOME/.aspire/bin:$PATH"

# Local test vars
export E2E_USERNAME="super@user.com"
export E2E_PASSWORD="superuser"

# Force Ollama to use the M5's high-bandwidth MLX path
export OLLAMA_FLASH_ATTENTION=1
# Allow the M5 to handle 4 parallel agentic streams
export OLLAMA_NUM_PARALLEL=4
# Set the default context high enough for modern codebases
export OLLAMA_CONTEXT_LENGTH=32768
# Keep the model loaded in the M5's unified memory (-1 = forever)
export OLLAMA_KEEP_ALIVE="-1"

#compdef opencode
###-begin-opencode-completions-###
#
# yargs command completion script
#
# Installation: opencode completion >> ~/.zshrc
#    or opencode completion >> ~/.zprofile on OSX.
#
_opencode_yargs_completions()
{
  local reply
  local si=$IFS
  IFS=$'
' reply=($(COMP_CWORD="$((CURRENT-1))" COMP_LINE="$BUFFER" COMP_POINT="$CURSOR" opencode --get-yargs-completions "${words[@]}"))
  IFS=$si
  if [[ ${#reply} -gt 0 ]]; then
    _describe 'values' reply
  else
    _default
  fi
}
if [[ "'${zsh_eval_context[-1]}" == "loadautofunc" ]]; then
  _opencode_yargs_completions "$@"
else
  compdef _opencode_yargs_completions opencode
fi
###-end-opencode-completions-###

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/mattis/.lmstudio/bin"
# End of LM Studio CLI section

