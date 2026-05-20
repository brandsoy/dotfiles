local M = {}

function M.setup()
	vim.opt.completeopt = { "menu", "menuone", "noselect", "popup" }
	vim.o.autocomplete = true -- Enables the overall completion feature.

	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("NativeLspCompletion", { clear = true }),
		callback = function(ev)
			local client = vim.lsp.get_client_by_id(ev.data.client_id)
			if not client then
				return
			end

			vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
		end,
	})
end

return M
