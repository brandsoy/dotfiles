local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.ssh_domains = {
	{
		-- This name identifies the domain
		name = "docksrv",
		-- The hostname or address to connect to. Will be used to match settings
		-- from your ssh config file
		remote_address = "ssh.docksrv.com -p 9999",
		-- The username to use on the remote host
		username = "mattis",
	},
}

config.color_scheme = "Tokyo Night"
config.enable_tab_bar = false
config.font_size = 16.0
config.font = wezterm.font("JetBrains Mono")
config.macos_window_background_blur = 30
config.window_background_opacity = 0.92
config.window_decorations = "RESIZE"

-- window_background_image = '/Users/omerhamerman/Downloads/3840x1080-Wallpaper-041.jpg',
-- window_background_image_hsb = {
-- 	brightness = 0.01,
-- 	hue = 1.0,
-- 	saturation = 0.5,
-- },

config.keys = {
	{
		key = "f",
		mods = "CTRL",
		action = wezterm.action.ToggleFullScreen,
	},
}

config.mouse_bindings = {
	-- Ctrl-click will open the link under the mouse cursor
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "CTRL",
		action = wezterm.action.OpenLinkAtMouseCursor,
	},
}

return config
