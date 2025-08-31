-- ================================================================================================
-- TITLE : nvim-lspconfig
-- ABOUT : Quickstart configurations for the built-in Neovim LSP client.
-- LINKS :
--   > github                  : https://github.com/neovim/nvim-lspconfig
--   > mason.nvim (dep)        : https://github.com/mason-org/mason.nvim
--   > blink.cmp  (dep)        : https://github.com/Saghen/blink.cmp
-- ================================================================================================

return {
	"neovim/nvim-lspconfig",
	dependencies = {
		{
			"mason-org/mason.nvim",
			opts = {
				registries = {
					"github:mason-org/mason-registry",
					"github:Crashdummyy/mason-registry",
				},
			},
		},
		"mason-org/mason-lspconfig.nvim",
    "saghen/blink.cmp"
	},
	config = function()
		require("utils.diagnostics").setup()
		require("servers")

		-- Auto-install LSP servers via mason
		local mason_lspconfig = require("mason-lspconfig")
		mason_lspconfig.setup({
			ensure_installed = {
				"lua_ls", "pyright", "gopls", "jsonls", "ts_ls",
				"bashls", "clangd", "dockerls", "emmet_ls", "yamlls", "tailwindcss", "sqls"
			},
			automatic_installation = true,
		})
	end,
}
