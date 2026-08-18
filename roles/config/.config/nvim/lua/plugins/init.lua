local M = {}

local function gh(repo)
	return 'https://github.com/' .. repo
end

function M.setup()
	vim.pack.add({
		-- Themes
		gh('0xleodevv/oc-2.nvim'),
		gh('catppuccin/nvim'),
		gh('EdenEast/nightfox.nvim'),
		gh('folke/tokyonight.nvim'),
		gh('dracula/vim'),
		gh('navarasu/onedark.nvim'),
		gh('idr4n/github-monochrome.nvim'),
		gh('brandsoy/SupaTheme'),
		gh('mryodo/rwth.nvim'),
		-- Plugins
		gh('echasnovski/mini.nvim'),
		gh('nvim-tree/nvim-web-devicons'),
		gh('ibhagwan/fzf-lua'),
		gh('iamcco/markdown-preview.nvim'),
		gh('MeanderingProgrammer/render-markdown.nvim'),
		-- gh('romgrk/barbar.nvim'),
		gh('lewis6991/gitsigns.nvim'),
		gh('norcalli/nvim-colorizer.lua'),
		gh('mikavilpas/yazi.nvim'),
		gh('3rd/image.nvim'),
		gh('joerdav/templ.vim'),
		-- Obsidian
		gh('obsidian-nvim/obsidian.nvim'),
		-- LSP
		gh('nvim-treesitter/nvim-treesitter'),
		gh('neovim/nvim-lspconfig'),
		gh('williamboman/mason.nvim'),
		gh('williamboman/mason-lspconfig.nvim'),
		gh('WhoIsSethDaniel/mason-tool-installer.nvim'),
		gh('stevearc/conform.nvim'),
		gh('b0o/SchemaStore.nvim'),
		gh('seblyng/roslyn.nvim'),
		-- AI
		gh('zbirenbaum/copilot.lua'),
		gh('nvim-lua/plenary.nvim'),
		gh('nvim-neo-tree/neo-tree.nvim'),
		gh('MunifTanjim/nui.nvim'),
		gh('mfussenegger/nvim-lint'),
		gh('atiladefreitas/dooing'),
	}, { confirm = false })

	require('plugins.ui').setup()
	require('plugins.editor_notify').setup()
	require('plugins.editor_lazygit').setup()
	require('plugins.editor_buffers').setup()
	require('plugins.editor_mini').setup()
	require('plugins.finder').setup()
	require('plugins.treesitter').setup()
	require('plugins.roslyn').setup()
	require('plugins.ai').setup()
	require('plugins.lsp').setup()
	require('plugins.markdown').setup()
	require('plugins.git').setup()
	require('plugins.yazi').setup()
	require('plugins.image').setup()
	-- require('plugins.barbar').setup()
	require('plugins.neo-tree').setup()
	require('plugins.lint').setup()
	require('plugins.obsidian').setup()
	require('plugins.dooing').setup()
end

return M
