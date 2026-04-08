local M = {}

function M.setup()
	local ok, ts = pcall(require, "nvim-treesitter.configs")
	if not ok then
		return
	end

	ts.setup({
		ensure_installed = {
			"bash",
			"zsh",
			"dockerfile",
			"go",
			"gomod",
			"c_sharp",
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
		},
		auto_install = true,
		highlight = { enable = true, additional_vim_regex_highlighting = false },
		indent = { enable = true, disable = { "python", "yaml" } },
	})
end

return M
