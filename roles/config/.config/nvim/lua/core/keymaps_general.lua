local M = {}

local function map(mode, lhs, rhs, desc, opts)
	local options = { silent = true, desc = desc }
	if opts then
		options = vim.tbl_extend('force', options, opts)
	end
	vim.keymap.set(mode, lhs, rhs, options)
end

local function notify_option(label, enabled)
	if not vim.notify then
		return
	end
	vim.notify(
		string.format('%s %s', label, enabled and 'enabled' or 'disabled'),
		vim.log.levels.INFO,
		{ title = 'Neovim' }
	)
end

function M.setup()
	map('n', '<leader>', '<nop>', 'Disable bare leader key')

	map('n', 'n', 'nzzzv', 'Next search result (centered)')
	map('n', 'N', 'Nzzzv', 'Previous search result (centered)')
	map('n', '<C-d>', '<C-d>zz', 'Half page down (centered)')
	map('n', '<C-u>', '<C-u>zz', 'Half page up (centered)')

	map('n', '<leader><leader>', '<Cmd>b#<CR>', 'Switch to last buffer')
	map('n', '<leader>h', '<Cmd>nohlsearch<CR>', 'Clear search highlight')

	map('n', '<leader>bn', '<Cmd>bnext<CR>', 'Next buffer')
	map('n', '<leader>bp', '<Cmd>bprevious<CR>', 'Previous buffer')
	map('n', '<leader>br', '<Cmd>edit!<CR>', 'Revert buffer from disk')

	map('n', '<leader>qn', '<Cmd>cnext<CR>', 'Next quickfix item')
	map('n', '<leader>qp', '<Cmd>cprevious<CR>', 'Previous quickfix item')
	map('n', '<leader>qo', '<Cmd>copen<CR>', 'Open quickfix list')
	map('n', '<leader>qc', '<Cmd>cclose<CR>', 'Close quickfix list')
	map('n', ']q', '<Cmd>cnext<CR>', 'Next quickfix item')
	map('n', '[q', '<Cmd>cprevious<CR>', 'Previous quickfix item')

	map('n', '<C-h>', '<C-w>h', 'Move to left window')
	map('n', '<C-j>', '<C-w>j', 'Move to bottom window')
	map('n', '<C-k>', '<C-w>k', 'Move to top window')
	map('n', '<C-l>', '<C-w>l', 'Move to right window')

	map('n', '<leader>sv', '<Cmd>vsplit<CR>', 'Split window vertically')
	map('n', '<leader>sh', '<Cmd>split<CR>', 'Split window horizontally')
	map('n', '<leader>sx', '<Cmd>close<CR>', 'Close current window')
	map('n', '<leader>se', '<C-w>=', 'Equalize window sizes')
	map('n', '<C-Up>', '<Cmd>resize +2<CR>', 'Increase window height')
	map('n', '<C-Down>', '<Cmd>resize -2<CR>', 'Decrease window height')
	map('n', '<C-Left>', '<Cmd>vertical resize -2<CR>', 'Decrease window width')
	map('n', '<C-Right>', '<Cmd>vertical resize +2<CR>', 'Increase window width')

	map('n', 'J', 'mzJ`z', 'Join lines and keep cursor position')

	map('n', '<leader>rc', function()
		vim.cmd.edit(vim.fn.fnameescape(vim.fs.joinpath(vim.fn.stdpath('config'), 'init.lua')))
	end, 'Edit Neovim config')

	map('n', '<leader>ww', '<Cmd>write<CR>', 'Save current buffer')
	map('n', '<leader>wa', '<Cmd>wall<CR>', 'Save all buffers')
	map('n', '<leader>wq', '<Cmd>wq<CR>', 'Save and quit window')
	map('n', '<leader>qq', '<Cmd>confirm qall<CR>', 'Quit Neovim')
	map('n', '<leader>qQ', '<Cmd>qall!<CR>', 'Force quit Neovim')

	map({ 'n', 'v' }, '<leader>y', '"+y', 'Yank to system clipboard')
	map('n', '<leader>Y', '"+Y', 'Yank line to system clipboard')
	map({ 'n', 'v' }, '<leader>p', '"+p', 'Paste from system clipboard')
	map('n', '<leader>fy', function()
		require('core.yank_history').pick()
	end, 'Pick from yank history')

	map('n', '<leader>un', function()
		vim.wo.relativenumber = not vim.wo.relativenumber
		notify_option('Relative number', vim.wo.relativenumber)
	end, 'Toggle relative line numbers')

	map('n', '<leader>uc', function()
		vim.g.cursorline_enabled = not vim.g.cursorline_enabled
		vim.wo.cursorline = vim.g.cursorline_enabled
		notify_option('Cursor line', vim.g.cursorline_enabled)
	end, 'Toggle cursor line')

	map('n', '<leader>uw', function()
		vim.wo.wrap = not vim.wo.wrap
		notify_option('Line wrap', vim.wo.wrap)
	end, 'Toggle soft wrap')

	map('n', '<leader>us', function()
		vim.wo.spell = not vim.wo.spell
		notify_option('Spell check', vim.wo.spell)
	end, 'Toggle spell checking')

	map('n', '<leader>ut', function()
		require('core.theme').select()
	end, 'Pick theme')

	map('n', '<leader>uT', function()
		require('core.theme').cycle(1)
	end, 'Next theme')

	map('n', '<leader>ldv', '<cmd>vsplit | lua vim.lsp.buf.definition()<cr>', 'LSP: definition in vsplit')
	map('n', '<leader>ldh', '<cmd>split | lua vim.lsp.buf.definition()<cr>', 'LSP: definition in split')

	map('n', 'gx', function()
		local file = vim.fn.expand('<cWORD>')
		file = file:gsub('^%!%[%[', ''):gsub('^%[%[', ''):gsub('%]%]$', '')
		file = file:gsub('^%(', ''):gsub('%)$', '')

		local clipboard = require('core.clipboard')
		local current_dir = vim.fn.expand('%:p:h')
		local locations = clipboard.attachment_candidates(current_dir, file)

		local found_path = nil
		for _, path in ipairs(locations) do
			if vim.fn.filereadable(path) == 1 then
				found_path = path
				break
			end
		end

		if found_path then
			vim.ui.open(found_path)
		elseif file:match('^https?://') then
			vim.ui.open(file)
		else
			print('File not found in current dir or attachments: ' .. file)
		end
	end, 'Open embedded PDF or Wiki-link')

	map('v', '<leader>', '<nop>', 'Disable bare leader key')
	map('v', '<', '<gv', 'Indent left and reselect')
	map('v', '>', '>gv', 'Indent right and reselect')

	map('v', '<leader>mw', function()
		local s = vim.fn.getreg('v')
		vim.cmd([[normal! gv]])
		vim.cmd([[normal! c[]()]])
		vim.api.nvim_put({ s }, 'c', true, true)
		vim.cmd([[normal! F[a]])
	end, 'Wrap selection in markdown link')

	map('n', '<Leader>di"', '"_di"', 'Delete inner without yanking')
	map('n', '<Leader>ci"', '"_ci"', 'Change inner without yanking')
end

return M
