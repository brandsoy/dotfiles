-- Central plugin spec using vim.pack.add (modern simple syntax)
return function()
	vim.pack.add({
		{ src = "https://github.com/stevearc/oil.nvim" },
		{ src = "https://github.com/folke/which-key.nvim" },
		{ src = "https://github.com/nvim-tree/nvim-web-devicons" },
		{ src = "https://github.com/ibhagwan/fzf-lua" },
		{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
		{ src = "https://github.com/ray-x/go.nvim" },
		{ src = "https://github.com/ray-x/guihua.lua" },
		{ src = "https://github.com/mfussenegger/nvim-dap" },
		{ src = "https://github.com/mfussenegger/nvim-lint" },
		{ src = "https://github.com/rcarriga/nvim-dap-ui" },
		{ src = "https://github.com/nvim-neotest/nvim-nio" },
		{ src = "https://github.com/theHamsta/nvim-dap-virtual-text" },
		{ src = "https://github.com/leoluz/nvim-dap-go" },
	})

	require("oil").setup()

	require("fzf-lua").setup({
		winopts = {
			-- Customise the fzf window appearance
			height = 0.85,
			width = 0.85,
			row = 0.5,
			col = 0.5,
			border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
		},
		keymap = {
			-- These are for inside the fzf window
			["fzf"] = {
				["ctrl-d"] = "half-page-down",
				["ctrl-u"] = "half-page-up",
			},
			["builtin"] = {
				["<F1>"] = "toggle-preview-wrap",
				["<F2>"] = "toggle-fullscreen",
			},
		},
		files = {
			-- Use fd for file searching if available
			cmd = "fd --type f --hidden --follow --exclude .git",
			-- previewer = "bat", -- uncomment if you have bat installed
		},
		grep = {
			-- Use ripgrep for live grep if available
			cmd = "rg --vimgrep",
			-- previewer = "bat", -- uncomment if you have bat installed
		},
	})

	vim.keymap.set("n", "<leader>ff", function()
		require("fzf-lua").files()
	end, { desc = "FZF Files" })
	vim.keymap.set("n", "<leader>fg", function()
		require("fzf-lua").live_grep()
	end, { desc = "FZF Live Grep" })
	vim.keymap.set("n", "<leader>fb", function()
		require("fzf-lua").buffers()
	end, { desc = "FZF Buffers" })
	vim.keymap.set("n", "<leader>fh", function()
		require("fzf-lua").help_tags()
	end, { desc = "FZF Help Tags" })
	vim.keymap.set("n", "<leader>fx", function()
		require("fzf-lua").diagnostics_document()
	end, { desc = "FZF Diagnostics Document" })
	vim.keymap.set("n", "<leader>fX", function()
		require("fzf-lua").diagnostics_workspace()
	end, { desc = "FZF Diagnostics Workspace" })
	vim.keymap.set("n", "<leader>fs", function()
		require("fzf-lua").lsp_document_symbols()
	end, { desc = "FZF Document Symbols" })
	vim.keymap.set("n", "<leader>fS", function()
		require("fzf-lua").lsp_workspace_symbols()
	end, { desc = "FZF Workspace Symbols" })

	require("nvim-treesitter.configs").setup({
		ensure_installed = {
			"bash",
			"css",
			"dockerfile",
			"go",
			"gomod",
			"gosum",
			"gotmpl",
			"html",
			"javascript",
			"json",
			"lua",
			"markdown",
			"markdown_inline",
			"python",
			"svelte",
			"typescript",
			"vue",
			"yaml",
			"vim",
			"vimdoc",
		},
		sync_install = true,
		auto_install = true,
		ignore_install = {},
		modules = {},
		highlight = {
			enable = true,
			additional_vim_regex_highlighting = false,
		},
		indent = { enable = true },
		incremental_selection = {
			enable = true,
			keymaps = {
				init_selection = "<CR>",
				node_incremental = "<CR>",
				scope_incremental = "<TAB>",
				node_decremental = "<S-TAB>",
			},
		},
	})

	require("which-key").setup()
	local wk = require("which-key")
	wk.add({
		{ "<leader>m", group = "Markdown" },
		{ "<leader>f", group = "FZF" },
		{ "<leader>l", group = "LSP" },
		-- { "<leader>lq", desc = "Diagnostics to Location List" },
		-- { "<leader>d", group = "Debug" },
		-- { "<F5>", desc = "DAP: Continue" },
		-- { "<F9>", desc = "DAP: Toggle Breakpoint" },
		-- { "<F10>", desc = "DAP: Step Over" },
		-- { "<F11>", desc = "DAP: Step Into" },
		-- { "<F12>", desc = "DAP: Step Out" },
		-- { "<leader>db", desc = "DAP: Toggle Breakpoint" },
		-- { "<leader>dc", desc = "DAP: Continue" },
		-- { "<leader>do", desc = "DAP: Step Over" },
		-- { "<leader>di", desc = "DAP: Step Into" },
		-- { "<leader>dO", desc = "DAP: Step Out" },
		-- { "<leader>dr", desc = "DAP: Toggle REPL" },
		-- { "<leader>du", desc = "DAP: Toggle UI" },
		-- { "<leader>dt", desc = "DAP: Debug Go Test" },
		-- { "<leader>dT", desc = "DAP: Debug Last Go Test" },
	})

	-- Plugin Keymaps
	vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
end
