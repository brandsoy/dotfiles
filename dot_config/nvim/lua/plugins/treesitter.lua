return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
		opts = {
			ensure_installed = {
				"bash",
				"zsh",
				"dockerfile",
				"go",
				"dotnet",
				"gomod",
				"hcl",
				"html",
				"javascript",
				"json",
				"lua",
				"markdown",
				"markdown_inline",
				"terraform",
				"typescript",
				"svelte",
				"yaml",
				"toml",
				"vim",
				"vimdoc",
				"tailwindcss",
			},
			sync_install = false,
			auto_install = true, -- Auto-install missing parsers
			highlight = {
				enable = true,
				disable = function(lang, buf)
					if vim.b[buf].large_file then
						return true
					end
					-- Disable for very long lines
					local max_filesize = 100 * 1024 -- 100 KB
					local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
					if ok and stats and stats.size > max_filesize then
						return true
					end
				end,
				additional_vim_regex_highlighting = false,
			},
			indent = {
				enable = true,
				disable = { "python", "yaml" }, -- These have known issues
			},
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<C-space>",
					node_incremental = "<C-space>",
					scope_incremental = "<C-s>",
					node_decremental = "<BS>",
				},
			},
		},
	},
}
