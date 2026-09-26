local M = {}
local yank_history = require('core.yank_history')

function M.setup()
	local group = vim.api.nvim_create_augroup('HighlightYank', {})
	vim.api.nvim_create_autocmd('TextYankPost', {
		group = group,
		pattern = '*',
		callback = function()
			vim.hl.on_yank({
				higroup = 'IncSearch',
				timeout = 200,
			})

			yank_history.record()
		end,
	})
end

return M
