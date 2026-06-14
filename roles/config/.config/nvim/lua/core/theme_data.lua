local M = {}

M.themes = {
	{ name = 'oc-2' },
	{ name = 'oc-2-noir' },
	{ name = 'catppuccin-mocha' },
	{ name = 'catppuccin-latte' },
	{ name = 'carbonfox' },
	{ name = 'tokyonight-night' },
	{ name = 'dracula' },
	{ name = 'onedark' },
}

M.theme_names = {}
M.theme_lookup = {}

for _, theme in ipairs(M.themes) do
	M.theme_names[#M.theme_names + 1] = theme.name
	M.theme_lookup[theme.name] = theme
end

M.state_file = vim.fn.stdpath('state') .. '/theme.txt'

return M
