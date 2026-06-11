local M = {}

local function map(lhs, rhs, desc)
	vim.keymap.set('n', lhs, rhs, { desc = desc })
end

function M.setup()
	local ok, neo_tree = pcall(require, 'neo-tree')
	if not ok then
		return
	end

	neo_tree.setup({})

	map('<leader>e', '<cmd>Neotree toggle<cr>', 'Neo-tree toggle')
	map('<leader>E', '<cmd>Neotree focus<cr>', 'Neo-tree focus')
	map('<leader>fe', '<cmd>Neotree reveal<cr>', 'Neo-tree reveal current file')
	map('<leader>be', '<cmd>Neotree buffers toggle<cr>', 'Neo-tree buffers')
	map('<leader>ge', '<cmd>Neotree git_status toggle<cr>', 'Neo-tree git status')
end

return M
