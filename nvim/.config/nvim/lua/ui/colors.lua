return function()
	-- Add Themes
	vim.pack.add({
		{ src = "https://github.com/nvim-lualine/lualine.nvim" },
		{ src = "https://github.com/catppuccin/nvim" },
		{ src = "https://github.com/nvim-mini/mini.icons" },
	})

	require("mini.icons").setup()

	require("catppuccin").setup({
		flavour = "mocha", -- latte, frappe, macchiato, mocha
		integrations = {
			lualine = true,
		},
	})

	require("lualine").setup({
		options = {
			theme = "catppuccin",
		},
	})

	vim.cmd("colorscheme catppuccin-mocha")
end
