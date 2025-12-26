return {
	{
		"MeanderingProgrammer/render-markdown.nvim",
		ft = { "markdown", "mdx" },
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		},
		opts = {
			completions = { lsp = { enabled = true } },
		},
		config = function(_, opts)
			require("render-markdown").setup(opts)
		end,
	},
}
