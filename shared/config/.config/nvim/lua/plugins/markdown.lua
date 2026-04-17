local M = {}

function M.setup()
	local ok, render = pcall(require, "render-markdown")
	if not ok then
		return
	end

	render.setup({
		completions = { lsp = { enabled = true } },
		latex = { enabled = false },
	})
end

return M
