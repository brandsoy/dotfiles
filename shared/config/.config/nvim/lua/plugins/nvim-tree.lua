local M = {}

function M.setup()
	local ok, render = pcall(require, 'nvim-tree')
	if not ok then
		return
	end

	render.setup()
end

return M
