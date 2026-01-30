return {
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPost", "BufNewFile" },
		opts = {
			signs = {
				add = { text = "│" },
				change = { text = "│" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
				untracked = { text = "┆" },
			},
			current_line_blame = false, -- Toggle with keybind
			current_line_blame_opts = {
				virt_text = true,
				virt_text_pos = "eol",
				delay = 300,
				ignore_whitespace = false,
			},
			current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
		},
		keys = {
			{ "<leader>gb", "<cmd>Gitsigns toggle_current_line_blame<cr>", desc = "Toggle git blame" },
			{ "<leader>gB", "<cmd>Gitsigns blame_line<cr>", desc = "Git blame line" },
			{ "<leader>gd", "<cmd>Gitsigns diffthis<cr>", desc = "Git diff" },
			{ "<leader>gp", "<cmd>Gitsigns preview_hunk<cr>", desc = "Preview hunk" },
			{ "<leader>gr", "<cmd>Gitsigns reset_hunk<cr>", desc = "Reset hunk" },
			{ "<leader>gs", "<cmd>Gitsigns stage_hunk<cr>", desc = "Stage hunk" },
			{ "<leader>gu", "<cmd>Gitsigns undo_stage_hunk<cr>", desc = "Undo stage hunk" },
			{ "]h", "<cmd>Gitsigns next_hunk<cr>", desc = "Next hunk" },
			{ "[h", "<cmd>Gitsigns prev_hunk<cr>", desc = "Previous hunk" },
		},
		config = function(_, opts)
			require("gitsigns").setup(opts)
		end,
	},
}
