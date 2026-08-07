local M = {}

local function map(lhs, rhs, desc)
	vim.keymap.set('n', lhs, rhs, { desc = desc })
end

function M.setup()
	local ok, neo_tree = pcall(require, 'neo-tree')
	if not ok then
		return
	end

	neo_tree.setup({
		filesystem = {
			window = {
				mappings = {
					['P'] = function(state)
						local node = state.tree:get_node()
						if not node or not node.path then
							return
						end

						local dir = vim.fn.isdirectory(node.path) == 1 and node.path or vim.fn.fnamemodify(node.path, ':h')
						local path = require('core.clipboard').paste_image_to_dir(dir)
						if path then
							require('neo-tree.sources.manager').refresh(state.name)
						end
					end,
				},
			},
		},
	})

	map('<leader>e', '<cmd>Neotree toggle<cr>', 'Neo-tree toggle')
	map('<leader>E', '<cmd>Neotree focus<cr>', 'Neo-tree focus')
	map('<leader>fe', '<cmd>Neotree reveal<cr>', 'Neo-tree reveal current file')
	map('<leader>be', '<cmd>Neotree buffers toggle<cr>', 'Neo-tree buffers')
	map('<leader>ge', '<cmd>Neotree git_status toggle<cr>', 'Neo-tree git status')
end

return M
