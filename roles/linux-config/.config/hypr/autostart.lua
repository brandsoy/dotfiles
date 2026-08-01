-- This file is loaded by hyprland.lua.

-- Programs and services
hl.on("hyprland.start", function()
    hl.exec_cmd("gsettings set org.gnome.desktop.interface gtk-theme 'Tokyo-Night'")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-theme 'default'")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface font-name 'Adwaita Sans 11'")
    hl.exec_cmd("uwsm app -- swaync")
    hl.exec_cmd("uwsm app -- hyprpaper")
    hl.exec_cmd("sleep 1 && uwsm app -- waybar")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("uwsm app -- hypridle")
    hl.exec_cmd("uwsm app -- vicinae server")
    hl.exec_cmd("sleep 3 && uwsm app -- nm-applet --indicator")
    hl.exec_cmd("sleep 3 && uwsm app -- blueman-applet")
    -- This is a long-running watcher, not a desktop application; don't launch it via uwsm app.
    hl.exec_cmd("~/.config/hypr/scripts/monitor_workspace_setup.sh")
end)

