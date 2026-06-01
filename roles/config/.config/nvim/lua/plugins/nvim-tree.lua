local M = {}

function M.setup()
	local ok, render = pcall(require, 'nvim-tree')
	if not ok then
		return
	end

	render.setup({
		update_focused_file = {
			enable = true, -- update the tree to focus the file in the current buffer
			update_cwd = false, -- optional: update Neovim cwd on file change
			ignore_list = {}, -- optional: file patterns to ignore
		},
	})
end

return M
