#!/usr/bin/env bash
set -euo pipefail

CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -n "${THEME_SYNC_ROOT:-}" ]]; then
  ROOT="$THEME_SYNC_ROOT"
elif [[ -d "$CONFIG_HOME/theme-sync/themes" ]]; then
  ROOT="$CONFIG_HOME/theme-sync"
else
  ROOT="$SCRIPT_DIR/../roles/config/.config/theme-sync"
fi

THEMES_DIR="$ROOT/themes"
STATE_DIR="$STATE_HOME/theme-sync"
CURRENT_FILE="$STATE_DIR/current"
CURRENT_ENV_FILE="$STATE_DIR/current.env"
MODE_ENV_FILE="$STATE_DIR/mode.env"


TARGET_GHOSTTY="$CONFIG_HOME/ghostty/auto/theme.ghostty"
TARGET_ALACRITTY="$CONFIG_HOME/alacritty/auto/theme.toml"
TARGET_KITTY="$CONFIG_HOME/kitty/auto/theme.conf"
TARGET_BTOP="$CONFIG_HOME/btop/themes/dotfiles.theme"
TARGET_LAZYGIT="$STATE_DIR/lazygit.yml"
TARGET_YAZI_THEME="$CONFIG_HOME/yazi/theme.toml"
TARGET_EZA_THEME="$CONFIG_HOME/eza/theme.yml"
TARGET_TMUX_THEME="$CONFIG_HOME/tmux/theme.conf"
TARGET_OPENCODE_THEME="$CONFIG_HOME/opencode/theme.json"
TARGET_BAT_THEMES="$CONFIG_HOME/bat/themes"
TARGET_NVIM_STATE="$STATE_HOME/nvim/theme.txt"

usage() {
  cat <<'EOF'
Usage: theme-sync <command> [theme]

Commands:
  tui                               Open interactive TUI
  list                              List available themes
  current                           Show current theme and resolved values
  set <theme>                       Set current theme and apply it
  apply                             Re-apply current theme
  mode-set <light|dark> <theme>     Set preferred theme for a system mode
  mode-current                      Show configured light/dark mode themes
  auto [--watch [seconds]]          Apply theme from current system light/dark mode
                                     --watch only reapplies when mode changes

Environment:
  THEME_SYNC_ROOT                   Override root path (default: ~/.config/theme-sync)
  THEME_SYNC_LIGHT_THEME            Override configured light mode theme
  THEME_SYNC_DARK_THEME             Override configured dark mode theme
EOF
}

ensure_dirs() {
  mkdir -p "$STATE_DIR"
  # One-time migration: retain local choices, never overwrite newer state.
  # Regenerate exports rather than copying machine-specific absolute paths.
  local f theme
  for f in current mode.env; do
    if [[ ! -e "$STATE_DIR/$f" && -f "$ROOT/$f" ]]; then
      cp "$ROOT/$f" "$STATE_DIR/$f"
    fi
  done
  if [[ ! -e "$CURRENT_ENV_FILE" && -f "$CURRENT_FILE" ]]; then
    theme="$(current_theme)"
    if [[ -f "$THEMES_DIR/$theme/theme.env" ]]; then
      load_theme "$theme"
      write_current_env "$theme"
    fi
  fi
}

write_current_env() {
  local theme="$1"
  {
    printf 'export TERMINAL_THEME=%q\n' "$theme"
    printf 'export BAT_THEME=%q\n' "${BAT_THEME:-}"
    printf 'export FZF_THEME_FILE=%q\n' "${FZF_THEME_FILE:-}"
    printf 'export STARSHIP_CONFIG=%q\n' "$STARSHIP_CONFIG"
    local lazygit_config="$CONFIG_HOME/lazygit/config.yml"
    [[ ! -f "$TARGET_LAZYGIT" ]] || lazygit_config+=",$TARGET_LAZYGIT"
    printf 'export LG_CONFIG_FILE=%q\n' "$lazygit_config"
  } > "$CURRENT_ENV_FILE"
}

load_mode_config() {
  THEME_LIGHT=""
  THEME_DARK=""

  if [[ -f "$MODE_ENV_FILE" ]]; then
    # shellcheck disable=SC1090
    source "$MODE_ENV_FILE"
  fi

  THEME_LIGHT="${THEME_SYNC_LIGHT_THEME:-${THEME_LIGHT:-}}"
  THEME_DARK="${THEME_SYNC_DARK_THEME:-${THEME_DARK:-}}"
}

save_mode_config() {
  mkdir -p "$STATE_DIR"
  cat > "$MODE_ENV_FILE" <<EOF
THEME_LIGHT="${THEME_LIGHT:-}"
THEME_DARK="${THEME_DARK:-}"
EOF
}

