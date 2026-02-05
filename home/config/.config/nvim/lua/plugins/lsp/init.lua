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
		event = { "BufReadPost", "BufNewFile" },
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
	{
		"smjonas/inc-rename.nvim",
		cmd = "IncRename",
		config = function()
			require("inc_rename").setup()
		end,
	},
	{
		"aznhe21/actions-preview.nvim",
		event = "LspAttach",
		config = function()
			local fzf_ok, fzf = pcall(require, "fzf-lua")
			if fzf_ok then
				require("actions-preview").setup({
					backend = { "fzf" },
				})
			else
				require("actions-preview").setup()
			end
		end,
	},
}
