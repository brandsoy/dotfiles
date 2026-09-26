export VIRTUAL_ENV_DISABLE_PROMPT=1
if (( $+commands[starship] )); then
  eval "$(starship init zsh)"
fi
