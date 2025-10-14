return function()
	-- Add Themes
	vim.pack.add({
		{ src = "https://github.com/catppuccin/nvim" },
		{ src = "https://github.com/Shatur/neovim-ayu" },
		{ src = "https://github.com/nvim-lualine/lualine.nvim" },
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

	-- require("catppuccin").setup({
	-- 	flavour = "mocha", -- latte, frappe, macchiato, mocha
	-- })
	require("ayu").setup({
		mirage = true,
		terminal = true,
		overrides = {},
	})
	vim.cmd("colorscheme ayu")
end
