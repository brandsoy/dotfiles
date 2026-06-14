local M = {}

function M.setup_conform()
	local ok, conform = pcall(require, 'conform')
	if not ok then
		return
	end

	conform.setup({
		format_on_save = function(bufnr)
			if vim.b[bufnr].large_file then
				return nil
			end
			return { lsp_format = 'fallback', timeout_ms = 1000 }
		end,
		formatters_by_ft = require('config.lsp.formatters_by_ft').get(),
	})
end

return M