set_mode_theme() {
  local mode="$1"
  local theme="$2"

  [[ -f "$THEMES_DIR/$theme/theme.env" ]] || {
    echo "Unknown theme: $theme"
    exit 1
  }

  load_mode_config
  case "$mode" in
    light) THEME_LIGHT="$theme" ;;
    dark) THEME_DARK="$theme" ;;
    *)
      echo "Mode must be 'light' or 'dark'."
      exit 1
      ;;
  esac

  save_mode_config
  echo "Saved $mode mode theme: $theme"
}

show_mode_config() {
  load_mode_config
  echo "light: ${THEME_LIGHT:-<unset>}"
  echo "dark:  ${THEME_DARK:-<unset>}"
}

detect_system_mode() {
  case "$(uname -s)" in
    Darwin)
      if defaults read -g AppleInterfaceStyle >/dev/null 2>&1; then
        echo "dark"
      else
        echo "light"
      fi
      ;;
    *)
      echo "Unsupported OS for automatic mode detection: $(uname -s)" >&2
      exit 1
      ;;
  esac
}

apply_system_mode_theme() {
  load_mode_config

  local mode
  mode="$(detect_system_mode)"

  local theme
  if [[ "$mode" == "dark" ]]; then
    theme="${THEME_DARK:-}"
  else
    theme="${THEME_LIGHT:-}"
  fi

  if [[ -z "$theme" ]]; then
    echo "No theme configured for $mode mode. Use: theme-sync mode-set $mode <theme>"
    exit 1
  fi

  local current
  current="$(current_theme)"
  if [[ "$current" == "$theme" ]]; then
    echo "System mode is $mode; theme already set: $theme"
    refresh_tmux_theme
    return 0
  fi

  echo "System mode is $mode; applying theme: $theme"
  apply_theme "$theme"
}

watch_system_mode_theme() {
  local interval="${1:-5}"
  local last_mode=""

  while true; do
    local mode
    mode="$(detect_system_mode 2>/dev/null || true)"

    if [[ -n "$mode" && "$mode" != "$last_mode" ]]; then
      apply_system_mode_theme || true
      last_mode="$mode"
    fi

    sleep "$interval"
  done
}

load_theme() {
  local theme="$1"
  local theme_file="$THEMES_DIR/$theme/theme.env"

  if [[ ! -f "$theme_file" ]]; then
    echo "Unknown theme: $theme"
    echo "Run 'theme-sync list' to view available themes."
    exit 1
  fi

  # Do not inherit optional mappings from the previous theme or parent shell.
  unset GHOSTTY_THEME_FILE BAT_THEME_FILE BTOP_THEME LAZYGIT_THEME_FILE OPENCODE_THEME_FILE VSCODE_THEME TMUX_BACKGROUND
  STARSHIP_CONFIG="$CONFIG_HOME/starship.toml"
  [[ ! -f "$THEMES_DIR/$theme/starship.toml" ]] || STARSHIP_CONFIG="$THEMES_DIR/$theme/starship.toml"
  # shellcheck disable=SC1090
  source "$theme_file"
}

prepare_output() {
  local file="$1"
  mkdir -p "$(dirname "$file")"
  # Detach old Stow links without touching their former targets (including
  # dangling links left after pulling the removal of generated files).
  [[ ! -L "$file" ]] || rm "$file"
}

copy_if_present() {
  local source_file="$1"
  local target_file="$2"

  if [[ -f "$source_file" ]]; then
    prepare_output "$target_file"
    cp "$source_file" "$target_file"
  fi
}

copy_tmux_theme() {
  local source_file="$1"
  local target_file="$2"

  [[ -f "$source_file" ]] || return 0
  prepare_output "$target_file"
  cp "$source_file" "$target_file"

  # Keep the bar background tied to the selected theme's canonical value,
  # rather than relying on a duplicated value in tmux.theme.conf.
  if [[ -n "${TMUX_BACKGROUND:-}" ]]; then
    sed -E -i.bak \
      "s|^set -g @minimal_theme_bg_color .*|set -g @minimal_theme_bg_color \"$TMUX_BACKGROUND\"|" \
      "$target_file"
    rm -f "$target_file.bak"
  fi
}

refresh_tmux_theme() {
  command -v tmux >/dev/null 2>&1 || return 0
  tmux ls >/dev/null 2>&1 || return 0

  local color
  for color in bg active inactive text accent border; do
    tmux set-option -gu "@minimal_theme_${color}_color" || true
  done
  [[ -f "$TARGET_TMUX_THEME" ]] && tmux source-file "$TARGET_TMUX_THEME" || true
  tmux run-shell "${DOTFILES_DIR:-$HOME/dotfiles}/scripts/tmux/minimal-theme/minimal.tmux" || true
}

