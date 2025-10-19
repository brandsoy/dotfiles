return {
	{
		"MeanderingProgrammer/render-markdown.nvim",
		ft = { "markdown", "mdx" },
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
		opts = {
			completions = { lsp = { enabled = true } },
		},
		config = function(_, opts)
			require("render-markdown").setup(opts)
		end,
	},
}
