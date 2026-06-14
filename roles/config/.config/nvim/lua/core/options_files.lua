local M = {}

function M.setup()
	vim.opt.backup = false
	vim.opt.writebackup = false
	vim.opt.swapfile = false
	vim.opt.undofile = true
	vim.opt.updatetime = 200
	vim.opt.timeoutlen = 500
	vim.opt.ttimeoutlen = 0
	vim.opt.autoread = true
	vim.opt.autowrite = false
	vim.opt.diffopt:append('vertical')
	vim.opt.diffopt:append('algorithm:patience')
	vim.opt.diffopt:append('linematch:60')

	local undodir_path = vim.fn.stdpath('state') .. '/undo'
	vim.opt.undodir = undodir_path
	if vim.fn.isdirectory(undodir_path) == 0 then
		vim.fn.mkdir(undodir_path, 'p')
	end
end

return M
