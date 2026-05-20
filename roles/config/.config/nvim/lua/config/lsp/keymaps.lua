local M = {}

function M.setup()
	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
		callback = function(ev)
			local bufnr = ev.buf
			local client = vim.lsp.get_client_by_id(ev.data.client_id)
			if not client then
				return
			end

			vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"

			local opts = { buffer = bufnr, silent = true, noremap = true }
			local keymap = vim.keymap.set
			local function map(mode, lhs, rhs, desc)
				keymap(mode, lhs, rhs, vim.tbl_extend("force", opts, { desc = desc }))
			end

			map("n", "gd", vim.lsp.buf.definition, "Go to Definition")
			map("n", "gD", vim.lsp.buf.declaration, "Go to Declaration")
			map("n", "gi", vim.lsp.buf.implementation, "Go to Implementation")
			map("n", "gr", vim.lsp.buf.references, "List References")
			map("n", "K", vim.lsp.buf.hover, "Hover Documentation")
			map("n", "<leader>lk", vim.lsp.buf.signature_help, "Signature Help")

			map("n", "<leader>lr", vim.lsp.buf.rename, "Rename Symbol")
			map("n", "<leader>la", vim.lsp.buf.code_action, "Code Action")
			map("n", "<leader>lf", function()
				local ok_conform, conform = pcall(require, "conform")
				if ok_conform then
					conform.format({ async = true, lsp_fallback = true })
					return
				end
				vim.lsp.buf.format({ async = true })
			end, "Format Buffer")

			map("n", "[d", vim.diagnostic.goto_prev, "Previous Diagnostic")
			map("n", "]d", vim.diagnostic.goto_next, "Next Diagnostic")
			map("n", "<leader>le", vim.diagnostic.open_float, "Show Diagnostics")
			map("n", "gl", vim.diagnostic.open_float, "Show Diagnostics")
			map("n", "<leader>lq", vim.diagnostic.setloclist, "Diagnostics to Location List")
			map("n", "<leader>lQ", vim.diagnostic.setqflist, "Diagnostics to Quickfix List")
		end,
	})
end

return M
