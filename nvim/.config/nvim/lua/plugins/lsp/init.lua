return {
	{
		"saghen/blink.cmp",
		event = { "InsertEnter", "CmdlineEnter" },
		dependencies = {
			"L3MON4D3/LuaSnip",
			"rafamadriz/friendly-snippets",
		},
		config = function()
			require("config.lsp.completion").setup()
		end,
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"mason-org/mason.nvim",
			"mason-org/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			"folke/neodev.nvim",
			"b0o/SchemaStore.nvim",
		},
		config = function()
			require("config.lsp.servers").setup()
			require("config.lsp.keymaps").setup()
		end,
	},
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre", "BufWritePost" },
		config = function()
			require("config.lsp.formatting").setup_conform()
		end,
	},
	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("config.lsp.formatting").setup_lint()
		end,
	},
}
