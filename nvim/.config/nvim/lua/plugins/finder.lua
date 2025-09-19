return function()
	-- Install FZF plugin
	vim.pack.add({
		{ src = "https://github.com/ibhagwan/fzf-lua" },
	})

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

	-- FZF keymaps
	vim.keymap.set("n", "<leader>ff", function()
		require("fzf-lua").files()
	end, { desc = "FZF Files" })
	vim.keymap.set("n", "<leader>fg", function()
		require("fzf-lua").live_grep({ cmd = "rg --column --line-number" })
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
end
