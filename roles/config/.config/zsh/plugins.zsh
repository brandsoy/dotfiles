# =========================================================
# Plugins
# =========================================================

ZPLUGINDIR="${ZDOTDIR:-$HOME/.config/zsh}/plugins"

_zplugin_load() {
  setopt local_options null_glob

  local owner="$1"
  local repo="$2"
  local plugin_path="${ZPLUGINDIR}/${repo}"

  mkdir -p "$ZPLUGINDIR"

  if [[ ! -d "$plugin_path" ]]; then
    echo "Installing ${repo}..."
    git clone --depth=1 "https://github.com/${owner}/${repo}" "$plugin_path" \
      || { echo "ERROR: failed to install ${repo}" >&2; return 1; }
  fi

  # Support common entrypoint naming conventions used by zsh plugins.
  local entry
  for entry in \
    "${plugin_path}/${repo}.plugin.zsh" \
    "${plugin_path}/${repo}.zsh" \
    "${plugin_path}/${repo}.sh" \
    "${plugin_path}"/*.plugin.zsh \
    "${plugin_path}"/*.zsh; do
    [[ -f "$entry" ]] || continue
    source "$entry"
    return 0
  done

  # Self-heal broken/empty plugin dirs (common after interrupted clone).
  echo "Reinstalling ${repo} (missing loadable script)..."
  rm -rf "$plugin_path"
  git clone --depth=1 "https://github.com/${owner}/${repo}" "$plugin_path" \
    || { echo "ERROR: failed to reinstall ${repo}" >&2; return 1; }

  for entry in \
    "${plugin_path}/${repo}.plugin.zsh" \
    "${plugin_path}/${repo}.zsh" \
    "${plugin_path}/${repo}.sh" \
    "${plugin_path}"/*.plugin.zsh \
    "${plugin_path}"/*.zsh; do
    [[ -f "$entry" ]] || continue
    source "$entry"
    return 0
  done

  echo "ERROR: no loadable script found for ${repo} in ${plugin_path}" >&2
  return 1
}

zplugin-update() {
  local dir
  for dir in "${ZPLUGINDIR}"/*/; do
    echo "Updating ${dir:t}..."
    git -C "$dir" pull --ff-only
  done
}

_zplugin_load zsh-users zsh-autosuggestions
_zplugin_load zsh-users zsh-history-substring-search
_zplugin_load jeffreytse zsh-vi-mode
_zplugin_load zdharma-continuum fast-syntax-highlighting
