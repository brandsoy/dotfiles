# # ~/.config/zsh/.zshenv

# ---------- XDG base directories ----------
# Centralizes config/cache/data locations
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# ---------- AI model storage ----------
# One source of truth. Override this before starting a shell when using an
# external SSD, for example: AI_MODELS_HOME=/Volumes/Models/Models.
export AI_MODELS_HOME="${AI_MODELS_HOME:-$HOME/Models}"

# Keep native framework layouts under the same root. HF/MLX share the
# Hugging Face cache; Ollama's blobs are separate because they are GGUF and
# are not interchangeable with safetensors.
export HF_HOME="$AI_MODELS_HOME/huggingface"
export HF_HUB_CACHE="$HF_HOME/hub"
export HUGGINGFACE_HUB_CACHE="$HF_HUB_CACHE" # older huggingface_hub clients
export TRANSFORMERS_CACHE="$HF_HUB_CACHE"    # older Transformers clients
export OLLAMA_MODELS="$AI_MODELS_HOME/ollama"

# --- Path helpers -----------------------------------------------------------
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

# --- Editor -----------------------------------------------------------------
export EDITOR=nvim
export VISUAL=nvim

# ---------- Pager ----------
if command -v bat >/dev/null 2>&1; then
  export MANPAGER="bat -l man -p"
elif command -v batcat >/dev/null 2>&1; then
  export MANPAGER="batcat -l man -p"
fi

# ---------- GPG ----------
export GPG_TTY=$(tty)

# ---------- Starship ----------
export STARSHIP_CONFIG="$ZDOTDIR/starship.toml"


# ---------- PATH ----------
# Personal binaries/scripts
export PATH="$HOME/.local/bin:$PATH"


# ------- ZSH CONFIG DIR -------
export ZDOTDIR="$HOME/.config/zsh"
