-- This file is loaded by hyprland.lua.

-- Appearance and layout
hl.config({
    general = {
        gaps_in = 0, gaps_out = 0, border_size = 0,
        col = { active_border = { colors = { "rgba(5599ccaa)", "rgba(55bb88aa)" }, angle = 45 }, inactive_border = "rgba(404040aa)" },
        resize_on_border = false, allow_tearing = false, layout = "dwindle",
    },
    decoration = {
        rounding = 0, rounding_power = 2, active_opacity = 1.0, inactive_opacity = 1.0,
        shadow = { enabled = true, range = 4, render_power = 3, color = "rgba(1a1a1aee)" },
        blur = { enabled = true, size = 3, passes = 1, vibrancy = 0.1696 },
    },
    animations = { enabled = true },
    misc = { force_default_wallpaper = -1, disable_hyprland_logo = false, focus_on_activate = true },
    input = {
        kb_layout = "us,no", kb_options = "grp:ctrl_space_toggle", follow_mouse = 1, sensitivity = 0,
        repeat_rate = 50, repeat_delay = 300, touchpad = { natural_scroll = true },
    },
})
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
hl.config({ master = { new_status = "master" } })

-- Animations
for name, points in pairs({
    easeOutQuint={{.23,1},{.32,1}}, easeInOutCubic={{.65,.05},{.36,1}}, linear={{0,0},{1,1}},
    almostLinear={{.5,.5},{.75,1}}, quick={{.15,0},{.1,1}},
}) do hl.curve(name, { type = "bezier", points = points }) end
for _, a in ipairs({
    {"global",1,10,"default"},{"border",1,5.39,"easeOutQuint"},{"windows",1,4.79,"easeOutQuint"},
    {"windowsIn",1,4.1,"easeOutQuint","popin 87%"},{"windowsOut",1,1.49,"linear","popin 87%"},
    {"fadeIn",1,1.73,"almostLinear"},{"fadeOut",1,1.46,"almostLinear"},{"fade",1,3.03,"quick"},
    {"layers",1,3.81,"easeOutQuint"},{"layersIn",1,4,"easeOutQuint","fade"},{"layersOut",1,1.5,"linear","fade"},
    {"fadeLayersIn",1,1.79,"almostLinear"},{"fadeLayersOut",1,1.39,"almostLinear"},
    {"workspaces",1,1.94,"almostLinear","fade"},{"workspacesIn",1,1.21,"almostLinear","fade"},
    {"workspacesOut",1,1.94,"almostLinear","fade"},{"zoomFactor",1,7,"quick"},
}) do hl.animation({ leaf=a[1], enabled=a[2] == 1, speed=a[3], bezier=a[4], style=a[5] }) end

