#!/usr/bin/env bash

get_tmux_option() {
    local option="$1"
    local default_value="$2"
    local option_value
    option_value="$(tmux show-option -gqv "$option")"
    if [ -z "$option_value" ]; then
        echo "$default_value"
    else
        echo "$option_value"
    fi
}

apply_minimal_theme() {
    # Get theme colors (allow customization)
    local bg_color
    local active_color
    local inactive_color
    local text_color
    local accent_color
    local border_color
    local icon_session
    local icon_dir
    local icon_memory
    local icon_date
    local icon_clock
    local icon_battery

    bg_color=$(get_tmux_option "@minimal_theme_bg_color" "#1A1D23")
    active_color=$(get_tmux_option "@minimal_theme_active_color" "#b4befe")
    inactive_color=$(get_tmux_option "@minimal_theme_inactive_color" "#6c7086")
    text_color=$(get_tmux_option "@minimal_theme_text_color" "#cdd6f4")
    accent_color=$(get_tmux_option "@minimal_theme_accent_color" "#b4befe")
    border_color=$(get_tmux_option "@minimal_theme_border_color" "#44475a")
    icon_session=$(get_tmux_option "@minimal_theme_session_icon" "")
    icon_dir=$(get_tmux_option "@minimal_theme_dir_icon" "")
    icon_memory=$(get_tmux_option "@minimal_theme_memory_icon" "")
    icon_date=$(get_tmux_option "@minimal_theme_date_icon" "")
    icon_clock=$(get_tmux_option "@minimal_theme_clock_icon" "")
    icon_battery=$(get_tmux_option "@minimal_theme_battery_icon" "")

    # Status bar setup
    tmux set-option -g status on
    tmux set-option -g status-position bottom
    tmux set-option -g status-interval 3
    tmux set-option -g status-justify left

    # Status bar colors and style
    tmux set-option -g status-style "bg=$bg_color,fg=$text_color"
    tmux set-option -g status-left-length 100
    tmux set-option -g status-right-length 100

    # Pane borders
    tmux set-option -g pane-border-style "fg=$border_color"
    tmux set-option -g pane-active-border-style "fg=$active_color"

    # Message style
    tmux set-option -g message-style "bg=$bg_color,fg=$text_color,bold"
    tmux set-option -g message-command-style "bg=$bg_color,fg=$text_color,bold"

    # Window status format
    tmux set-option -g window-status-format "#[fg=$inactive_color,bg=$bg_color] #I:#W "
    tmux set-option -g window-status-current-format "#[fg=$active_color,bg=$bg_color,bold] #I:#W "
    tmux set-option -g window-status-separator ""

    # Status left (session name)
    tmux set-option -g status-left "#[fg=$accent_color,bold]$icon_session  #S #[fg=$inactive_color]│ "

    # Status right with macOS-safe system info
    local status_right="\
#[fg=$accent_color]$icon_dir #[fg=$text_color]#([ #{pane_current_path} = \$HOME ] && echo '~' || basename #{pane_current_path}) \
#[fg=$inactive_color]│ \
#[fg=$accent_color]$icon_memory #[fg=$text_color]#(memory_pressure 2>/dev/null | awk -F': ' '/System-wide memory free percentage/ { print \$2 }' | tr -d '%' | awk 'NF {print; found=1} END {if (!found) print \"N/A\"}')% \
#[fg=$inactive_color]│ \
#[fg=$accent_color]$icon_date #[fg=$text_color]#(date +%d) \
#[fg=$inactive_color]│ \
#[fg=$accent_color]$icon_clock #[fg=$text_color]#(date +%H:%M) \
#[fg=$inactive_color]│ \
#[fg=$accent_color]$icon_battery #[fg=$text_color]#(pmset -g batt 2>/dev/null | awk 'NR==2 { match(\$0, /([0-9]+)%/, m); print m[1] ? m[1] : \"N/A\" }')% "

    tmux set-option -g status-right "$status_right"

    # Copy mode styling
    tmux set-option -g mode-style "bg=$active_color,fg=$bg_color"

    # Clock mode
    tmux set-option -g clock-mode-colour "$active_color"
    tmux set-option -g clock-mode-style 24
}
