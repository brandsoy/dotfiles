return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
		opts = {
			ensure_installed = {
				"bash",
				"dockerfile",
				"go",
				"gomod",
				"html",
				"javascript",
				"json",
				"lua",
				"markdown",
				"markdown_inline",
				"typescript",
				"yaml",
				"vim",
				"vimdoc",
				"bicep",
			},
			sync_install = false,
			auto_install = false,
			highlight = {
				enable = true,
				disable = function(lang, buf)
					return vim.b[buf].large_file
				end,
				additional_vim_regex_highlighting = false,
			},
			indent = { enable = true },
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<C-space>",
					node_incremental = "<C-space>",
					scope_incremental = "<C-s>",
					node_decremental = "<BS>",
				},
			},
		},
		config = function(_, opts)
			require("nvim-treesitter.configs").setup(opts)
		end,
	},
}