refresh_kitty_theme() {
  command -v kitty >/dev/null 2>&1 || return 0

  local targets=()
  local s

  [[ -n "${KITTY_LISTEN_ON:-}" ]] && targets+=("$KITTY_LISTEN_ON")
  [[ -n "${THEME_SYNC_KITTY_LISTEN_ON:-}" ]] && targets+=("$THEME_SYNC_KITTY_LISTEN_ON")
  targets+=("unix:/tmp/kitty")
  [[ -n "${TMPDIR:-}" ]] && targets+=("unix:${TMPDIR%/}/kitty")

  for s in /tmp/kitty*; do
    [[ -S "$s" ]] && targets+=("unix:$s")
  done

  local target
  for target in "${targets[@]}"; do
    kitty @ --to "$target" load-config "$CONFIG_HOME/kitty/kitty.conf" >/dev/null 2>&1 && return 0
  done

  kitty @ load-config "$CONFIG_HOME/kitty/kitty.conf" >/dev/null 2>&1 || true
}

ensure_bat_theme() {
  [[ -n "${BAT_THEME:-}" ]] || return 0
  command -v bat >/dev/null 2>&1 || return 0

  if ! bat --list-themes 2>/dev/null | grep -Fxq "$BAT_THEME"; then
    bat cache --build >/dev/null
  fi

  if ! bat --list-themes 2>/dev/null | grep -Fxq "$BAT_THEME"; then
    echo "warning: bat theme '$BAT_THEME' is not available" >&2
  fi
}

apply_theme() {
  local theme="$1"
  local theme_dir="$THEMES_DIR/$theme"

  load_theme "$theme"
  local file
  for file in "$ALACRITTY_IMPORT" "$KITTY_INCLUDE"; do
    if [[ ! -f "$file" ]]; then
      echo "Theme asset missing: $file. Run dotfiles-install plugins and links first." >&2
      return 1
    fi
  done

  prepare_output "$TARGET_GHOSTTY"
  if [[ -n "${GHOSTTY_THEME_FILE:-}" && -f "$GHOSTTY_THEME_FILE" ]]; then
    cp "$GHOSTTY_THEME_FILE" "$TARGET_GHOSTTY"
  else
    printf 'theme = %s\n' "$GHOSTTY_THEME" > "$TARGET_GHOSTTY"
  fi

  copy_if_present "$ALACRITTY_IMPORT" "$TARGET_ALACRITTY"
  copy_if_present "$KITTY_INCLUDE" "$TARGET_KITTY"
  refresh_kitty_theme
  if [[ -n "${BAT_THEME_FILE:-}" && -f "$BAT_THEME_FILE" ]]; then
    copy_if_present "$BAT_THEME_FILE" "$TARGET_BAT_THEMES/$(basename "$BAT_THEME_FILE")"
    bat cache --build >/dev/null 2>&1 || true
  fi
  ensure_bat_theme
  if [[ -n "${BTOP_THEME:-}" && -f "$BTOP_THEME" ]]; then
    copy_if_present "$BTOP_THEME" "$TARGET_BTOP"
  else
    rm -f "$TARGET_BTOP"
  fi

  mkdir -p "$(dirname "$TARGET_NVIM_STATE")"
  printf '%s\n' "$NVIM_THEME" > "$TARGET_NVIM_STATE"

  # Optional overlays must not leak from the previously selected theme.
  rm -f "$TARGET_LAZYGIT" "$TARGET_YAZI_THEME" "$TARGET_EZA_THEME" "$TARGET_TMUX_THEME"
  if [[ -n "${LAZYGIT_THEME_FILE:-}" ]]; then
    copy_if_present "$LAZYGIT_THEME_FILE" "$TARGET_LAZYGIT"
  else
    copy_if_present "$theme_dir/lazygit.yml" "$TARGET_LAZYGIT"
  fi
  copy_if_present "$theme_dir/yazi.theme.toml" "$TARGET_YAZI_THEME"
  copy_if_present "$theme_dir/eza.theme.yml" "$TARGET_EZA_THEME"
  copy_tmux_theme "$theme_dir/tmux.theme.conf" "$TARGET_TMUX_THEME"
  if [[ -n "${OPENCODE_THEME_FILE:-}" ]]; then
    copy_if_present "$OPENCODE_THEME_FILE" "$TARGET_OPENCODE_THEME"
  else
    rm -f "$TARGET_OPENCODE_THEME"
  fi
  refresh_tmux_theme

  write_current_env "$theme"
  printf '%s\n' "$theme" > "$CURRENT_FILE"

  echo "Applied theme: $theme"
}

set_theme() {
  local theme="$1"

  if [[ -z "$theme" ]]; then
    echo "Missing theme name."
    usage
    exit 1
  fi

  apply_theme "$theme"
}

