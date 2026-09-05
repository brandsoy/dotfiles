# History and completion caches are local state, not dotfiles.
mkdir -p "$XDG_STATE_HOME/zsh" "$XDG_CACHE_HOME/zsh"
HISTFILE="$XDG_STATE_HOME/zsh/history"
HISTSIZE=100000
SAVEHIST=100000
setopt APPEND_HISTORY SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE
setopt HIST_EXPIRE_DUPS_FIRST HIST_FIND_NO_DUPS
setopt AUTOCD NOBEEP NUMERIC_GLOB_SORT

[[ -t 0 ]] && export GPG_TTY="$(tty)"
if (( $+commands[bat] )); then
  export MANPAGER='bat -l man -p'
fi

if (( $+commands[zoxide] )); then
  eval "$(zoxide init zsh)"
fi

autoload -Uz compinit
fpath=("$ZDOTDIR/completion" $fpath)
compinit -d "$XDG_CACHE_HOME/zsh/zcompdump"
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

source "$ZDOTDIR/fzf.zsh"
export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship.toml"
# Legacy fallback preserves existing installs until the first theme-sync command.
_theme_env="$XDG_STATE_HOME/theme-sync/current.env"
[[ -r "$_theme_env" ]] || _theme_env="$XDG_CONFIG_HOME/theme-sync/current.env"
[[ -r "$_theme_env" ]] && source "$_theme_env"
unset _theme_env
[[ -n "${FZF_THEME_FILE:-}" && -r "$FZF_THEME_FILE" ]] && source "$FZF_THEME_FILE"
if (( $+commands[fzf] )); then
  source <(fzf --zsh)
fi

source "$ZDOTDIR/aliases.zsh"
source "$ZDOTDIR/bindings.zsh"
source "$ZDOTDIR/plugins.zsh"
source "$ZDOTDIR/prompt.zsh"
source "$ZDOTDIR/hooks.zsh"

# Machine-local credentials are deliberately untracked.
[[ -r "$ZDOTDIR/secrets.zsh" ]] && source "$ZDOTDIR/secrets.zsh"

# Activation stays last; shims are already available to noninteractive shells.
if (( $+commands[mise] )); then
  eval "$(mise activate zsh)"
fi
