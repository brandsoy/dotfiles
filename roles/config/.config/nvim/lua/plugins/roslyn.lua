local M = {}

function M.setup()
	local ok, roslyn = pcall(require, "roslyn")
	if not ok then
		return
	end

	roslyn.setup({
		filewatching = "roslyn",
		broad_search = false,
		lock_target = false,
		silent = false,
	})

	vim.lsp.config("roslyn", {
		filetypes = { "cs" },
	})
end

return M
