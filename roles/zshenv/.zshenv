# Environment needed by both interactive shells and scripts. No external commands.
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
# Stow places Zsh here, independently of other apps' XDG overrides.
export ZDOTDIR="$HOME/.config/zsh"

export EDITOR=nvim
export VISUAL=nvim

# Shared model location; frameworks retain their native storage layouts.
export AI_MODELS_HOME="${AI_MODELS_HOME:-$HOME/Models}"
export HF_HOME="$AI_MODELS_HOME/huggingface"
export HF_HUB_CACHE="$HF_HOME/hub"
export HUGGINGFACE_HUB_CACHE="$HF_HUB_CACHE"
export TRANSFORMERS_CACHE="$HF_HUB_CACHE"
export OLLAMA_MODELS="$AI_MODELS_HOME/ollama"

# Zsh keeps PATH and path in sync; preserve the first occurrence of each entry.
typeset -U path PATH
export PNPM_HOME="${PNPM_HOME:-$XDG_DATA_HOME/pnpm}"
path=("$HOME/.local/bin" "$XDG_DATA_HOME/mise/shims" "$PNPM_HOME" "$PNPM_HOME/bin" $path)
