#!/bin/bash

# Script to dynamically assign workspaces based on monitor availability
# This script should be run at Hyprland startup and when monitors change

# Check if external monitors are connected
EXTERNAL_MONITORS=$(hyprctl monitors | grep -E "DP-2|DP-3" | wc -l)

if [ "$EXTERNAL_MONITORS" -gt "0" ]; then
  # External monitors are connected - assign workspaces 1-9 to external, 10 to laptop
  echo "External monitors detected - configuring workspaces"

  # Assign workspaces 1-9 to external monitors (DP-2 or DP-3)
  for ws in {1..4}; do
    hyprctl dispatch workspace $ws
    hyprctl dispatch movetoworkspacesilent $ws,DP-2,DP-3
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
