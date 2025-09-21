return function()
	-- Install FZF plugin
	vim.pack.add({
		{ src = "https://github.com/ibhagwan/fzf-lua" },
	})

	local fzf = require("fzf-lua")
	local actions = require("fzf-lua.actions")

	fzf.setup({
		winopts = {
			-- Keep the picker large but focused in the centre
			height = 0.88,
			width = 0.86,
			row = 0.5,
			col = 0.5,
			preview = {
				layout = "flex",
				flip_columns = 120,
			},
			border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
		},
		keymap = {
			-- These are for inside the fzf window
			["fzf"] = {
				["ctrl-d"] = "half-page-down",
				["ctrl-u"] = "half-page-up",
				["ctrl-q"] = actions.file_sel_to_qf,
			},
			["builtin"] = {
				["<C-f>"] = "toggle-fullscreen",
				["<C-p>"] = "toggle-preview",
				["<C-w>"] = "toggle-preview-wrap",
			},
		},
		files = {
			prompt = "Files❯ ",
			cwd_prompt = true,
			fd_opts = [[--color=never --hidden --follow --type f --exclude .git --exclude node_modules --exclude .venv]],
			actions = {
				["default"] = actions.file_edit,
				["ctrl-s"] = actions.file_split,
				["ctrl-v"] = actions.file_vsplit,
				["ctrl-t"] = actions.file_tabedit,
			},
		},
		git = {
			files = {
				prompt = "GitFiles❯ ",
			},
		},
		oldfiles = {
			prompt = "Recent❯ ",
		},
		buffers = {
			prompt = "Buffers❯ ",
			cwd_only = true,
			sort_lastused = true,
		},
		grep = {
			prompt = "Grep❯ ",
			input_prompt = "Grep For❯ ",
			cmd = "rg --vimgrep --hidden --smart-case --glob '!.git' --glob '!node_modules' --glob '!.venv'",
			actions = {
				["ctrl-q"] = actions.file_sel_to_qf,
				["ctrl-s"] = actions.file_split,
			},
		},
	})

	local function map(lhs, rhs, desc)
		vim.keymap.set("n", lhs, rhs, { desc = desc })
	end

	-- FZF keymaps
	map("<leader>ff", fzf.files, "Find files (project aware)")
	map("<leader>fF", fzf.git_files, "Find tracked files")
	map("<leader>fr", fzf.oldfiles, "Open recent files")
	map("<leader>fb", fzf.buffers, "Switch buffer")
	map("<leader>fs", fzf.lsp_document_symbols, "Search document symbols")
	map("<leader>fS", fzf.lsp_workspace_symbols, "Search workspace symbols")
	map("<leader>fd", fzf.diagnostics_document, "List document diagnostics")
	map("<leader>fD", fzf.diagnostics_workspace, "List workspace diagnostics")
	map("<leader>fg", fzf.live_grep, "Live grep project")
	map("<leader>fw", fzf.grep_cword, "Grep word under cursor")
	map("<leader>fW", fzf.grep_cWORD, "Grep WORD under cursor")
	map("<leader>fh", fzf.help_tags, "Search help tags")
	map("<leader>f/", fzf.command_history, "Command history")
	map("<leader>f?", fzf.keymaps, "Search keymaps")
	map("<leader>f.", fzf.resume, "Resume last picker")
end
