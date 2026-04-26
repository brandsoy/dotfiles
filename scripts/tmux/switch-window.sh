#!/usr/bin/env bash

set -euo pipefail

selection="$(tmux list-sessions -F '#{session_name}' | env -u FZF_DEFAULT_OPTS -u FZF_DEFAULT_COMMAND -u FZF_CTRL_T_COMMAND fzf --prompt='Session > ' --layout=reverse --border --height=100% --info=inline || true)"

if [ -z "$selection" ]; then
  exit 0
fi

session="$selection"

tmux switch-client -t "$session"
