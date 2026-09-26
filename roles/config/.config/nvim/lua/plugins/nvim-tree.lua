local M = {}

function M.setup()
	local ok, nvim_tree = pcall(require, 'nvim-tree')
	if not ok then
		return
	end

	nvim_tree.setup({
		view = { width = 35 },
		renderer = { group_empty = true },
		update_focused_file = { enable = true, update_root = false },
		on_attach = function(bufnr)
			local api = require('nvim-tree.api')
			api.config.mappings.default_on_attach(bufnr)
			vim.keymap.set('n', 'P', function()
				local node = api.tree.get_node_under_cursor()
				if not node then
					return
				end

				local path = require('core.clipboard').paste_image_to_dir(node.absolute_path)
				if path then
					api.tree.reload()
				end
			end, { buffer = bufnr, desc = 'Paste image' })
		end,
	})

	local function toggle()
		require('nvim-tree.api').tree.toggle({ find_file = true })
	end

	vim.keymap.set('n', '<leader>e', toggle, { desc = 'Nvim-tree toggle and reveal current file' })
	vim.keymap.set('n', '<leader>E', '<cmd>NvimTreeFocus<cr>', { desc = 'Nvim-tree focus' })
	vim.keymap.set('n', '<leader>fe', toggle, { desc = 'Nvim-tree reveal current file' })
	vim.keymap.set('n', '<leader>be', '<cmd>NvimTreeToggle<cr>', { desc = 'Nvim-tree buffers' })
	vim.keymap.set('n', '<leader>ge', '<cmd>NvimTreeToggle<cr>', { desc = 'Nvim-tree git status' })
end

return M
