return {
	{
		"obsidian-nvim/obsidian.nvim",
		version = "*",
		cmd = { "Obsidian" },
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		opts = {
			workspaces = {
				{
					name = "WorkNotes",
					path = "~/Sync/WorkNotes",
				},
				{
					name = "PrivateNotes",
					path = "~/Sync/PrivateNotes",
				},
			},

			-- Completion using blink.cmp
			completion = {
				nvim_cmp = false,
			},

			-- Use fzf-lua for picker
			picker = {
				name = "fzf-lua",
			},

			-- Daily notes configuration
			daily_notes = {
				folder = "daily",
				date_format = "%Y-%m-%d",
				alias_format = "%B %-d, %Y",
			},

			-- Templates configuration
			templates = {
				folder = "templates",
				date_format = "%Y-%m-%d",
				time_format = "%H:%M",
			},

			-- Frontmatter with created/updated timestamps
			frontmatter = {
				func = function(note)
					local out = { id = note.id, aliases = note.aliases, tags = note.tags }
					local now = os.date("%Y-%m-%d")
					if note.metadata ~= nil and note.metadata.created then
						out.created = note.metadata.created
					else
						local stat = vim.uv.fs_stat(tostring(note.path))
						if stat and stat.birthtime and stat.birthtime.sec > 0 then
							out.created = os.date("%Y-%m-%d", stat.birthtime.sec)
						else
							out.created = now
						end
					end
					out.updated = now
					if note.metadata ~= nil then
						for k, v in pairs(note.metadata) do
							if out[k] == nil then
								out[k] = v
							end
						end
					end
					return out
				end,
			},

			-- Note ID generation
			note_id_func = function(title)
				-- Use title if provided, otherwise use timestamp
				if title ~= nil then
					return title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
				else
					return tostring(os.time())
				end
			end,

			-- Disable legacy commands
			legacy_commands = false,

			-- Checkbox cycling order
			checkbox = {
				order = { " ", "x", ">", "~", "!" },
			},

			-- UI options
			ui = {
				enable = true,
				update_debounce = 200,
				max_file_length = 5000,
				bullets = { char = "•", hl_group = "ObsidianBullet" },
				external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" },
				reference_text = { hl_group = "ObsidianRefText" },
				highlight_text = { hl_group = "ObsidianHighlightText" },
				tags = { hl_group = "ObsidianTag" },
				block_ids = { hl_group = "ObsidianBlockID" },
				hl_groups = {
					ObsidianTodo = { bold = true, fg = "#f78c6c" },
					ObsidianDone = { bold = true, fg = "#89ddff" },
					ObsidianRightArrow = { bold = true, fg = "#f78c6c" },
					ObsidianTilde = { bold = true, fg = "#ff5370" },
					ObsidianImportant = { bold = true, fg = "#d73128" },
					ObsidianBullet = { bold = true, fg = "#89ddff" },
					ObsidianRefText = { underline = true, fg = "#c792ea" },
					ObsidianExtLinkIcon = { fg = "#c792ea" },
					ObsidianTag = { italic = true, fg = "#89ddff" },
					ObsidianBlockID = { italic = true, fg = "#89ddff" },
					ObsidianHighlightText = { bg = "#75662e" },
				},
			},

			-- Attachments (images, etc.)
			attachments = {
				folder = "attachments",
			},
		},
		config = function(_, opts)
			require("obsidian").setup(opts)

			local function map(mode, lhs, rhs, desc, extra)
				local o = vim.tbl_extend("force", { silent = true, desc = desc }, extra or {})
				vim.keymap.set(mode, lhs, rhs, o)
			end

			-- Global leader keymaps (lazy-load plugin on first use)
			map("n", "<leader>on", "<cmd>Obsidian new<cr>", "New note")
			map("n", "<leader>oo", "<cmd>Obsidian quick_switch<cr>", "Quick switch")
			map("n", "<leader>os", "<cmd>Obsidian search<cr>", "Search notes")
			map("n", "<leader>of", "<cmd>Obsidian follow_link<cr>", "Follow link")
			map("n", "<leader>oO", "<cmd>Obsidian open<cr>", "Open in Obsidian app")
			map("n", "<leader>od", "<cmd>Obsidian today<cr>", "Today's note")
			map("n", "<leader>oD", "<cmd>Obsidian dailies<cr>", "Browse dailies")
			map("n", "<leader>oy", "<cmd>Obsidian yesterday<cr>", "Yesterday's note")
			map("n", "<leader>om", "<cmd>Obsidian tomorrow<cr>", "Tomorrow's note")
			map("n", "<leader>ot", "<cmd>Obsidian template<cr>", "Insert template")
			map("n", "<leader>oT", "<cmd>Obsidian toc<cr>", "Table of contents")
			map("n", "<leader>ob", "<cmd>Obsidian backlinks<cr>", "Show backlinks")
			map("n", "<leader>ol", "<cmd>Obsidian links<cr>", "Show links")
			map("n", "<leader>og", "<cmd>Obsidian tags<cr>", "Search tags")
			map("n", "<leader>op", "<cmd>Obsidian paste_img<cr>", "Paste image")
			map("n", "<leader>or", "<cmd>Obsidian rename<cr>", "Rename note")
			map("n", "<leader>oc", "<cmd>Obsidian toggle_checkbox<cr>", "Toggle checkbox")
			map("n", "<leader>ow", "<cmd>Obsidian workspace<cr>", "Switch workspace")
			map("v", "<leader>ol", "<cmd>Obsidian link<cr>", "Link to note")
			map("v", "<leader>on", "<cmd>Obsidian link_new<cr>", "Link to new note")
			map("v", "<leader>oe", "<cmd>Obsidian extract_note<cr>", "Extract to new note")

			-- Buffer-local keymaps only in Obsidian workspace markdown files
			vim.api.nvim_create_autocmd("BufEnter", {
				pattern = "*.md",
				callback = function(args)
					local buf = args.buf
					local path = vim.api.nvim_buf_get_name(buf)
					if path == "" then
						return
					end
					local client = require("obsidian").get_client()
					if not client then
						return
					end
					-- Check if file is within an Obsidian workspace
					local in_workspace = false
					for _, ws in ipairs(client.opts.workspaces or {}) do
						local ws_path = vim.fn.expand(ws.path)
						if path:sub(1, #ws_path) == ws_path then
							in_workspace = true
							break
						end
					end
					if not in_workspace then
						return
					end
					map("n", "<cr>", function()
						return require("obsidian").util.smart_action()
					end, "Obsidian smart action", { buffer = buf })
					map("n", "[o", function()
						return require("obsidian").util.nav_link("prev")
					end, "Previous link", { buffer = buf })
					map("n", "]o", function()
						return require("obsidian").util.nav_link("next")
					end, "Next link", { buffer = buf })
				end,
			})
		end,
	},
}
