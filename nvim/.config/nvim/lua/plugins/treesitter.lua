return function()
	-- Install Treesitter
	vim.pack.add({
		{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
	})

	require("nvim-treesitter.configs").setup({
		ensure_installed = {
			"bash",
			"css",
			"dockerfile",
			"go",
			"gomod",
			"gosum",
			"gotmpl",
			"html",
			"javascript",
			"json",
			"lua",
			"markdown",
			"markdown_inline",
			"python",
			"svelte",
			"typescript",
			"vue",
			"yaml",
			"vim",
			"vimdoc",
		},
		sync_install = true,
		auto_install = true,
		ignore_install = {},
		modules = {},
		highlight = {
			enable = true,
			additional_vim_regex_highlighting = false,
		},
		indent = { enable = true },
		incremental_selection = {
			enable = true,
			keymaps = {
				init_selection = "<C-space>",
				node_incremental = "<C-space>",
				scope_incremental = "<C-s>",
				node_decremental = "<BS>",
			},
		},
	})
end

