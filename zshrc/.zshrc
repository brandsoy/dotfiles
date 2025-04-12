# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

if [[ -f "/opt/homebrew/bin/brew" ]] then
  # If you're using macOS, you'll want this enabled
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

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
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Aliases
alias ls='ls --color'
alias l='ls -la --color'
alias c='clear'
alias ld='lazydocker'
alias lg='lazygit'
alias vim='nvim'
alias vf='nvim $(fzf --preview="bat --color=always {}")'

# FZF Snacks
# Fuzzy file search (CTRL-T replacement)
# alias ff="fd --type f --hidden --exclude .git | fzf --preview 'bat --color=always {}'"

# Directory navigation (ALT-C replacement)
alias fd="cd \$(find * -type d | fzf --height 40% --reverse --preview 'tree -C {}')"

# Command history search (CTRL-R replacement)
alias fh="history | fzf --tac --no-sort --prompt='  ' --header='Command History'"

# Fuzzy git log browser
alias fgl="git log --oneline --graph --color=always | fzf --ansi --preview 'git show --color=always {1}'"

# Git branch selector
alias fgb="git branch --all | fzf --header 'Switch Branch' | xargs git checkout"

# Fuzzy kill process
alias fkill="ps -ef | fzf --header='Kill Process' | awk '{print \$2}' | xargs kill"

# Shell integrations
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"

# Add GOPATH to shell config (e.g., ~/.zshrc or ~/.bashrc)  
export GOPATH="$(go env GOPATH)"  
export PATH="$PATH:$GOPATH/bin"


# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/mattis/micromamba/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/mattis/micromamba/etc/profile.d/conda.sh" ]; then
        . "/Users/mattis/micromamba/etc/profile.d/conda.sh"
    else
        export PATH="/Users/mattis/micromamba/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

