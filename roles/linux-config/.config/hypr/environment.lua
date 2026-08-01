-- This file is loaded by hyprland.lua.

-- Environment
for name, value in pairs({
    XCURSOR_SIZE = "24", HYPRCURSOR_SIZE = "24",
    GDK_BACKEND = "wayland,x11,*", QT_QPA_PLATFORM = "wayland;xcb",
    SDL_VIDEODRIVER = "wayland", CLUTTER_BACKEND = "wayland",
    QT_QPA_PLATFORMTHEME = "qt6ct", GTK_THEME = "Adwaita-dark",
    XDG_CURRENT_DESKTOP = "Hyprland", XDG_SESSION_TYPE = "wayland",
    XDG_SESSION_DESKTOP = "Hyprland",
}) do hl.env(name, value) end

