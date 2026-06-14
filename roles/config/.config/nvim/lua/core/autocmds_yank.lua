local M = {}

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
		end,
	})
end

return M
