#!/bin/bash

# Script to dynamically assign workspaces based on monitor availability
# This script should be run at Hyprland startup and when monitors change

# Find the first connected external monitor (DP-2 or DP-3)
EXTERNAL_MON=$(hyprctl monitors -j | jq -r '.[].name' | grep -E "^DP-" | head -n1)

if [ -n "$EXTERNAL_MON" ]; then
  # External monitor is connected - assign workspaces 1-4 to external, 5 to laptop
  echo "External monitor detected ($EXTERNAL_MON) - configuring workspaces"

  # Assign workspaces 1-4 to external monitor
  for ws in {1..4}; do
    hyprctl dispatch workspace $ws
    hyprctl dispatch movetoworkspacesilent $ws,$EXTERNAL_MON
  done

  # Assign workspace 5 to laptop monitor
  hyprctl dispatch workspace 5
  hyprctl dispatch movetoworkspacesilent 5,eDP-1

  # Go back to workspace 1
  hyprctl dispatch workspace 1

else
  # No external monitors - assign all workspaces to laptop
  echo "No external monitors detected - configuring all workspaces on laptop"

  for ws in {1..5}; do
    hyprctl dispatch workspace $ws
    hyprctl dispatch movetoworkspacesilent $ws,eDP-1
  done

  # Go back to workspace 1
  hyprctl dispatch workspace 1
fi
