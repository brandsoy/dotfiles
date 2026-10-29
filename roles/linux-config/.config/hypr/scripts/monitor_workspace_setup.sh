#!/bin/bash

# Script to dynamically assign workspaces based on monitor availability
# This script should be run at Hyprland startup and when monitors change

set -o pipefail

# hyprctl can return an error message with a successful exit status.
hypr_command() {
  local result
  result=$(hyprctl "$@") && [ "$result" = ok ] && return 0
  printf 'hyprctl %s failed: %s\n' "$1" "$result" >&2
  return 1
}

configure_workspaces() {
  local monitors laptop external target quoted ws existing current focused after failed=0
  monitors=$(hyprctl monitors -j) || return 1
  laptop=$(jq -er '[.[].name | select(startswith("eDP-"))][0] // ""' <<< "$monitors") || return 1
  external=$(jq -er '[.[].name | select(startswith("eDP-") | not)] | if index("DP-2") then "DP-2" else .[0] // "" end' <<< "$monitors") || return 1
  [ -n "$laptop$external" ] || return 1
  existing=$(hyprctl workspaces -j) || return 1
  focused=$(hyprctl activeworkspace -j | jq -er '.id | numbers') || return 1

  for ws in {1..5}; do
    target=${external:-$laptop}
    if [ "$ws" -eq 5 ] && [ -n "$laptop" ]; then
      target=$laptop
    fi
    [ -n "$target" ] || continue
    # Monitor connector names use these characters; reject anything else rather
    # than interpolate arbitrary text into Lua.
    if [[ ! $target =~ ^[a-zA-Z0-9_.-]+$ ]]; then
      printf 'Invalid monitor name: %s\n' "$target" >&2
      failed=1
      continue
    fi
    quoted="\"$target\""
    hypr_command eval "hl.workspace_rule({ workspace = \"$ws\", monitor = $quoted })" || failed=1
    current=$(jq -r --argjson ws "$ws" '.[] | select(.id == $ws) | .monitor' <<< "$existing") || { failed=1; continue; }
    if [ -n "$current" ] && [ "$current" != "$target" ]; then
      hypr_command dispatch "hl.dsp.workspace.move({ workspace = $ws, monitor = $quoted })" || failed=1
    fi
  done

  # Moving an active workspace can change focus. Do not switch if it did not.
  after=$(hyprctl activeworkspace -j | jq -er '.id | numbers') || return 1
  if [ "$after" != "$focused" ]; then
    hypr_command dispatch "hl.dsp.focus({ workspace = $focused })" || failed=1
  fi
  return "$failed"
}

# Reload clears dynamic Lua rules without changing the monitor list. Compare
# the actual rules too, so both reloads and hotplug trigger reconciliation.
monitor_names() {
  hyprctl monitors -j | jq -r '.[].name' | sort
}
workspace_rules() {
  hyprctl workspacerules -j | jq -c '[.[] | select(.workspaceString as $ws | ["1", "2", "3", "4", "5"] | index($ws)) | {workspaceString, monitor, enabled}] | sort_by(.workspaceString)'
}

previous_monitors=
previous_rules=
while :; do
  current_monitors=$(monitor_names) && current_rules=$(workspace_rules) || { sleep 2; continue; }
  if [ -z "$previous_rules" ] || [ "$current_monitors" != "$previous_monitors" ] || [ "$current_rules" != "$previous_rules" ]; then
    if configure_workspaces; then
      previous_monitors=$current_monitors
      previous_rules=$(workspace_rules) || previous_rules=
      if [ "$(jq 'length' <<< "$previous_rules")" != 5 ]; then
        previous_rules=
      fi
    fi
  fi
  sleep 2
done
