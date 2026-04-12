local M = {}

local function gh(repo)
	return "https://github.com/" .. repo
end

function M.setup()
	vim.pack.add({
    -- Themes
		gh("0xleodevv/oc-2.nvim"),
		gh("catppuccin/nvim"),
		gh("EdenEast/nightfox.nvim"),
		gh("folke/tokyonight.nvim"),
    -- Plugins
		gh("echasnovski/mini.nvim"),
		gh("ibhagwan/fzf-lua"),
    -- LSP
		gh("nvim-treesitter/nvim-treesitter"),
		gh("neovim/nvim-lspconfig"),
		gh("stevearc/conform.nvim"),
		gh("b0o/SchemaStore.nvim"),
		gh("seblyng/roslyn.nvim"),
		gh("zbirenbaum/copilot.lua"),
		gh("MeanderingProgrammer/render-markdown.nvim"),
		gh("lewis6991/gitsigns.nvim"),
		gh("mikavilpas/yazi.nvim"),
		gh("nvim-lua/plenary.nvim"),
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
	require("plugins.yazi").setup()
end

return M
