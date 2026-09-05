local M = {}

local function gh(repo)
	return 'https://github.com/' .. repo
end

function M.setup()
	vim.api.nvim_create_autocmd('PackChanged', {
		callback = function(event)
			local data = event.data
			if
				data.spec.name ~= 'markdown-preview.nvim'
				or not vim.tbl_contains({ 'install', 'update' }, data.kind)
			then
				return
			end

			local result = vim
				.system({ 'npm', 'install', '--no-audit', '--no-fund' }, {
					cwd = vim.fs.joinpath(data.path, 'app'),
				})
				:wait()
			if result.code ~= 0 then
				vim.notify(
					'Failed to install markdown-preview dependencies',
					vim.log.levels.ERROR
				)
			end
		end,
	})

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
		gh('abecodes/tabout.nvim'),
		{
			src = gh('folke/which-key.nvim'),
			version = vim.version.range('3'),
		},
		gh('nvim-tree/nvim-web-devicons'),
		gh('ibhagwan/fzf-lua'),
		gh('iamcco/markdown-preview.nvim'),
		gh('MeanderingProgrammer/render-markdown.nvim'),
		gh('lewis6991/gitsigns.nvim'),
		gh('sindrets/diffview.nvim'),
		gh('norcalli/nvim-colorizer.lua'),
		gh('3rd/image.nvim'),
		gh('joerdav/templ.vim'),
		gh('nvim-tree/nvim-tree.lua'),
		-- LSP
		{
			src = gh('Saghen/blink.cmp'),
			version = vim.version.range('1'),
		},
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
	require('plugins.tabout').setup()
	require('plugins.markdown').setup()
	require('plugins.git').setup()
	require('plugins.image').setup()
	require('plugins.nvim-tree').setup()
	require('plugins.lint').setup()
	require('plugins.dooing').setup()
	require('plugins.which_key').setup()
end

return M
