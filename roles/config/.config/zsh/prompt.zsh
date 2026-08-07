# Prevent Python virtualenv from polluting the prompt
export VIRTUAL_ENV_DISABLE_PROMPT=1

# Let theme-sync select the active Starship palette/config.
[[ -r "$HOME/.config/theme-sync/current.env" ]] && source "$HOME/.config/theme-sync/current.env"

eval "$(starship init zsh)"
