local M = {}

function M.setup()
	require('core.autocmds_cursor').setup()
	require('core.autocmds_yank').setup()
	require('core.autocmds_largefile').setup()
	require('core.autocmds_cursorline').setup()
end

return M
