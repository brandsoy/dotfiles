local M = {}

function M.setup()
	local ok_fzf, fzf = pcall(require, 'fzf-lua')
	if not ok_fzf then
		return
	end

	pcall(function()
		local mini_icons = require('mini.icons')
		mini_icons.setup()
		mini_icons.mock_nvim_web_devicons()
	end)

	local actions = require('fzf-lua.actions')
	local function git_root_or_cwd()
		local out = vim.fn.systemlist('git rev-parse --show-toplevel')
		if vim.v.shell_error == 0 and out[1] and out[1] ~= '' then
			return out[1]
		end
		return vim.uv.cwd()
	end

	fzf.setup({
		fzf_colors = true,
		winopts = {
			backdrop = 100,
			preview = {
				layout = 'vertical',
				vertical = 'right:55%',
			},
		},
		defaults = {
			file_icons = 'mini',
			color_icons = false,
		},
		files = {
			-- Keep fzf-lua's toggleable flags as booleans. If --no-ignore is
			-- embedded in fd_opts, fzf-lua's default no_ignore=false removes it,
			-- which hides ignored-but-tracked files from <leader>ff.
			fd_opts = [[--color=never --type f --type l --exclude .git --exclude node_modules --exclude .venv]],
			hidden = true,
			follow = true,
			no_ignore = true,
			file_icons = 'mini',
		},
		grep = {
			cmd = "rg --column --vimgrep --hidden --smart-case --glob '!.git' --glob '!node_modules' --glob '!.venv'",
			actions = { ['ctrl-q'] = actions.file_sel_to_qf },
			file_icons = 'mini',
		},
	})

	local map = vim.keymap.set
	map('n', '<leader>ff', function()
		fzf.files({ cwd = git_root_or_cwd() })
	end, { desc = 'Find files' })
	map('n', '<leader>fF', function()
		fzf.git_files()
	end, { desc = 'Find tracked files' })
	map('n', '<leader>fr', function()
		fzf.oldfiles()
	end, { desc = 'Open recent files' })
	map('n', '<leader>fR', function()
		fzf.resume()
	end, { desc = 'Resume last picker' })
	map('n', '<leader>fb', function()
		fzf.buffers()
	end, { desc = 'Switch buffer' })
	map('n', '<leader>fs', function()
		fzf.lsp_document_symbols()
	end, { desc = 'Document symbols' })
	map('n', '<leader>fS', function()
		fzf.lsp_workspace_symbols()
	end, { desc = 'Workspace symbols' })
	map('n', '<leader>fd', function()
		fzf.diagnostics_document()
	end, { desc = 'Document diagnostics' })
	map('n', '<leader>fD', function()
		fzf.diagnostics_workspace()
	end, { desc = 'Workspace diagnostics' })
	map('n', '<leader>fg', function()
		fzf.live_grep()
	end, { desc = 'Live grep' })
	map('n', '<leader>fw', function()
		fzf.grep_cword()
	end, { desc = 'Grep word' })
	map('n', '<leader>fh', function()
		fzf.help_tags()
	end, { desc = 'Help tags' })
	map('n', '<leader>/', function()
		fzf.lgrep_curbuf()
	end, { desc = 'Buffer fuzzy search' })
end

return M
