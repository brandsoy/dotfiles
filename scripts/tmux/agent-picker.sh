#!/usr/bin/env bash

state="${XDG_STATE_HOME:-$HOME/.local/state}/theme-switcher/current.env"
# shellcheck disable=SC1090
[[ -r "$state" ]] && source "$state"
# shellcheck disable=SC1090
[[ -r "${FZF_THEME_FILE:-}" ]] && source "$FZF_THEME_FILE"

# ponytail: match common agent commands on the pane's tty; add names here for other CLIs.
processes=$(ps -A -o tty= -o args=)
rows=$(tmux list-panes -a -F '#{pane_id}	#{pane_tty}	#{session_name}:#{window_index}.#{pane_index}	#{window_name}	#{pane_current_path}' |
  while IFS=$'\t' read -r id tty location window path; do
    tty=${tty#/dev/}
    agent=$(printf '%s\n' "$processes" | awk -v tty="$tty" '
      { terminal = $1; sub(/^tty/, "", terminal); sub(/^tty/, "", tty) }
      terminal == tty {
        for (i = 2; i <= NF && i <= 4; i++) {
          name = $i; sub(/^.*\//, "", name); sub(/\.(js|mjs|cjs)$/, "", name)
          if (name ~ /^(pi|claude|codex|opencode|gemini|aider)$/) { print name; exit }
          if (i == 2 && name !~ /^(node|bun|python|python3|env)$/) break
        }
      }')
    [[ -n "$agent" ]] && printf '%s\t%s\t%s\t%s\t%s\n' "$id" "$agent" "$location" "$window" "$path"
  done)

if [[ -z "$rows" ]]; then
  tmux display-message 'No open agents found'
  exit 0
fi

selection=$(printf '%s\n' "$rows" | fzf-tmux -p 30%,30% \
  --delimiter=$'\t' --with-nth=2.. --no-sort --border --border-label ' agents ' --prompt '🤖  ' \
  --header '  Enter jump to agent · Esc cancel' --bind 'tab:down,btab:up') || exit 0
id=${selection%%$'\t'*}
tmux select-window -t "$id" \; select-pane -t "$id" \; switch-client -c "$1" -t "$id"
