local M = {}

function M.setup()
	vim.opt.autochdir = false
	vim.opt.foldmethod = 'indent'
	vim.opt.foldlevel = 99
	vim.opt.splitbelow = true
	vim.opt.splitright = true
end

return M
