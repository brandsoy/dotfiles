# Pinned submodules; install/update them explicitly with dotfiles-install plugins.
# Shell startup never downloads, updates, or removes plugins.
ZPLUGINDIR="$ZDOTDIR/plugins"
for plugin in zsh-autosuggestions zsh-history-substring-search zsh-vi-mode; do
  entry="$ZPLUGINDIR/$plugin/$plugin.zsh"
  [[ -r "$entry" ]] && source "$entry"
done
unset plugin entry

# Keep syntax highlighting after other ZLE plugins.
if (( $+commands[zsh-patina] )); then
  eval "$(zsh-patina activate)"
fi
