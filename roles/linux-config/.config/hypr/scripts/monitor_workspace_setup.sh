#!/bin/bash

# Script to dynamically assign workspaces based on monitor availability
# This script should be run at Hyprland startup and when monitors change

configure_workspaces() {
  # Find the first connected external monitor.
  local external_mon
  external_mon=$(hyprctl monitors -j | jq -r '.[].name' | grep -E '^DP-' | head -n1)

  if [ -n "$external_mon" ]; then
    echo "External monitor detected ($external_mon) - configuring workspaces"
    for ws in {1..4}; do
      hyprctl dispatch workspace "$ws"
      hyprctl dispatch movetoworkspacesilent "$ws,$external_mon"
    done
    hyprctl dispatch workspace 5
    hyprctl dispatch movetoworkspacesilent "5,eDP-1"
  else
    echo "No external monitors detected - configuring workspaces on laptop"
    for ws in {1..5}; do
      hyprctl dispatch workspace "$ws"
      hyprctl dispatch movetoworkspacesilent "$ws,eDP-1"
    done
  fi

  hyprctl dispatch workspace 1
}

# Configure once, then watch for monitor hotplug changes. This replaces the
# deprecated exec-on-monitor-add/remove hooks when using hyprland.lua.
configure_workspaces
previous_monitors=$(hyprctl monitors -j | jq -r '.[].name' | sort | tr '\n' ' ')
while sleep 2; do
  current_monitors=$(hyprctl monitors -j | jq -r '.[].name' | sort | tr '\n' ' ')
  if [ "$current_monitors" != "$previous_monitors" ]; then
    configure_workspaces
    previous_monitors="$current_monitors"
  fi
done
