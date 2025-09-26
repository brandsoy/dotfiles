return function()
	vim.pack.add({
		{ src = "https://github.com/nvim-lua/plenary.nvim" },
		{ src = "https://github.com/zbirenbaum/copilot.lua" },
		{ src = "https://github.com/CopilotC-Nvim/CopilotChat.nvim" },
	})

	require("copilot").setup({
		suggestions = { enabled = true, auto_trigger = true },
		panel = { enabled = true },
		keymap = {
			-- accept = "<C-l>", -- accept suggestion
			accept = "<Tab>", -- accept suggestion
			next = "<C-]>", -- cycle next
			prev = "<C-[>", -- cycle previous
			dismiss = "<C-e>", -- dismiss ghost text
		},
	})

	require("CopilotChat").setup({
		debug = false,
		window = {
			layout = "vertical",
			width = 0.4,
		},
	})

	-- Keymaps
	local wk = require("which-key")
	wk.add({
		{ "<leader>c", group = "Copilot" },
		{ "<leader>cc", "<cmd>CopilotChat<cr>", desc = "Open Copilot Chat" },
		{ "<leader>cq", "<cmd>CopilotChatClose<cr>", desc = "Close Copilot Chat" },
		{ "<leader>co", "<cmd>CopilotChatOpen<cr>", desc = "Toggle Copilot Chat" },
	})
end
