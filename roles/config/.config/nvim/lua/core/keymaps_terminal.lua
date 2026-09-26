local M = {}

local function map(mode, lhs, rhs, desc, opts)
	local options = { silent = true, desc = desc }
	if opts then
		options = vim.tbl_extend('force', options, opts)
	end
	vim.keymap.set(mode, lhs, rhs, options)
end

function M.setup()
	map('i', 'jk', [[<C-\><C-n>]], 'Exit insert mode')

	map('t', '<Esc>', [[<C-\><C-n>]], 'Exit terminal mode')
	map('t', '<C-h>', [[<C-\><C-n><C-w>h]], 'Terminal: move to left window')
	map('t', '<C-j>', [[<C-\><C-n><C-w>j]], 'Terminal: move to bottom window')
	map('t', '<C-k>', [[<C-\><C-n><C-w>k]], 'Terminal: move to top window')
	map('t', '<C-l>', [[<C-\><C-n><C-w>l]], 'Terminal: move to right window')
end

return M
