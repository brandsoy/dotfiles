return function()
	-- Install editor enhancement plugins
	vim.pack.add({
		{ src = "https://github.com/stevearc/oil.nvim" },
		{ src = "https://github.com/folke/which-key.nvim" },
		{ src = "https://github.com/nvim-mini/mini.bufremove" },
		{ src = "https://github.com/nvim-mini/mini.pairs" },
		{ src = "https://github.com/rcarriga/nvim-notify" },
		{ src = "https://github.com/nvim-mini/mini.ai" },
		{ src = "https://github.com/nvim-mini/mini.move" },
		{ src = "https://github.com/nvim-mini/mini.notify" },
	})

	-- Oil file manager
	require("oil").setup()
	vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

	-- Buffer remove helper
	require("mini.bufremove").setup()

	require("mini.ai").setup()

	require("mini.move").setup({
		mappings = {
			down = "<A-j>",
			up = "<A-k>",
			line_down = "<A-j>",
			line_up = "<A-k>",
		},
	})

	-- Autopairs
	require("mini.pairs").setup({
		modes = { insert = true, command = false, terminal = false },
	})

	require("mini.notify").setup({})

	-- Which-key for keymap help
	require("which-key").setup()
	local wk = require("which-key")
	wk.add({
		{ "<leader>b", group = "Buffers" },
		{ "<leader>d", group = "Debug" },
		{ "<leader>f", group = "Find" },
		{ "<leader>l", group = "LSP" },
		{ "<leader>lq", desc = "Diagnostics to Location List" },
		{ "<leader>m", group = "Markdown" },
		{ "<leader>q", group = "Quit" },
		{ "<leader>s", group = "Splits" },
		{ "<leader>u", group = "Toggles" },
		{ "<leader>w", group = "Write" },
	})

	-- Notifications
	local notify = require("notify")
	notify.setup({
		background_colour = "#1f1f28",
		stages = "fade_in_slide_out",
		timeout = 2000,
		render = "compact",
	})
	vim.notify = notify
end
