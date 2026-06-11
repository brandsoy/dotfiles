local M = {}

local function map(mode, lhs, rhs, desc)
	vim.keymap.set(mode, lhs, rhs, { desc = desc })
end

function M.setup()
	local ok, obsidian = pcall(require, 'obsidian')
	if not ok then
		return
	end

	obsidian.setup({
		legacy_commands = false,
		picker = {
			name = 'fzf-lua',
		},
		workspaces = {
			{ name = 'Personal', path = '~/Obsidian/Personal' },
			{ name = 'Work', path = '~/Obsidian/Work' },
		},
		templates = {
			folder = 'Templates',
			date_format = '%Y-%m-%d-%a',
			time_format = '%H:%M',
		},
	})

	map('n', '<leader>oo', ':Obsidian ', 'Obsidian commands')
	map('n', '<leader>oO', '<cmd>Obsidian open<cr>', 'Obsidian open in app')
	map('n', '<leader>oC', '<cmd>Obsidian check<cr>', 'Obsidian check')
	map('n', '<leader>od', '<cmd>Obsidian dailies<cr>', 'Obsidian dailies')
	map('n', '<leader>oh', '<cmd>Obsidian help<cr>', 'Obsidian help')
	map('n', '<leader>oH', '<cmd>Obsidian helpgrep<cr>', 'Obsidian help grep')
	map('n', '<leader>on', '<cmd>Obsidian new<cr>', 'Obsidian new note')
	map(
		'n',
		'<leader>oN',
		'<cmd>Obsidian new_from_template<cr>',
		'Obsidian new from template'
	)
	map('n', '<leader>ot', '<cmd>Obsidian today<cr>', 'Obsidian today')
	map('n', '<leader>oT', '<cmd>Obsidian tomorrow<cr>', 'Obsidian tomorrow')
	map('n', '<leader>oy', '<cmd>Obsidian yesterday<cr>', 'Obsidian yesterday')
	map(
		'n',
		'<leader>oq',
		'<cmd>Obsidian quick_switch<cr>',
		'Obsidian quick switch'
	)
	map('n', '<leader>os', '<cmd>Obsidian search<cr>', 'Obsidian search')
	map('n', '<leader>oS', '<cmd>Obsidian sync<cr>', 'Obsidian sync')
	map('n', '<leader>oa', '<cmd>Obsidian tags<cr>', 'Obsidian tags')
	map(
		'n',
		'<leader>oU',
		'<cmd>Obsidian unique_note<cr>',
		'Obsidian unique note'
	)
	map('n', '<leader>ow', '<cmd>Obsidian workspace<cr>', 'Obsidian workspace')

	map('n', '<leader>ob', '<cmd>Obsidian backlinks<cr>', 'Obsidian backlinks')
	map(
		'n',
		'<leader>of',
		'<cmd>Obsidian follow_link<cr>',
		'Obsidian follow link'
	)
	map('n', '<leader>oz', '<cmd>Obsidian toc<cr>', 'Obsidian table of contents')
	map(
		'n',
		'<leader>om',
		'<cmd>Obsidian template<cr>',
		'Obsidian insert template'
	)
	map('n', '<leader>ol', '<cmd>Obsidian links<cr>', 'Obsidian links')
	map('n', '<leader>op', '<cmd>Obsidian paste_img<cr>', 'Obsidian paste image')
	map('n', '<leader>or', '<cmd>Obsidian rename<cr>', 'Obsidian rename note')
	map(
		'n',
		'<leader>ox',
		'<cmd>Obsidian toggle_checkbox<cr>',
		'Obsidian toggle checkbox'
	)

	map(
		'x',
		'<leader>oe',
		':<C-u>Obsidian extract_note<cr>',
		'Obsidian extract note'
	)
	map('x', '<leader>ol', ':<C-u>Obsidian link<cr>', 'Obsidian link selection')
	map(
		'x',
		'<leader>oL',
		':<C-u>Obsidian link_new<cr>',
		'Obsidian link new note'
	)
end

return M
