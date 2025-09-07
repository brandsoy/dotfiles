return function()
	-- Add Themes
	vim.pack.add({
		{ src = "https://github.com/rose-pine/neovim" },
	})
	-- Apply Theme
	vim.cmd("colorscheme rose-pine")
end
