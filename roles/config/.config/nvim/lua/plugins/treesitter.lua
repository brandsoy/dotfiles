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
	vim.api.nvim_create_autocmd('FileType', {
		group = vim.api.nvim_create_augroup('user_treesitter_highlighting', {
			clear = true,
		}),
		pattern = '*',
		callback = function(args)
			if vim.b[args.buf].large_file then
				return
			end

			local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
			if lang then
				pcall(vim.treesitter.start, args.buf, lang)
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
