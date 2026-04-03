local M = {}

function M.setup()
	local ok_fzf, fzf = pcall(require, "fzf-lua")
	if not ok_fzf then
		return
	end

	local actions = require("fzf-lua.actions")
	fzf.setup({
		"max-perf",
		files = {
			fd_opts = [[--color=never --hidden --follow --type f --exclude .git --exclude node_modules --exclude .venv]],
		},
		grep = {
			cmd = "rg --column --vimgrep --hidden --smart-case --glob '!.git' --glob '!node_modules' --glob '!.venv'",
			actions = { ["ctrl-q"] = actions.file_sel_to_qf },
		},
	})

	local map = vim.keymap.set
	map("n", "<leader>ff", function() fzf.files() end, { desc = "Find files" })
	map("n", "<leader>fF", function() fzf.git_files() end, { desc = "Find tracked files" })
	map("n", "<leader>fr", function() fzf.oldfiles() end, { desc = "Open recent files" })
	map("n", "<leader>fb", function() fzf.buffers() end, { desc = "Switch buffer" })
	map("n", "<leader>fs", function() fzf.lsp_document_symbols() end, { desc = "Document symbols" })
	map("n", "<leader>fS", function() fzf.lsp_workspace_symbols() end, { desc = "Workspace symbols" })
	map("n", "<leader>fd", function() fzf.diagnostics_document() end, { desc = "Document diagnostics" })
	map("n", "<leader>fD", function() fzf.diagnostics_workspace() end, { desc = "Workspace diagnostics" })
	map("n", "<leader>fg", function() fzf.live_grep() end, { desc = "Live grep" })
	map("n", "<leader>fw", function() fzf.grep_cword() end, { desc = "Grep word" })
	map("n", "<leader>fh", function() fzf.help_tags() end, { desc = "Help tags" })
	map("n", "<leader>/", function() fzf.lgrep_curbuf() end, { desc = "Buffer fuzzy search" })
end

return M
