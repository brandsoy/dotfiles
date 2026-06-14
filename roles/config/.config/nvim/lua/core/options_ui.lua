local M = {}

function M.setup()
	vim.opt.number = true
	vim.opt.relativenumber = true
	vim.opt.cursorline = true
	vim.opt.scrolloff = 10
	vim.opt.sidescrolloff = 8
	vim.opt.wrap = false
	vim.opt.cmdheight = 0
	vim.opt.spelllang = { 'en', 'no' }
	vim.opt.winborder = 'rounded'

	vim.opt.termguicolors = true
	vim.opt.signcolumn = 'yes'
	vim.opt.matchtime = 2
	vim.opt.showmode = false
	vim.opt.laststatus = 3
	vim.opt.pumheight = 10
	vim.opt.pumblend = 10
	vim.opt.winblend = 0
	vim.opt.conceallevel = 1
	vim.opt.concealcursor = ''
	vim.opt.redrawtime = 10000
	vim.opt.maxmempattern = 20000
	vim.opt.synmaxcol = 200

	vim.opt.guicursor = {
		'n-v-c:block',
		'i-ci-ve:block',
		'r-cr:hor20',
		'o:hor50',
		'a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor',
		'sm:block-blinkwait175-blinkoff150-blinkon175',
	}

	vim.opt.fillchars = {
		diff = '╱',
		foldopen = '▾',
		foldclose = '▸',
	}
end

return M
