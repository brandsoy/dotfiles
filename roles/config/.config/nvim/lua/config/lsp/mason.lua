local M = {}

function M.setup()
	local mason_ok, mason = pcall(require, 'mason')
	if not mason_ok then
		return
	end

	mason.setup({
		registries = require('config.lsp.mason_registries').get(),
	})

	local mlsp_ok, mason_lspconfig = pcall(require, 'mason-lspconfig')
	if mlsp_ok then
		mason_lspconfig.setup({
			automatic_enable = false,
			ensure_installed = require('config.lsp.mason_servers').get(),
		})
	end

	local mti_ok, mason_tool_installer = pcall(require, 'mason-tool-installer')
	if mti_ok then
		mason_tool_installer.setup({
			ensure_installed = require('config.lsp.mason_tools').get(),
			run_on_start = true,
		})
	end
end

return M
