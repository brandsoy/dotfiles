local M = {}

function M.setup()
	vim.g.cursorline_enabled = vim.g.cursorline_enabled ~= false

	local group = vim.api.nvim_create_augroup('ActiveCursorline', {})
	vim.api.nvim_create_autocmd({ 'WinEnter', 'BufEnter' }, {
		group = group,
		callback = function()
			vim.wo.cursorline = vim.g.cursorline_enabled
		end,
	})
	vim.api.nvim_create_autocmd({ 'WinLeave' }, {
		group = group,
		callback = function()
			vim.wo.cursorline = false
		end,
	})
end

return M
