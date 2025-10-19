return {
	{
		"nvim-mini/mini.icons",
		lazy = false,
		config = function()
			require("mini.icons").setup()
		end,
	},
	{
		"Shatur/neovim-ayu",
		priority = 1000,
		config = function()
			require("ayu").setup({
				mirage = true,
				terminal = true,
				overrides = {},
			})
			-- vim.cmd.colorscheme("ayu")
		end,
	},
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = true,
	},
	{
		"zenbones-theme/zenbones.nvim",
		dependencies = "rktjmp/lush.nvim",
		lazy = false,
		priority = 1000,
		-- you can set set configuration options here
		config = function()
			vim.g.zenbones_darken_comments = 45
			vim.cmd.colorscheme("zenwritten")
		end,
	},
	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		dependencies = { "nvim-mini/mini.icons" },
		opts = {
			options = {
				theme = "zenwritten",
				section_separators = { left = "", right = "" },
				component_separators = { left = "", right = "" },
			},
		},
		config = function(_, opts)
			require("lualine").setup(opts)
		end,
	},
}
