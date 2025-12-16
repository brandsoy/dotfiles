return {
	{
		"nvim-mini/mini.icons",
		lazy = true,
		config = function()
			require("mini.icons").setup()
			require("mini.icons").mock_nvim_web_devicons()
		end,
	},
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = false,
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				flavour = "auto",
				background = {
					light = "latte",
					dark = "mocha",
				},
				transparent_background = true,
				integrations = {
					blink_cmp = true,
					fzf = true,
					mason = true,
					markdown = true,
					mini = { enabled = true },
					native_lsp = { enabled = true },
					treesitter = true,
					which_key = true,
				},
			})

			vim.cmd.colorscheme("catppuccin")
		end,
	},
	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		dependencies = { "nvim-mini/mini.icons" },
		opts = {
			options = {
				theme = "catppuccin",
				section_separators = { left = "", right = "" },
				component_separators = { left = "", right = "" },
			},
		},
		config = function(_, opts)
			require("lualine").setup(opts)
		end,
	},
}
