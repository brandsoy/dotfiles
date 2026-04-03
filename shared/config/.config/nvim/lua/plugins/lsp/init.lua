local M = {}

function M.setup()
	require("config.lsp.completion").setup()
	require("config.lsp.servers").setup()
	require("config.lsp.keymaps").setup()
	require("config.lsp.formatting").setup_conform()
end

return M
