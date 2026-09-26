local M = {}

function M.setup()
	require('core.keymaps_general').setup()
	require('core.keymaps_markdown').setup()
	require('core.keymaps_terminal').setup()
end

return M
