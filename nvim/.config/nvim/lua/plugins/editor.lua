return function()
	-- Install editor enhancement plugins
	vim.pack.add({
		{ src = "https://github.com/stevearc/oil.nvim" },
		{ src = "https://github.com/folke/which-key.nvim" },
		{ src = "https://github.com/nvim-tree/nvim-web-devicons" },
	})

	-- Oil file manager
	require("oil").setup()
	vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

	-- Which-key for keymap help
	require("which-key").setup()
	local wk = require("which-key")
	wk.add({
		{ "<leader>m", group = "Markdown" },
		{ "<leader>f", group = "FZF" },
		{ "<leader>l", group = "LSP" },
		{ "<leader>lq", desc = "Diagnostics to Location List" },
		{ "<leader>d", group = "Debug" },
	})
end