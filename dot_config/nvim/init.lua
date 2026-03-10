if vim.loader then vim.loader.enable() end
require("core")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	spec = {
		{ import = "plugins" },
	},
	defaults = { lazy = true },
	checker = { enabled = false },
	change_detection = { notify = false },
	rocks = {
		enabled = false, -- Disable luarocks support (not needed for any plugins)
	},
	performance = {
		rtp = {
			reset = true, -- reset the runtime path to $VIMRUNTIME and your config directory
		},
	},
})
