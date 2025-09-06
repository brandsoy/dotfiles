return function()
	-- Completion autotrigger + inlay hints when supported
	vim.api.nvim_create_autocmd("LspAttach", {
		callback = function(ev)
			local client = vim.lsp.get_client_by_id(ev.data.client_id)
			if client ~= nil and client:supports_method("textDocument/completion") then
				vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
			end
			if client ~= nil and client.server_capabilities.inlayHintProvider then
				pcall(vim.lsp.inlay_hint.enable, true, { bufnr = ev.buf })
			end
		end,
	})

	-- LSP keymaps and pickers on attach
	vim.api.nvim_create_autocmd("LspAttach", {
		callback = function(ev)
			local bufnr = ev.buf
			local opts = { buffer = bufnr, silent = true, noremap = true }

			local keymap = vim.keymap.set

			keymap("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to Definition" }))
			keymap("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "Go to Declaration" }))
			keymap(
				"n",
				"gi",
				vim.lsp.buf.implementation,
				vim.tbl_extend("force", opts, { desc = "Go to Implementation" })
			)
			keymap("n", "gr", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "List References" }))

			keymap("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover Documentation" }))
			keymap(
				"n",
				"gK",
				"<cmd>normal! K<CR>",
				vim.tbl_extend("force", opts, { desc = "Keywordprg Help (default)" })
			)

			keymap("n", "<leader>lr", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename Symbol" }))
			keymap("n", "<leader>la", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code Action" }))
			keymap(
				"n",
				"<leader>lk",
				vim.lsp.buf.signature_help,
				vim.tbl_extend("force", opts, { desc = "Signature Help" })
			)
			keymap("n", "<leader>lf", function()
				vim.lsp.buf.format({ async = true })
			end, vim.tbl_extend("force", opts, { desc = "Format Buffer" }))

			keymap("n", "[d", vim.diagnostic.goto_prev, vim.tbl_extend("force", opts, { desc = "Previous Diagnostic" }))
			keymap("n", "]d", vim.diagnostic.goto_next, vim.tbl_extend("force", opts, { desc = "Next Diagnostic" }))
			keymap(
				"n",
				"<leader>le",
				vim.diagnostic.open_float,
				vim.tbl_extend("force", opts, { desc = "Show Diagnostics (Float)" })
			)
			keymap(
				"n",
				"<leader>lq",
				vim.diagnostic.setloclist,
				vim.tbl_extend("force", opts, { desc = "Diagnostics to Location List" })
			)
		end,
	})
end
