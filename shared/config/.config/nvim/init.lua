if vim.loader then vim.loader.enable() end
require("core")

require("plugins").setup()

local node_host = vim.fn.exepath("neovim-node-host")
if node_host ~= "" then
	vim.g.node_host_prog = node_host
else
	vim.g.loaded_node_provider = 0
end
