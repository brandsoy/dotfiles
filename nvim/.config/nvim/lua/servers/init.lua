local lsp = require("utils.lsp")
local ok, blink = pcall(require, "blink.cmp")
lsp.capabilities = ok and blink.get_lsp_capabilities() or vim.lsp.protocol.make_client_capabilities()

-- Language Server Protocol (LSP)
local servers = {
	"lua_ls",
	"pyright",
	"gopls",
	"jsonls",
	"ts_ls",
	"bashls",
	"clangd",
	"dockerls",
	"emmet_ls",
	"yamlls",
	"tailwindcss",
	"sqls",
}

for _, server in ipairs(servers) do
	lsp.enable(server)
end

require("servers.roslyn")
