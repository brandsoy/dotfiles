return function()
	-- Install editor enhancement plugins
	vim.pack.add({
		{ src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" },
	})

	-- Oil file manager
	require("render-markdown").setup({
		completions = { lsp = { enabled = true } },
	})
	-- vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

	-- Which-key for keymap help
	-- require("which-key").setup()
	-- local wk = require("which-key")
	-- wk.add({
	-- 	{ "<leader>b", group = "Buffers" },
	-- 	{ "<leader>d", group = "Debug" },
	-- 	{ "<leader>f", group = "Find" },
	-- 	{ "<lsudo luarocks install --lua-version 5.1 tiktoken_coreeader>l", group = "LSP" },
	-- 	{ "<leader>lq", desc = "Diagnostics to Location List" },
	-- 	{ "<leader>m", group = "Markdown" },
	-- 	{ "<leader>q", group = "Quit" },
	-- 	{ "<leader>s", group = "Splits" },
	-- 	{ "<leader>u", group = "Toggles" },
	-- 	{ "<leader>w", group = "Write" },
	-- })
end
