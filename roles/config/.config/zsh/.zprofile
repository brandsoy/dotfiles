# Login-only integrations. Common environment and unique PATH live in .zshenv.
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

if [[ -n "${HOMEBREW_PREFIX:-}" && -d "$HOMEBREW_PREFIX/opt/libpq/bin" ]]; then
  path=("$HOMEBREW_PREFIX/opt/libpq/bin" $path)
fi

for dir in "$HOME/.tsp/bin" "$HOME/.opencode/bin" "$HOME/.aspire/bin" \
  "$HOME/.omlx/bin" "$HOME/.hermes/node/bin"; do
  [[ -d "$dir" ]] && path=("$dir" $path)
done
unset dir

if [[ "$OSTYPE" == linux* ]]; then
  [[ -d "$HOME/.cargo/bin" ]] && path=("$HOME/.cargo/bin" $path)
  export XDG_DATA_DIRS="${XDG_DATA_DIRS:-/usr/local/share:/usr/share}:/var/lib/flatpak/exports/share:$XDG_DATA_HOME/flatpak/exports/share"
  export MESA_LOG_LEVEL=error
  export QT_QPA_PLATFORMTHEME=qt5ct
else
  [[ -d /Applications/Obsidian.app/Contents/MacOS ]] && path+=(/Applications/Obsidian.app/Contents/MacOS)
  [[ -r "$HOME/.orbstack/shell/init.zsh" ]] && source "$HOME/.orbstack/shell/init.zsh"
fi

# Keep user binaries and mise-managed tools ahead of Homebrew dependencies.
path=("$HOME/.local/bin" "$XDG_DATA_HOME/mise/shims" "$PNPM_HOME" "$PNPM_HOME/bin" $path)
