return {
	{
		"saghen/blink.cmp",
		event = { "InsertEnter", "CmdlineEnter" },
		config = function()
			require("config.lsp.completion").setup()
		end,
	},
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"mason-org/mason.nvim",
			"mason-org/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			{ "folke/lazydev.nvim", ft = "lua", opts = {} },
			"b0o/SchemaStore.nvim",
		},
		config = function()
			require("config.lsp.servers").setup()
			require("config.lsp.keymaps").setup()
		end,
	},
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
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
