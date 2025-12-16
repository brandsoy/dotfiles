local M = {}

function M.setup()
	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("UserLspConfig", {}),
		callback = function(ev)
			local bufnr = ev.buf
			local client = vim.lsp.get_client_by_id(ev.data.client_id)
			if not client then
				return
			end

	
	
			if client.server_capabilities.inlayHintProvider then
				pcall(vim.lsp.inlay_hint.enable, true, { bufnr = bufnr })
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
			map("n", "<leader>lr", vim.lsp.buf.rename, "Rename Symbol")
			map("n", "<leader>la", vim.lsp.buf.code_action, "Code Action")
			map("n", "<leader>lk", vim.lsp.buf.signature_help, "Signature Help")
			map("n", "<leader>lf", function()
				require("conform").format({ async = true, lsp_fallback = true })
			end, "Format Buffer")

			map("n", "[d", vim.diagnostic.goto_prev, "Previous Diagnostic")
			map("n", "]d", vim.diagnostic.goto_next, "Next Diagnostic")
			map("n", "<leader>le", vim.diagnostic.open_float, "Show Diagnostics (Float)")
			map("n", "<leader>lq", vim.diagnostic.setloclist, "Diagnostics to Location List")

			-- Toggle diagnostics virtual text
			map("n", "<leader>lt", function()
				local cfg = vim.diagnostic.config()
				local vt = cfg.virtual_text
				local enabled = (type(vt) == "table") or vt
				vim.diagnostic.config({ virtual_text = not enabled })
				vim.notify("Virtual text " .. (enabled and "disabled" or "enabled"))
			end, "Toggle Diagnostics Virtual Text")

			-- Force enable all servers
			map("n", "<leader>ll", function()
				vim.cmd("LspEnableAll")
			end, "Enable All LSP Servers")
		end,
	})
end

return M
