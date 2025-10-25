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
			{ "<leader>uh", function() require("fzf-lua").mini_notify_history() end, desc = "Notification history" },
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

			fzf.mini_notify_history = function(opts)
				opts = opts or {}

				local ok_notify, mini_notify = pcall(require, "mini.notify")
				if not ok_notify then
					vim.notify("mini.notify not available; cannot show history", vim.log.levels.ERROR, { title = "Notifications" })
					return
				end

				local history = mini_notify.get_all()
				if type(history) ~= "table" or #history == 0 then
					vim.notify("Notification history is empty", vim.log.levels.INFO, { title = "Notifications" })
					return
				end

				local entries = {}
				local lookup = {}

				for index = #history, 1, -1 do
					local notif = history[index]
					local id = string.format("%05d", index)
					local level = string.upper(notif.level or "INFO")
					local timestamp = notif.ts_add and os.date("%H:%M:%S", math.floor(notif.ts_add)) or "--:--:--"
					local message = (notif.msg or ""):gsub("\n", " ")
					message = message:gsub("%s+", " ")
					message = message:match("^%s*(.-)%s*$") or ""
					local display = string.format("%s | %-5s | %s", timestamp, level, message)
					table.insert(entries, string.format("%s %s", id, display))
					lookup[id] = notif
				end

				local function extract_notification(selection)
					if not selection or not selection[1] then
						return nil
					end
					local id = selection[1]:match("^(%d+)")
					if not id then
						return nil
					end
					return lookup[id]
				end

				local fzf_opts = vim.tbl_deep_extend("force", {
					prompt = "Notify❯ ",
					winopts = {
						title = "Notification History",
						title_pos = "center",
					},
					fzf_opts = {
						["--no-sort"] = "",
						["--delimiter"] = " ",
						["--with-nth"] = "2..",
					},
					actions = {
						["default"] = function(selection)
							local notif = extract_notification(selection)
							if not notif then
								return
							end
							local level = vim.log.levels[notif.level or "INFO"] or vim.log.levels.INFO
							vim.notify(notif.msg, level)
						end,
						["ctrl-y"] = function(selection)
							local notif = extract_notification(selection)
							if not notif then
								return
							end
							vim.fn.setreg("+", notif.msg)
							vim.notify("Notification copied to clipboard", vim.log.levels.INFO, { title = "Notifications" })
						end,
					},
					previewer = false,
				}, opts or {})

				fzf.fzf_exec(entries, fzf_opts)
			end
		end,
	},
}
