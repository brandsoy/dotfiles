# ~/.zshenv
# Sourced for every zsh session (interactive, non-interactive, scripts)

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
