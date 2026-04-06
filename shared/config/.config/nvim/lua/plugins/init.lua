local M = {}

local function gh(repo)
	return "https://github.com/" .. repo
end

function M.setup()
	vim.pack.add({
		gh("0xleodevv/oc-2.nvim"),
		gh("folke/tokyonight.nvim"),
		gh("echasnovski/mini.nvim"),
		gh("ibhagwan/fzf-lua"),
		gh("nvim-treesitter/nvim-treesitter"),
		gh("neovim/nvim-lspconfig"),
		gh("stevearc/conform.nvim"),
		gh("b0o/SchemaStore.nvim"),
		gh("seblyng/roslyn.nvim"),
		gh("zbirenbaum/copilot.lua"),
		gh("MeanderingProgrammer/render-markdown.nvim"),
		gh("lewis6991/gitsigns.nvim"),
	}, { confirm = false })

	require("plugins.ui").setup()
	require("plugins.editor").setup()
	require("plugins.finder").setup()
	require("plugins.treesitter").setup()
	require("plugins.roslyn").setup()
	require("plugins.ai").setup()
	require("plugins.lsp").setup()
	require("plugins.markdown").setup()
	require("plugins.git").setup()
end

return M
