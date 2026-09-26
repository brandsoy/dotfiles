local M = {}

local data = require('core.theme_data')
local storage = require('core.theme_storage')
local selection = require('core.theme_selection')
local commands = require('core.theme_commands')

local function notify(message, level)
	if vim.notify then
		vim.notify(message, level or vim.log.levels.INFO, { title = 'Theme' })
	end
end

local function clear_bg()
	local groups = { 'Normal', 'NormalNC', 'SignColumn', 'StatusLine', 'StatusLineNC', 'EndOfBuffer' }
	for _, group in ipairs(groups) do
		vim.api.nvim_set_hl(0, group, { bg = 'NONE', ctermbg = 'NONE' })
	end
end

function M.list()
	return vim.deepcopy(data.theme_names)
end

function M.saved()
	return storage.read_saved_theme()
end

function M.apply(name, opts)
	opts = opts or {}
	if not data.theme_lookup[name] then
		notify(string.format('Unknown theme: %s', name), vim.log.levels.ERROR)
		return false
	end

	if name == 'oc-2' or name == 'oc-2-noir' then
		pcall(function()
			require('oc2').setup({ theme = name })
		end)
	end

	local ok_colorscheme, err = pcall(vim.cmd.colorscheme, name)
	if not ok_colorscheme then
		notify(string.format('Failed to load %s: %s', name, err), vim.log.levels.ERROR)
		return false
	end

	clear_bg()

	if not opts.silent then
		notify(string.format('Switched to %s', name))
	end

	if opts.persist ~= false then
		local saved, err = storage.save_theme(name)
		if not saved then
			notify(string.format('Switched to %s, but could not save the selection: %s', name, err), vim.log.levels.WARN)
		end
	end

	return true
end

function M.cycle(step)
	return selection.cycle(step)
end

function M.select()
	return selection.select()
end

function M.setup()
	return commands.setup()
end

function M.startup(default_name)
	return selection.startup(default_name)
end

function M.init(default_name)
	M.setup()
	return M.startup(default_name)
end

return M
