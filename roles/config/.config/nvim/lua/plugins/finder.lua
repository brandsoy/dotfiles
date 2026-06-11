local M = {}

function M.setup()
	local ok_fzf, fzf = pcall(require, 'fzf-lua')
	if not ok_fzf then
		return
	end

	pcall(function()
		require('mini.icons').setup()
	end)

	local actions = require('fzf-lua.actions')
	local function buffer_dir()
		local name = vim.api.nvim_buf_get_name(0)
		if name ~= '' then
			return vim.fs.dirname(name)
		end
		return vim.uv.cwd()
	end

	local function git_root(dir)
		local out =
			vim.fn.systemlist({ 'git', '-C', dir, 'rev-parse', '--show-toplevel' })
		if vim.v.shell_error == 0 and out[1] and out[1] ~= '' then
			return out[1]
		end
	end

	local function project_root_or_cwd()
		local dir = buffer_dir()
		return git_root(dir) or dir
	end

	local function project_files()
		fzf.files({ cwd = project_root_or_cwd() })
	end

	local function vcs_files()
		local dir = buffer_dir()
		local root = git_root(dir)
		if root then
			fzf.git_files({ cwd = root })
			return
		end

		fzf.files({ cwd = dir })
	end

	local function grep_project()
		fzf.live_grep({ cwd = project_root_or_cwd() })
	end

	local function oldfiles_project()
		fzf.oldfiles({ cwd = project_root_or_cwd() })
	end

	local function grep_word_project()
		fzf.grep_cword({ cwd = project_root_or_cwd() })
	end

	local function workspace_diagnostics()
		fzf.diagnostics_workspace({ cwd = project_root_or_cwd() })
	end

	local function workspace_symbols()
		fzf.lsp_workspace_symbols({ cwd = project_root_or_cwd() })
	end

	local function help_tags()
		fzf.help_tags()
	end

	local function resume()
		fzf.resume()
	end

	local function buffers()
		fzf.buffers()
	end

	local function document_symbols()
		fzf.lsp_document_symbols()
	end

	local function document_diagnostics()
		fzf.diagnostics_document()
	end

	local function curbuf_grep()
		fzf.lgrep_curbuf()
	end

	local function file_actions()
		return {
			['ctrl-q'] = actions.file_sel_to_qf,
		}
	end

	local function grep_actions()
		return {
			['ctrl-q'] = actions.file_sel_to_qf,
		}
	end

	fzf.setup({
		ui_select = true,
		fzf_colors = true,
		winopts = {
			backdrop = 60,
			preview = {
				layout = 'vertical',
				vertical = 'right:55%',
			},
		},
		defaults = {
			file_icons = 'mini',
			color_icons = true,
		},
		files = {
			fd_opts = [[--color=never --type f --type l --hidden --follow --exclude .git --exclude .jj --exclude node_modules --exclude .venv --exclude dist --exclude build]],
			file_icons = 'mini',
			actions = file_actions(),
		},
		oldfiles = {
			file_icons = 'mini',
			actions = file_actions(),
		},
		git = {
			files = {
				file_icons = 'mini',
				actions = file_actions(),
			},
		},
		buffers = {
			file_icons = 'mini',
			ignore_current_buffer = true,
		},
		grep = {
			rg_opts = "--column --line-number --no-heading --color=always --smart-case --max-columns=4096 --glob '!.git' --glob '!node_modules' --glob '!.venv' --glob '!dist' --glob '!build' -e",
			actions = grep_actions(),
			file_icons = 'mini',
		},
	})

	local map = vim.keymap.set
	map('n', '<leader>ff', project_files, { desc = 'Find files' })
	map('n', '<leader>fF', vcs_files, { desc = 'Find tracked files' })
	map('n', '<leader>fr', oldfiles_project, { desc = 'Open recent files' })
	map('n', '<leader>fR', resume, { desc = 'Resume last picker' })
	map('n', '<leader>fb', buffers, { desc = 'Switch buffer' })
	map('n', '<leader>fs', document_symbols, { desc = 'Document symbols' })
	map('n', '<leader>fS', workspace_symbols, { desc = 'Workspace symbols' })
	map(
		'n',
		'<leader>fd',
		document_diagnostics,
		{ desc = 'Document diagnostics' }
	)
	map(
		'n',
		'<leader>fD',
		workspace_diagnostics,
		{ desc = 'Workspace diagnostics' }
	)
	map('n', '<leader>fg', grep_project, { desc = 'Live grep' })
	map('n', '<leader>fw', grep_word_project, { desc = 'Grep word' })
	map('n', '<leader>fh', help_tags, { desc = 'Help tags' })
	map('n', '<leader>/', curbuf_grep, { desc = 'Buffer fuzzy search' })
end

return M
