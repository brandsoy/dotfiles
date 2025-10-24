return {
	{
		"stevearc/oil.nvim",
		cmd = "Oil",
		keys = {
			{ "-", "<CMD>Oil<CR>", desc = "Open parent directory" },
		},
		opts = {},
		config = function(_, opts)
			require("oil").setup(opts)
		end,
	},
	{
		"nvim-mini/mini.bufremove",
		lazy = false,
		config = function()
			require("mini.bufremove").setup()
		end,
	},
	{
		"nvim-mini/mini.ai",
		event = "VeryLazy",
		config = function()
			require("mini.ai").setup()
		end,
	},
	{
		"nvim-mini/mini.move",
		event = "VeryLazy",
		opts = {
			mappings = {
				down = "<A-j>",
				up = "<A-k>",
				line_down = "<A-j>",
				line_up = "<A-k>",
			},
		},
		config = function(_, opts)
			require("mini.move").setup(opts)
		end,
	},
	{
		"nvim-mini/mini.pairs",
		event = "InsertEnter",
		opts = {
			modes = { insert = true, command = false, terminal = false },
		},
		config = function(_, opts)
			require("mini.pairs").setup(opts)
		end,
	},
	{
		"nvim-mini/mini.notify",
		lazy = false,
		config = function()
			require("mini.notify").setup({})
		end,
	},

	{
		"nvim-mini/mini.diff",
		version = false,
		config = function()
			require("mini.notify").setup({})
		end,
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		config = function()
			require("which-key").setup()
			local wk = require("which-key")
			wk.add({
				{ "<leader>b", group = "Buffers" },
				{ "<leader>d", group = "Debug" },
				{ "<leader>f", group = "Find" },
				{ "<leader>l", group = "LSP" },
				{ "<leader>lq", desc = "Diagnostics to Location List" },
				{ "<leader>m", group = "Markdown" },
				{ "<leader>uh", desc = "Notification history" },
				{ "<leader>q", group = "Quit" },
				{ "<leader>s", group = "Splits" },
				{ "<leader>u", group = "Toggles" },
				{ "<leader>w", group = "Write" },
			})
		end,
	},
}
