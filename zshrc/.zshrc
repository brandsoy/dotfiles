# ~/.zshrc

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname "$ZINIT_HOME")"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
if [ -f "${ZINIT_HOME}/zinit.zsh" ]; then # Check if zinit.zsh exists
    source "${ZINIT_HOME}/zinit.zsh"
else
    echo "Zinit not found at ${ZINIT_HOME}/zinit.zsh. Please check your installation."
    return 1 # Optional: exit if zinit is critical
fi

# Add in Powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add in snippets
zinit snippet OMZL::git.zsh
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::command-not-found

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[ ! -f ~/.p10k.zsh ] || source ~/.p10k.zsh

# ~/.zshrc history configuration
# Keybindings
bindkey -e # Use Emacs keybindings (ensure this is set)
bindkey '^p' history-beginning-search-backward  # Search backward based on prefix
bindkey '^n' history-beginning-search-forward   # Search forward based on prefix
bindkey '^[w' kill-region                      # Your existing binding (Alt+W or Esc+W)

# History settings
HISTSIZE=10000                 # Number of lines kept in memory per session
SAVEHIST=10000                 # Number of lines saved to the history file
HISTFILE=~/.zsh_history        # Location of history file

setopt appendhistory           # Append to the history file, don't overwrite
setopt extended_history        # Record timestamp and duration
setopt hist_expire_dups_first  # Expire duplicates first when trimming history
setopt hist_ignore_dups        # Ignore immediately consecutive duplicates
setopt hist_ignore_space       # Ignore commands starting with space
setopt hist_verify             # Show history expansion before executing
setopt inc_append_history      # Append commands to history file immediately
setopt share_history           # Share history between running shells (implies inc_append_history and appendhistory)
setopt hist_find_no_dups       # Skip duplicates when searching
# Optional: Remove superfluous blanks before saving
# setopt hist_reduce_blanks

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Aliases
# Prefer 'ls -G' on macOS if 'ls --color' is not available or for BSD ls
# However, GNU coreutils (often installed via Homebrew) provides 'ls --color'
alias ls='ls --color=auto' # --color=auto is generally safer
alias l='ls -la --color=auto'
alias c='clear'
alias ld='lazydocker'
alias lg='lazygit'
alias vim='nvim'
alias vf='nvim $(fzf --preview="bat --color=always {}")'

# FZF Snacks
# Fuzzy file search (CTRL-T replacement)
alias ff="fd --type f --hidden --exclude .git | fzf --preview 'bat --color=always {}'" # fd needs to be installed

# Directory navigation (ALT-C replacement)
# Ensure 'find' and 'fzf' are available. 'tree' for preview.
alias fdnav="cd \$(find * -maxdepth 1 -type d 2>/dev/null | fzf --height 40% --reverse --preview 'tree -C {}' 2>/dev/null || echo .)"


# Command history search (CTRL-R replacement)
alias fh="history | fzf --tac --no-sort --prompt='  ' --header='Command History'"

# Fuzzy git log browser
alias fgl="git log --oneline --graph --color=always | fzf --ansi --preview 'git show --color=always {1}'"

# Git branch selector
alias fgb="git branch --all | fzf --header 'Switch Branch' | xargs git checkout"

# Fuzzy kill process
alias fkill="ps -ef | fzf --header='Kill Process' | awk '{print \$2}' | xargs kill"

# Shell integrations (Generic - should work if tools are in PATH)
if command -v fzf &>/dev/null; then
  eval "$(fzf --zsh)"
fi
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init --cmd cd zsh)"
fi

# Go PATH setup
if command -v go &>/dev/null; then
  export GOPATH="$(go env GOPATH 2>/dev/null || echo "$HOME/go")" # Fallback if go env GOPATH fails
  if [ -d "$GOPATH/bin" ]; then
    export PATH="$PATH:$GOPATH/bin"
  fi
fi


# NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
  \. "$NVM_DIR/nvm.sh"  # This loads nvm
  if [ -s "$NVM_DIR/bash_completion" ]; then # NVM also provides bash completion which zsh can use
    \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
  fi
fi

# mise (formerly rtx)
if command -v mise &>/dev/null; then
  eval "$(mise activate zsh)"
fi


# OS-Specific Configurations
if [[ "$(uname)" == "Darwin" ]]; then
  # macOS-specific settings

  # Homebrew for macOS
  if [[ -f "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi

  # PNPM for macOS (using user's specific Library path)
  PNPM_HOME_MAC="/Users/mattis/Library/pnpm"
  if [ -d "$PNPM_HOME_MAC" ]; then
    export PNPM_HOME="$PNPM_HOME_MAC"
    case ":$PATH:" in
      *":$PNPM_HOME:"*) ;;
      *) export PATH="$PNPM_HOME:$PATH" ;;
    esac
  fi
  unset PNPM_HOME_MAC


  # PostgreSQL (from Homebrew on macOS)
  LIBPQ_BIN_MAC="/usr/local/opt/libpq/bin" # Common path, but can vary
  # More robust check for brew's libpq path
  if command -v brew &>/dev/null && brew --prefix libpq &>/dev/null; then
    LIBPQ_BIN_MAC_BREW="$(brew --prefix libpq)/bin"
    if [ -d "$LIBPQ_BIN_MAC_BREW" ]; then
        export PATH="$LIBPQ_BIN_MAC_BREW:$PATH"
    fi
    unset LIBPQ_BIN_MAC_BREW
  elif [ -d "$LIBPQ_BIN_MAC" ]; then # Fallback to common hardcoded path
    export PATH="$LIBPQ_BIN_MAC:$PATH"
  fi
  unset LIBPQ_BIN_MAC


elif [[ "$(uname)" == "Linux" ]]; then
  # Linux-specific settings

  # Homebrew for Linux (Linuxbrew)
  if [[ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi

  # PNPM for Linux (uses XDG_DATA_HOME or default ~/.local/share/pnpm)
  PNPM_HOME_LINUX="${XDG_DATA_HOME:-$HOME/.local/share}/pnpm"
  if [ -d "$PNPM_HOME_LINUX" ]; then
    export PNPM_HOME="$PNPM_HOME_LINUX"
    case ":$PATH:" in
      *":$PNPM_HOME:"*) ;;
      *) export PATH="$PNPM_HOME:$PATH" ;;
    esac
  fi
  unset PNPM_HOME_LINUX
fi # End of OS-specific block

# Any other generic settings can go here

# Ensure PATH does not have duplicates (optional, can be slow on each prompt)
# typeset -U path # This is zsh specific and efficient
# path=($path)    # Rebuilds path array removing duplicates

# Final check for p10k prompt
if command -v p10k &>/dev/null; then
    p10k reload &>/dev/null # Reload p10k if it's already configured, handles changes
fi

# TypeSpec
TYPESPEC_PATH="/Users/mattis/.tsp/bin"
if [ -d "$TYPESPEC_PATH" ]; then
  export PATH="/Users/mattis/.tsp/bin:$PATH"
fi

export GEMINI_API_KEY="AIzaSyAK1EWAqybtchh-k5uNCmWvnSIRhUqJcgc"

# opencode
export PATH=/home/mattis/.opencode/bin:$PATH
