local M = {}

function M.setup()
	vim.opt.tabstop = 2
	vim.opt.shiftwidth = 2
	vim.opt.softtabstop = 2
	vim.opt.expandtab = true
	vim.opt.smartindent = true
	vim.opt.grepprg = 'rg --vimgrep'
	vim.opt.grepformat = '%f:%l:%c:%m'

	vim.opt.ignorecase = true
	vim.opt.smartcase = true
	vim.opt.hlsearch = false
	vim.opt.incsearch = true

	vim.opt.iskeyword:append('-')
	vim.opt.path:append('**')
	vim.opt.selection = 'inclusive'
	vim.opt.mouse = 'a'
	vim.opt.clipboard:append('unnamedplus')
	vim.opt.wildmode = 'longest:full,full'
	vim.opt.wildignorecase = true
end

return M
