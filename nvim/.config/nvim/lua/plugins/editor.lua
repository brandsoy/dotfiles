return {
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			"nvim-tree/nvim-web-devicons", -- optional, but recommended
		},
		lazy = false, -- neo-tree will lazily load itself
		keys = {
			{ "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Explorer" },
			{ "<leader>fe", "<cmd>Neotree focus<cr>", desc = "Explorer focus" },
			{ "<leader>be", "<cmd>Neotree buffers<cr>", desc = "Buffer explorer" },
			{ "<leader>ge", "<cmd>Neotree git_status<cr>", desc = "Git explorer" },
		},
	},

	{
		"stevearc/oil.nvim",
		cmd = "Oil",
		keys = {
			{ "-", "<CMD>Oil<CR>", desc = "Open parent directory" },
		},
		opts = {},
		config = function(_, opts)
			require("oil").setup(opts)
		end,
	},
	{
		"nvim-mini/mini.bufremove",
		keys = {
			{
				"<leader>bd",
				function()
					require("mini.bufremove").delete()
				end,
				desc = "Delete buffer",
			},
			{
				"<leader>bD",
				function()
					require("mini.bufremove").delete(0, true)
				end,
				desc = "Delete buffer (force)",
			},
			{
				"<leader>bo",
				function()
					local current = vim.api.nvim_get_current_buf()
					local bufremove = require("mini.bufremove")
					for _, buf in ipairs(vim.api.nvim_list_bufs()) do
						if buf ~= current and vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted then
							bufremove.delete(buf, false)
						end
					end
				end,
				desc = "Delete other buffers",
			},
		},
		config = function()
			require("mini.bufremove").setup()
		end,
	},
	{
		"nvim-mini/mini.ai",
		keys = {
			{ "a", mode = { "x", "o" } },
			{ "i", mode = { "x", "o" } },
		},
		config = function()
			require("mini.ai").setup()
		end,
	},
	{
		"nvim-mini/mini.move",
		keys = {
			{ "<A-j>", mode = { "n", "v" } },
			{ "<A-k>", mode = { "n", "v" } },
		},
		opts = {
			mappings = {
				down = "<A-j>",
				up = "<A-k>",
				line_down = "<A-j>",
				line_up = "<A-k>",
			},
		},
		config = function(_, opts)
			require("mini.move").setup(opts)
		end,
	},
	{
		"nvim-mini/mini.pairs",
		event = "InsertEnter",
		opts = {
			modes = { insert = true, command = false, terminal = false },
		},
		config = function(_, opts)
			require("mini.pairs").setup(opts)
		end,
	},
	{
		"nvim-mini/mini.notify",
		event = "VeryLazy",
		config = function()
			local mini_notify = require("mini.notify")

			local function format_message(notification)
				local labels = {
					ERROR = "[error]",
					WARN = "[warn] ",
					INFO = "[info] ",
					DEBUG = "[debug]",
					TRACE = "[trace]",
				}
				local level = notification.level or notification.level_name or "INFO"
				level = string.upper(level)
				local prefix = labels[level] or labels.INFO
				return string.format("%s %s", prefix, notification.msg)
			end

			local function floating_window_config()
				local tabline_is_visible = vim.o.showtabline ~= 0
				return {
					anchor = "NE",
					col = vim.o.columns,
					row = tabline_is_visible and 1 or 0,
					border = "rounded",
				}
			end

			mini_notify.setup({
				content = {
					format = format_message,
				},
				window = {
					winblend = 10,
					max_width_share = 0.45,
					config = floating_window_config,
				},
			})

			vim.notify = mini_notify.make_notify({
				ERROR = { duration = 7000 },
				WARN = { duration = 5000 },
				INFO = { duration = 3000 },
			})

			local function set_notify_highlights()
				local background = "#1b1d2b"
				vim.api.nvim_set_hl(0, "MiniNotifyNormal", { bg = background, fg = "#d0d5f6" })
				vim.api.nvim_set_hl(0, "MiniNotifyBorder", { bg = background, fg = "#8087ad" })
				vim.api.nvim_set_hl(0, "MiniNotifyTitle", { fg = "#a5b3ff", bold = true })
			end

			set_notify_highlights()
			vim.api.nvim_create_autocmd("ColorScheme", {
				callback = set_notify_highlights,
				desc = "Reapply MiniNotify highlight overrides",
			})
		end,
	},

	{
		"nvim-mini/mini.diff",
		version = false,
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			if vim.fn.isdirectory(".git") == 1 or vim.fn.finddir(".git", ".;") ~= "" then
				require("mini.diff").setup({})
			end
		end,
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		config = function()
			require("which-key").setup()
			local wk = require("which-key")
			wk.add({
				{ "<leader>b", group = "Buffers" },
				{ "<leader>d", group = "Debug" },
				{ "<leader>e", desc = "Explorer" },
				{ "<leader>f", group = "Find" },
				{ "<leader>g", group = "Git" },
				{ "<leader>l", group = "LSP" },
				{ "<leader>lq", desc = "Diagnostics to Location List" },
				{ "<leader>m", group = "Markdown" },
				{ "<leader>uh", desc = "Notification history" },
				{ "<leader>q", group = "Quit" },
				{ "<leader>s", group = "Splits" },
				{ "<leader>u", group = "Toggles" },
				{ "<leader>w", group = "Write" },
			})
		end,
	},
}