list_themes() {
  [[ -d "$THEMES_DIR" ]] || return 0
  for dir in "$THEMES_DIR"/*; do
    [[ -d "$dir" ]] || continue
    local theme
    theme="$(basename "$dir")"
    echo "$theme"
  done
}

current_theme() {
  if [[ -f "$CURRENT_FILE" ]]; then
    tr -d '\n' < "$CURRENT_FILE"
  else
    echo ""
  fi
}

show_current() {
  local theme
  theme="$(current_theme)"

  if [[ -z "$theme" ]]; then
    echo "No current theme set."
    exit 1
  fi

  load_theme "$theme"
  echo "theme: $theme"
  echo "ghostty: $GHOSTTY_THEME"
  echo "alacritty import: $ALACRITTY_IMPORT"
  echo "kitty include: $KITTY_INCLUDE"
  echo "nvim: $NVIM_THEME"
  echo "bat: $BAT_THEME"
  echo "btop: ${BTOP_THEME:-<default>}"
  echo "fzf file: ${FZF_THEME_FILE:-}"
  echo "vscode: ${VSCODE_THEME:-<unset>}"
}

tui_pick_theme() {
  local prompt="$1"
  local themes
  themes="$(list_themes)"

  if [[ -z "$themes" ]]; then
    echo "No themes found in $THEMES_DIR"
    return 1
  fi

  if command -v fzf >/dev/null 2>&1; then
    printf '%s\n' "$themes" | fzf --prompt "$prompt" --height 40% --layout=reverse --border
  else
    local picked=""
    select picked in $themes; do
      [[ -n "$picked" ]] && { echo "$picked"; return 0; }
    done
  fi
}

tui_menu() {
  while true; do
    local current light dark mode
    current="$(current_theme)"
    load_mode_config
    light="${THEME_LIGHT:-<unset>}"
    dark="${THEME_DARK:-<unset>}"
    mode="$(detect_system_mode 2>/dev/null || echo "unknown")"

    clear
    echo "theme-sync"
    echo "----------"
    echo "Current: ${current:-<unset>}"
    echo "System mode: $mode"
    echo "Light mode theme: $light"
    echo "Dark mode theme:  $dark"
    echo
    echo "1) Set current theme"
    echo "2) Apply current theme"
    echo "3) Set light mode theme"
    echo "4) Set dark mode theme"
    echo "5) Auto-apply from system mode"
    echo "6) Show current details"
    echo "q) Quit"
    echo
    read -r -p "Choose: " choice

    case "$choice" in
      1)
        local picked
        picked="$(tui_pick_theme "Theme > ")" || true
        [[ -n "${picked:-}" ]] && apply_theme "$picked"
        read -r -p "Press Enter to continue..." _
        ;;
      2)
        local t
        t="$(current_theme)"
        if [[ -z "$t" ]]; then
          echo "No current theme set."
        else
          apply_theme "$t"
        fi
        read -r -p "Press Enter to continue..." _
        ;;
      3)
        local light_pick
        light_pick="$(tui_pick_theme "Light theme > ")" || true
        [[ -n "${light_pick:-}" ]] && set_mode_theme light "$light_pick"
        read -r -p "Press Enter to continue..." _
        ;;
      4)
        local dark_pick
        dark_pick="$(tui_pick_theme "Dark theme > ")" || true
        [[ -n "${dark_pick:-}" ]] && set_mode_theme dark "$dark_pick"
        read -r -p "Press Enter to continue..." _
        ;;
      5)
        apply_system_mode_theme || true
        read -r -p "Press Enter to continue..." _
        ;;
      6)
        show_current || true
        read -r -p "Press Enter to continue..." _
        ;;
      q|Q)
        break
        ;;
    esac
  done
}

main() {
  local cmd="${1:-tui}"
  case "$cmd" in -h|--help|help) usage; return 0 ;; esac
  ensure_dirs

  case "$cmd" in
    tui)
      tui_menu
      ;;
    list)
      list_themes
      ;;
    current)
      show_current
      ;;
    set)
      set_theme "${2:-}"
      ;;
    apply)
      local theme
      theme="$(current_theme)"
      if [[ -z "$theme" ]]; then
        echo "No current theme set. Use: theme-sync set <theme>"
        exit 1
      fi
      apply_theme "$theme"
      ;;
    mode-set)
      set_mode_theme "${2:-}" "${3:-}"
      ;;
    mode-current)
      show_mode_config
      ;;
    auto)
      if [[ "${2:-}" == "--watch" ]]; then
        local interval="${3:-5}"
        watch_system_mode_theme "$interval"
      else
        apply_system_mode_theme
      fi
      ;;
    ""|-h|--help|help)
      usage
      ;;
    *)
      echo "Unknown command: $cmd"
      usage
      exit 1
      ;;
  esac
}

main "$@"
