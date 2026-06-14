local M = {}

function M.setup()
	require('core.options_ui').setup()
	require('core.options_editing').setup()
	require('core.options_files').setup()
	require('core.options_behavior').setup()
end

return M
