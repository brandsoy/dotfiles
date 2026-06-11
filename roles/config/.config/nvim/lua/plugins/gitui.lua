local M = {}

function M.setup()
	local ok, gitui = pcall(require, 'nvim-gitui')
	if not ok then
		return
	end

	gitui.setup({
		keymaps = {
			n = '<leader>gu',
		},
		window = {
			width = 0.9,
			height = 0.9,
			border = 'rounded',
		},
	})

	vim.keymap.set('n', '<leader>gu', gitui.open_gitui, { desc = 'GitUI' })
end

return M
