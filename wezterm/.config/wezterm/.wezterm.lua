-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.color_scheme = "rose-pine"
-- config.color_scheme = 'Rosé Pine (base16)'
-- config.color_scheme = "Rosé Pine (Gogh)"

config.font = wezterm.font("CaskaydiaCove Nerd Font Mono")

-- and finally, return the configuration to wezterm
return config
