-- This file is loaded by hyprland.lua.

-- Window and layer rules
hl.window_rule({ name="suppress-maximize-events", match={ class=".*" }, suppress_event="maximize" })
hl.window_rule({ name="fix-xwayland-drags", match={ class="^$", title="^$", xwayland=true, float=true, fullscreen=false, pin=false }, no_focus=true })
hl.window_rule({ name="move-hyprland-run", match={ class="hyprland-run" }, move="20 monitor_h-120", float=true })
hl.window_rule({ name="satty-floating-editor", match={ class="com.gabm.satty" }, float=true, center=true, size={"80%","80%"} })
hl.layer_rule({ name="vicinae-blur", match={ namespace="vicinae" }, blur=true, ignore_alpha=0 })
hl.layer_rule({ name="vicinae-no-animation", match={ namespace="vicinae" }, no_anim=true })
