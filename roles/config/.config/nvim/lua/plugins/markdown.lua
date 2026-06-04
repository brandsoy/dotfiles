local M = {}

function M.setup()
	-- vim.g.mkdp_auto_start = 0
	-- vim.g.mkdp_auto_close = 1
	-- vim.g.mkdp_refresh_slow = 0
	-- vim.g.mkdp_command_for_global = 0
	-- vim.g.mkdp_open_to_the_world = 0
	-- vim.g.mkdp_open_ip = "127.0.0.1"
	-- vim.g.mkdp_browser = ""
	-- vim.g.mkdp_echo_preview_url = 1
	vim.g.mkdp_filetypes = { 'markdown' }

	vim.keymap.set(
		'n',
		'<leader>mp',
		'<cmd>MarkdownPreviewToggle<cr>',
		{ desc = 'Markdown preview' }
	)

	-- local ok, render = pcall(require, "render-markdown")
	-- if ok then
	-- 	render.setup({
	-- 		completions = { lsp = { enabled = true } },
	-- 		latex = { enabled = false },
	-- 	})
	-- end
end

return M
