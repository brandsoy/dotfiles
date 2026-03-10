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

			if client.server_capabilities.inlayHintProvider then
				pcall(vim.lsp.inlay_hint.enable, false, { bufnr = bufnr })
			end

			vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"

			local opts = { buffer = bufnr, silent = true, noremap = true }
			local keymap = vim.keymap.set

			local function map(mode, lhs, rhs, desc)
				keymap(mode, lhs, rhs, vim.tbl_extend("force", opts, { desc = desc }))
			end

			-- Navigation
			map("n", "gd", vim.lsp.buf.definition, "Go to Definition")
			map("n", "gD", vim.lsp.buf.declaration, "Go to Declaration")
			map("n", "gi", vim.lsp.buf.implementation, "Go to Implementation")
			map("n", "gr", vim.lsp.buf.references, "List References")
			map("n", "K", vim.lsp.buf.hover, "Hover Documentation")
			map("n", "<leader>lk", vim.lsp.buf.signature_help, "Signature Help")

			-- Actions
			keymap("n", "<leader>lr", function()
				local inc_rename_ok = pcall(require, "inc_rename")
				if inc_rename_ok then
					return ":IncRename " .. vim.fn.expand("<cword>")
				else
					vim.lsp.buf.rename()
					return ""
				end
			end, vim.tbl_extend("force", opts, { desc = "Rename Symbol", expr = true }))

			map("n", "<leader>la", function()
				local actions_ok, actions = pcall(require, "actions-preview")
				if actions_ok then
					actions.code_actions()
				else
					vim.lsp.buf.code_action()
				end
			end, "Code Action")

			map("n", "<leader>lf", function()
				local ok_conform, conform = pcall(require, "conform")
				if not ok_conform then
					vim.notify("conform not available", vim.log.levels.WARN)
					return
				end
				conform.format({ async = true, lsp_fallback = true })
			end, "Format Buffer")

			map("n", "<leader>lR", "<cmd>LspRestart<cr>", "Restart LSP")

			-- Diagnostics
			map("n", "[d", vim.diagnostic.goto_prev, "Previous Diagnostic")
			map("n", "]d", vim.diagnostic.goto_next, "Next Diagnostic")
			map("n", "<leader>le", vim.diagnostic.open_float, "Show Diagnostics (Float)")
			map("n", "gl", vim.diagnostic.open_float, "Show Diagnostics (Float)")
			map("n", "<leader>lq", vim.diagnostic.setloclist, "Diagnostics to Location List")
			map("n", "<leader>lQ", vim.diagnostic.setqflist, "Diagnostics to Quickfix List")
			
			-- Copy diagnostic message under cursor
			map("n", "<leader>ly", function()
				local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })
				if #diagnostics == 0 then
					vim.notify("No diagnostics on current line", vim.log.levels.INFO)
					return
				end
				
				-- Get the first diagnostic on the line
				local message = diagnostics[1].message
				vim.fn.setreg("+", message)
				vim.fn.setreg('"', message)
				vim.notify("Copied diagnostic: " .. message, vim.log.levels.INFO)
			end, "Copy Diagnostic Message")

			-- Toggles
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
