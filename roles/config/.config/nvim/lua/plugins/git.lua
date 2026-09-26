local M = {}

function M.setup()
	local ok, gitsigns = pcall(require, 'gitsigns')
	if ok then
		gitsigns.setup({
			signs = {
				add = { text = '|' },
				change = { text = '|' },
				delete = { text = '_' },
				topdelete = { text = '-' },
				changedelete = { text = '~' },
			},
			current_line_blame = false,
			on_attach = function(bufnr)
				local bt = vim.bo[bufnr].buftype
				if bt ~= '' and bt ~= 'acwrite' then
					return false
				end

				local ft = vim.bo[bufnr].filetype
				if ft == 'checkhealth' then
					return false
				end

				local name = vim.api.nvim_buf_get_name(bufnr)
				if name:match('^health://') then
					return false
				end

				return true
			end,
		})
	end

	local diffview_ok, diffview = pcall(require, 'diffview')
	if diffview_ok then
		diffview.setup({})
	end

	vim.keymap.set('n', '<leader>dv', '<cmd>DiffviewOpen<cr>', { desc = 'Open Diffview' })
	vim.keymap.set('n', '<leader>dx', '<cmd>DiffviewClose<cr>', { desc = 'Close Diffview' })
	vim.keymap.set('n', '<leader>dh', '<cmd>DiffviewFileHistory %<cr>', { desc = 'File history' })
	vim.keymap.set('n', '<leader>co', '<cmd>diffget //2<cr>', { desc = 'Conflict: choose ours' })
	vim.keymap.set('n', '<leader>ct', '<cmd>diffget //3<cr>', { desc = 'Conflict: choose theirs' })

	vim.keymap.set(
		'n',
		'<leader>gb',
		'<cmd>Gitsigns toggle_current_line_blame<cr>',
		{ desc = 'Toggle git blame' }
	)
	vim.keymap.set(
		'n',
		'<leader>gd',
		'<cmd>Gitsigns diffthis<cr>',
		{ desc = 'Git diff' }
	)
	vim.keymap.set(
		'n',
		']h',
		'<cmd>Gitsigns next_hunk<cr>',
		{ desc = 'Next hunk' }
	)
	vim.keymap.set(
		'n',
		'[h',
		'<cmd>Gitsigns prev_hunk<cr>',
		{ desc = 'Previous hunk' }
	)
end

return M
