#!/usr/bin/env bash
# Maintainer: mattis

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

    bg_color=$(get_tmux_option "@minimal_theme_bg_color" "#282c34")
    active_color=$(get_tmux_option "@minimal_theme_active_color" "#98C379")
    inactive_color=$(get_tmux_option "@minimal_theme_inactive_color" "#5c6370")
    text_color=$(get_tmux_option "@minimal_theme_text_color" "#abb2bf")
    accent_color=$(get_tmux_option "@minimal_theme_accent_color" "#E86671")
    border_color=$(get_tmux_option "@minimal_theme_border_color" "#3e4452")
    icon_session=$(get_tmux_option "@minimal_theme_session_icon" "")
    icon_dir=$(get_tmux_option "@minimal_theme_dir_icon" "")
    icon_memory=$(get_tmux_option "@minimal_theme_memory_icon" "")
    icon_date=$(get_tmux_option "@minimal_theme_date_icon" "")
    icon_clock=$(get_tmux_option "@minimal_theme_clock_icon" "")
    icon_battery=$(get_tmux_option "@minimal_theme_battery_icon" "")

    # Status bar setup
    tmux set-option -g status on
    # tmux set-option -g status-position bottom
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
    tmux set-option -g message-style "bg=$border_color,fg=$text_color,bold"
    tmux set-option -g message-command-style "bg=$border_color,fg=$text_color,bold"

    # Window status format
    tmux set-option -g window-status-format "#[fg=$inactive_color,bg=$bg_color]  #I #W  "
    tmux set-option -g window-status-current-format "#[fg=$bg_color,bg=$active_color,bold]  #I #W  "
    tmux set-option -g window-status-separator ""

    # Status left (session name)
    tmux set-option -g status-left "#[fg=$bg_color,bg=$accent_color,bold] $icon_session #S #[fg=$accent_color,bg=$bg_color]#[fg=$inactive_color,bg=$bg_color] "

    # Status right with macOS-safe system info
    local status_right="\
#[fg=$inactive_color,bg=$bg_color]#[fg=$border_color]#[fg=$text_color,bg=$border_color] $icon_dir #([ #{pane_current_path} = \$HOME ] && echo '~' || basename #{pane_current_path}) \
#[fg=$bg_color,bg=$border_color]#[fg=$border_color]#[fg=$text_color,bg=$border_color] $icon_memory #(memory_pressure 2>/dev/null | awk -F': ' '/System-wide memory free percentage/ { print \$2 }' | tr -d '%' | awk 'NF {print; found=1} END {if (!found) print \"N/A\"}')% \
#[fg=$bg_color,bg=$border_color]#[fg=$border_color]#[fg=$text_color,bg=$border_color] $icon_date #(date +%d) \
#[fg=$bg_color,bg=$border_color]#[fg=$border_color]#[fg=$text_color,bg=$border_color] $icon_clock #(date +%H:%M) \
#[fg=$bg_color,bg=$border_color]#[fg=$border_color]#[fg=$text_color,bg=$border_color] $icon_battery #(pmset -g batt 2>/dev/null | awk 'NR==2 { match(\$0, /([0-9]+)%/, m); print m[1] ? m[1] : \"N/A\" }')% #[fg=$border_color,bg=$bg_color] "

    tmux set-option -g status-right "$status_right"

    # Copy mode styling
    tmux set-option -g mode-style "bg=$active_color,fg=$bg_color"

    # Clock mode
    tmux set-option -g clock-mode-colour "$active_color"
    tmux set-option -g clock-mode-style 24
}
