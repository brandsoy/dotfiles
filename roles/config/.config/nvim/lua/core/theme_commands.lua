local M = {}

local data = require('core.theme_data')
local selection = require('core.theme_selection')

function M.setup()
	if vim.g.theme_commands_loaded then
		return
	end

	vim.g.theme_commands_loaded = true

	vim.api.nvim_create_user_command('Theme', function(command_opts)
		if command_opts.args ~= '' then
			require('core.theme').apply(command_opts.args)
			return
		end
		selection.select()
	end, {
		nargs = '?',
		complete = function(arg_lead)
			return vim.tbl_filter(function(name)
				return name:find(arg_lead, 1, true) == 1
			end, data.theme_names)
		end,
		desc = 'Pick or set colorscheme',
	})

	vim.api.nvim_create_user_command('ThemeNext', function()
		selection.cycle(1)
	end, { desc = 'Switch to next colorscheme' })
	vim.api.nvim_create_user_command('ThemePrev', function()
		selection.cycle(-1)
	end, { desc = 'Switch to previous colorscheme' })
end

return M
