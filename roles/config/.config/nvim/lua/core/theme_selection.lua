local M = {}

local data = require('core.theme_data')
local storage = require('core.theme_storage')

local function current_index()
	local current = vim.g.colors_name or data.themes[1].name
	for index, theme in ipairs(data.themes) do
		if theme.name == current then
			return index
		end
	end
	return 1
end

function M.cycle(step)
	local next_index = current_index() + step
	if next_index < 1 then
		next_index = #data.themes
	elseif next_index > #data.themes then
		next_index = 1
	end
	return require('core.theme').apply(data.themes[next_index].name)
end

function M.select()
	vim.ui.select(data.theme_names, { prompt = 'Select colorscheme' }, function(choice)
		if choice then
			require('core.theme').apply(choice)
		end
	end)
end

function M.startup(default_name)
	return require('core.theme').apply(storage.read_saved_theme() or default_name or data.themes[1].name, {
		silent = true,
		persist = false,
	})
end

return M
