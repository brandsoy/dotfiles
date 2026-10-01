local M = {}

local ensure_installed = {
	'bash',
	'zsh',
	'dockerfile',
	'go',
	'gomod',
	'c_sharp',
	'hcl',
	'jinja',
	'html',
	'graphql',
	'css',
	'xml',
	'javascript',
	'json',
	'lua',
	'markdown',
	'markdown_inline',
	'prisma',
	'python',
	'powershell',
	'terraform',
	'typescript',
	'typespec',
	'svelte',
	'yaml',
	'toml',
	'templ',
	'vim',
	'vimdoc',
}

local function start_treesitter(bufnr)
	if vim.b[bufnr].large_file or vim.treesitter.highlighter.active[bufnr] then
		return
	end

	local lang = vim.treesitter.language.get_lang(vim.bo[bufnr].filetype)
	if lang then
		pcall(vim.treesitter.start, bufnr, lang)
	end
end

local function install_missing_parsers()
	local ok_ts, ts = pcall(require, 'nvim-treesitter')
	if not ok_ts then
		return
	end

	local config = require('nvim-treesitter.config')
	local installed = config.get_installed('parsers')
	local missing = vim.tbl_filter(function(lang)
		return not vim.list_contains(installed, lang)
	end, ensure_installed)

	if #missing > 0 then
		ts.install(missing)
	end
end

function M.setup()
	vim.treesitter.language.register('html', 'htmx')
	vim.treesitter.language.register('yaml', 'yaml.ansible')

	-- nvim-treesitter no longer enables highlighting automatically. Start the
	-- matching parser for every supported filetype, including custom filetypes.
	local highlighting_group = vim.api.nvim_create_augroup('user_treesitter_highlighting', {
		clear = true,
	})

	vim.api.nvim_create_autocmd({ 'BufEnter', 'FileType' }, {
		group = highlighting_group,
		pattern = '*',
		callback = function(args)
			start_treesitter(args.buf)
		end,
	})

	vim.api.nvim_create_autocmd('User', {
		group = highlighting_group,
		pattern = 'TSUpdate',
		callback = function()
			for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
				if vim.api.nvim_buf_is_loaded(bufnr) then
					start_treesitter(bufnr)
				end
			end
		end,
	})

	local ok_ts, ts = pcall(require, 'nvim-treesitter')
	if not ok_ts then
		return
	end

	ts.setup({
		install_dir = vim.fn.stdpath('data') .. '/site',
	})

	vim.api.nvim_create_user_command('TSInstallMissing', function()
		install_missing_parsers()
	end, { desc = 'Install missing treesitter parsers' })

	vim.api.nvim_create_user_command('TSReinstallAll', function()
		ts.install(ensure_installed, { force = true })
	end, { desc = 'Reinstall all configured treesitter parsers' })

	vim.api.nvim_create_autocmd('VimEnter', {
		once = true,
		callback = install_missing_parsers,
	})
end

return M
