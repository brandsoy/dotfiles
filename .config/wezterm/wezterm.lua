local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.enable_tab_bar = false
config.macos_window_background_blur = 10
config.window_background_opacity = 0.96
config.window_decorations = "RESIZE"

-- config.color_scheme = "Tokyo Night"
config.color_scheme = "catppuccin-mocha"
-- my coolnight colorscheme
config.colors = {
	-- foreground = "#CBE0F0",
	background = "#011423",
	cursor_bg = "#47FF9C",
	cursor_border = "#47FF9C",
	cursor_fg = "#011423",
	selection_bg = "#033259",
	selection_fg = "#CBE0F0",
	-- ansi = { "#214969", "#E52E2E", "#44FFB1", "#FFE073", "#0FC5ED", "#a277ff", "#24EAF7", "#24EAF7" },
	-- brights = { "#214969", "#E52E2E", "#44FFB1", "#FFE073", "#A277FF", "#a277ff", "#24EAF7", "#24EAF7" },
}

config.font = wezterm.font("JetBrainsMono Nerd Font")
-- config.font = wezterm.font("MesloLGS Nerd Font Mono")
config.font_size = 16

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
