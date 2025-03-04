
# --- Zsh Configuration ---

# Enable prompt substitution
setopt prompt_subst

# Completion configuration
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
autoload bashcompinit && bashcompinit
autoload -Uz compinit
compinit

# --- Environment Variables ---

# GPG Configuration
if [ -n "$TTY" ]; then
  export GPG_TTY=$(tty)
else
  export GPG_TTY="$TTY"
fi
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent

# PATH Configuration
export PATH="$HOME/.go/bin:$PATH"
export PATH="$PATH:$HOME/go/bin"
export PNPM_HOME="$HOME/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Default editor
export EDITOR=nvim

# --- Tool Initializations ---

# Homebrew
if [[ -f "/opt/homebrew/bin/brew" ]]; then
  eval "$($(brew --prefix)/bin/brew shellenv)"
fi

# Starship prompt
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
eval "$(starship init zsh)"

# FZF Integration
eval "$(fzf --zsh)"
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow'
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Zoxide (better cd)
eval "$(zoxide init zsh)"
alias cd="z"

# Mise (formerly RTX)
eval "$(mise activate zsh)"

# --- Zinit Configuration ---

ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "$ZINIT_HOME/zinit.zsh"

# Plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::command-not-found

# Tools
zinit ice wait"2" as"command" from"gh-r" lucid mv"zoxide*/zoxide -> zoxide" atclone"./zoxide init zsh > init.zsh" atpull"%atclone" src"init.zsh" nocompile
zinit light ajeetdsouza/zoxide
zinit ice wait"0" lucid from"gh-r" as"command" mv"mise* -> mise" atclone"./mise activate zsh > init.zsh" atpull"%atclone" src"init.zsh" atload'eval "$(mise activate zsh)"'
zinit light jdx/mise
zinit cdreplay -q

# --- Keybindings ---
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region
zle_highlight+=(paste:none)

# --- History Configuration ---
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory sharehistory hist_ignore_space hist_ignore_all_dups hist_save_no_dups hist_ignore_dups hist_find_no_dups

# --- Aliases ---
alias l='eza -l --icons --git -a'
alias lt='eza --tree --level=2 --long --icons --git'
alias ltree='eza --tree --level=2 --icons --git'
alias vim='nvim'
alias c='clear'
alias ..='cd ..'
alias ...='cd ...'
alias nf='nvim $(fzf --preview="bat --color=always {}")'
alias ld='lazydocker'
alias lg='lazygit'

# --- Custom Functions ---
cx() { cd "$@" && l; }
fcd() { cd "$(find . -type d -not -path '*/.*' | fzf)" && l; }
f() { echo "$(find . -type f -not -path '*/.*' | fzf)" | pbcopy; }
fv() { nvim "$(find . -type f -not -path '*/.*' | fzf)"; }

# --- Bun Completions ---
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# End of Configuration
