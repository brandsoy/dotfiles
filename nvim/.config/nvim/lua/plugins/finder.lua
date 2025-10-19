return {
	{
		"ibhagwan/fzf-lua",
		cmd = "FzfLua",
		keys = {
			{ "<leader>ff", function() require("fzf-lua").files() end, desc = "Find files (project aware)" },
			{ "<leader>fF", function() require("fzf-lua").git_files() end, desc = "Find tracked files" },
			{ "<leader>fr", function() require("fzf-lua").oldfiles() end, desc = "Open recent files" },
			{ "<leader>fb", function() require("fzf-lua").buffers() end, desc = "Switch buffer" },
			{ "<leader>fs", function() require("fzf-lua").lsp_document_symbols() end, desc = "Search document symbols" },
			{ "<leader>fS", function() require("fzf-lua").lsp_workspace_symbols() end, desc = "Search workspace symbols" },
			{ "<leader>fd", function() require("fzf-lua").diagnostics_document() end, desc = "List document diagnostics" },
			{ "<leader>fD", function() require("fzf-lua").diagnostics_workspace() end, desc = "List workspace diagnostics" },
			{ "<leader>fg", function() require("fzf-lua").live_grep() end, desc = "Live grep project" },
			{ "<leader>fw", function() require("fzf-lua").grep_cword() end, desc = "Grep word under cursor" },
			{ "<leader>fW", function() require("fzf-lua").grep_cWORD() end, desc = "Grep WORD under cursor" },
			{ "<leader>fh", function() require("fzf-lua").help_tags() end, desc = "Search help tags" },
			{ "<leader>f/", function() require("fzf-lua").command_history() end, desc = "Command history" },
			{ "<leader>f?", function() require("fzf-lua").keymaps() end, desc = "Search keymaps" },
			{ "<leader>f.", function() require("fzf-lua").resume() end, desc = "Resume last picker" },
		},
		config = function()
			local fzf = require("fzf-lua")
			local actions = require("fzf-lua.actions")
			fzf.setup({
				winopts = {
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
					fzf = {
						["ctrl-d"] = "half-page-down",
						["ctrl-u"] = "half-page-up",
						["ctrl-q"] = actions.file_sel_to_qf,
					},
					builtin = {
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
					files = { prompt = "GitFiles❯ " },
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
					cmd = "rg --column --vimgrep --hidden --smart-case --glob '!.git' --glob '!node_modules' --glob '!.venv'",
					actions = {
						["ctrl-q"] = actions.file_sel_to_qf,
						["ctrl-s"] = actions.file_split,
					},
				},
			})
		end,
	},
}
