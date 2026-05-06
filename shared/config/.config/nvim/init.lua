if vim.loader then vim.loader.enable() end
require("core")

require("plugins").setup()

local node_host = vim.fn.exepath("neovim-node-host")
if node_host ~= "" then
	vim.g.node_host_prog = node_host
else
	vim.g.loaded_node_provider = 0
end

local python3_host = vim.fn.exepath("python3")
if python3_host ~= "" then
	vim.g.python3_host_prog = python3_host
else
	vim.g.loaded_python3_provider = 0
end
