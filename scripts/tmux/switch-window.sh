#!/usr/bin/env bash

set -euo pipefail

selection="$(tmux list-panes -a -F '#{session_name}:#{window_index}.#{pane_index}:#{window_name}:#{pane_title}' | fzf --prompt='Switch to pane: ' --reverse || true)"

if [ -z "$selection" ]; then
  exit 0
fi

session="$(printf '%s' "$selection" | cut -d':' -f1)"
window_and_pane="$(printf '%s' "$selection" | cut -d':' -f2)"
window="$(printf '%s' "$window_and_pane" | cut -d'.' -f1)"
pane="$(printf '%s' "$window_and_pane" | cut -d'.' -f2)"

tmux switch-client -t "$session"
tmux select-window -t "${session}:$window"
tmux select-pane -t "${session}:${window}.${pane}"
