return function()
	-- Add Themes
	vim.pack.add({
		{ src = "https://github.com/nvim-lualine/lualine.nvim" },
		{ src = "https://github.com/catppuccin/nvim" },
		{ src = "https://github.com/nvim-mini/mini.icons" },
	})

	require("mini.icons").setup()

	require("lualine").setup({
		options = {
			theme = "ayu_mirage",
			section_separators = { left = "", right = "" },
			component_separators = { left = "", right = "" },
		},
	})

	require("catppuccin").setup({
		flavour = "mocha", -- latte, frappe, macchiato, mocha
	})
	vim.cmd("colorscheme catppuccin-mocha")
end
