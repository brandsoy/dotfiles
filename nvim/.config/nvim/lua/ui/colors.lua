return function()
	-- Add Themes
	vim.pack.add({
		{ src = "https://github.com/rose-pine/neovim" },
		{ src = "https://github.com/Mofiqul/adwaita.nvim" },
		{ src = "https://github.com/projekt0n/github-nvim-theme" },
		{ src = "https://github.com/folke/tokyonight.nvim" },
		{ src = "https://github.com/catppuccin/nvim" },
	})

	-- -- Adawita specific
	-- vim.g.adwaita_darker = true -- for darker version
	-- vim.g.adwaita_disable_cursorline = true -- to disable cursorline
	-- vim.g.adwaita_transparent = false -- makes the background transparent
	-- vim.cmd([[colorscheme adwaita]])

	-- vim.cmd("colorscheme rose-pine")
	-- vim.cmd("colorscheme github_dark_tritanopia")

	vim.cmd("colorscheme catppuccin-mocha")

	-- colorscheme tokyonight
	-- colorscheme tokyonight-night
	-- colorscheme tokyonight-storm
	-- colorscheme tokyonight-day
	-- colorscheme tokyonight-moon
	-- vim.cmd("colorscheme tokyonight-night")
end
