-- This file is loaded by hyprland.lua.

-- Keybindings
local terminal = "kitty"
local browser = "helium"
local mainMod = "SUPER"
local function bind(key, dispatcher, flags)
	hl.bind(mainMod .. " + " .. key, dispatcher, flags)
end
bind("Q", hl.dsp.window.close())
bind("M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || uwsm stop"))
bind("RETURN", hl.dsp.exec_cmd(terminal))
bind("B", hl.dsp.exec_cmd(browser))
bind("V", hl.dsp.window.float({ action = "toggle" }))
bind("P", hl.dsp.window.pseudo())
bind("Space", hl.dsp.exec_cmd("vicinae toggle"))
hl.bind("SUPER + ALT + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind("ALT + SHIFT + 4", hl.dsp.exec_cmd('grim -g "$(slurp)" - | satty --filename -'))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("grim ~/Pictures/$(date +'%Y-%m-%d_%H-%M-%S').png"))
hl.bind("CTRL + Print", hl.dsp.exec_cmd('grim -g "$(slurp)" - | wl-copy'))
for _, x in ipairs({ { "h", "left" }, { "l", "right" }, { "k", "up" }, { "j", "down" } }) do
	bind(x[1], hl.dsp.focus({ direction = x[2] }))
	hl.bind(mainMod .. " + SHIFT + " .. x[1], hl.dsp.window.move({ direction = x[2] }))
end
hl.bind("SUPER + SHIFT + RETURN", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind("SUPER + SHIFT + F", hl.dsp.window.fullscreen({ action = "toggle" }))
for i = 1, 5 do
	hl.bind("SUPER + " .. i, hl.dsp.focus({ workspace = i }))
	hl.bind("SUPER + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end
bind("S", hl.dsp.workspace.toggle_special("magic"))
hl.bind("SUPER + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))
hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })
for _, x in ipairs({
	{ "XF86AudioRaiseVolume", "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+" },
	{ "XF86AudioLowerVolume", "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-" },
	{ "XF86AudioMute", "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle" },
	{ "XF86AudioMicMute", "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle" },
	{ "XF86MonBrightnessUp", "brightnessctl -e4 -n2 set 5%+" },
	{ "XF86MonBrightnessDown", "brightnessctl -e4 -n2 set 5%-" },
}) do
	hl.bind(x[1], hl.dsp.exec_cmd(x[2]), { locked = true, repeating = true })
end
for _, x in ipairs({
	{ "XF86AudioNext", "playerctl next" },
	{ "XF86AudioPause", "playerctl play-pause" },
	{ "XF86AudioPlay", "playerctl play-pause" },
	{ "XF86AudioPrev", "playerctl previous" },
}) do
	hl.bind(x[1], hl.dsp.exec_cmd(x[2]), { locked = true })
end
