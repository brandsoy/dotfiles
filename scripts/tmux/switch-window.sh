#!/usr/bin/env bash

set -euo pipefail

tab=$'\t'
format=$'#{pane_id}\t#{?pane_active,0,#{?window_active,1,#{?pane_last,2,3}}}\t#{session_name}\t#{window_name}\t#{pane_current_command}\t#{pane_index}\t#{?pane_active,*, }\t#{pane_start_command}\t#{pane_current_path}'

# Rank panes so active/recent panes show first.
pane_list="$(tmux list-panes -a -F "$format")"
selection="$(printf '%s\n' "$pane_list" | sort -t "$tab" -k2,2n -k3,3 -k4,4 | awk -F '\t' 'BEGIN { OFS="\t" } function clip(s, n) { return length(s) > n ? substr(s, 1, n - 3) "..." : s } { display = sprintf("%s %-14s %-26s %-14s p%-2s", $7, clip($3, 14), clip($4, 26), clip($5, 14), $6); search = $3 " " $4 " " $5 " " $8 " " $9; print $1, display, search }' | env -u FZF_DEFAULT_OPTS -u FZF_DEFAULT_COMMAND -u FZF_CTRL_T_COMMAND fzf --prompt='Pane > ' --delimiter="$tab" --with-nth=2 --layout=reverse --border --height=100% --info=inline --header='* session        window name                 command        index' || true)"

if [ -z "$selection" ]; then
  exit 0
fi

pane_id="$(printf '%s\n' "$selection" | cut -f1)"
session="$(tmux display-message -p -t "$pane_id" '#{session_name}')"
window="$(tmux display-message -p -t "$pane_id" '#{window_index}')"

tmux switch-client -t "$session"
tmux select-window -t "${session}:$window"
tmux select-pane -t "$pane_id"
