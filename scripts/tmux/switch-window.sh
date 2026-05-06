#!/usr/bin/env bash

set -euo pipefail

preview_cmd='bash -c '\''session="$1"; tmux list-windows -t "$session" -F "#{window_index}:#{window_name}" | while IFS= read -r win; do idx="${win%%:*}"; printf "%s\n" "$win"; tmux list-panes -t "$session:$idx" -F "  #{pane_index} #{pane_current_command}"; done'\'' _ {}'

selection="$(tmux list-sessions -F '#{session_name}' | env -u FZF_DEFAULT_OPTS -u FZF_DEFAULT_COMMAND -u FZF_CTRL_T_COMMAND fzf --prompt='Session > ' --layout=reverse --height=100% --info=inline --preview-window='right:65%' --preview="$preview_cmd" || true)"
# selection="$(tmux list-sessions -F '#{session_name}' | env -u FZF_DEFAULT_OPTS -u FZF_DEFAULT_COMMAND -u FZF_CTRL_T_COMMAND fzf --prompt='Session > ' --layout=reverse --border --height=100% --info=inline || true)"

if [ -z "$selection" ]; then
  exit 0
fi

session="$selection"

tmux switch-client -t "$session"
