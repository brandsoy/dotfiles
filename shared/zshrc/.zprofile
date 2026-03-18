# ~/.zprofile
# Sourced once at login shell startup (before .zshrc)
# Path helpers are available from .zshenv

# --- Homebrew & Paths -------------------------------------------------------
# Try Apple Silicon path first, then Intel
if [[ -x "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x "/usr/local/bin/brew" ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# LibPQ
if command -v brew &>/dev/null; then
  LIBPQ_BIN="$(brew --prefix libpq 2>/dev/null)/bin"
  [[ -d "$LIBPQ_BIN" ]] && path_prepend "$LIBPQ_BIN"
  unset LIBPQ_BIN
elif [[ -d "/usr/local/opt/libpq/bin" ]]; then
  path_prepend "/usr/local/opt/libpq/bin"
fi

# --- Local tool paths -------------------------------------------------------
path_prepend "$HOME/.tsp/bin"
path_prepend "$HOME/.opencode/bin"
path_prepend "$HOME/.aspire/bin"

# --- pnpm -------------------------------------------------------------------
if [[ "$OSTYPE" == "darwin"* ]]; then
  export PNPM_HOME="$HOME/Library/pnpm"
else
  export PNPM_HOME="$HOME/.local/share/pnpm"
fi
path_prepend "$PNPM_HOME"

# --- OS-specific (Linux only) -----------------------------------------------
if [[ "$OSTYPE" == linux* ]]; then
  path_prepend "$HOME/.local/bin"
  path_prepend "$HOME/.opencode/bin"
  path_prepend "$HOME/.cargo/bin"
  export XDG_DATA_DIRS="$XDG_DATA_DIRS:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share"
  export MESA_LOG_LEVEL=error
  export QT_QPA_PLATFORMTHEME=qt5ct
fi

# Added by Obsidian
path_append "/Applications/Obsidian.app/Contents/MacOS"
