return {
	{
		"seblyng/roslyn.nvim",
		ft = { "cs", "csx", "vb", "csproj" },
		config = function()
			require("roslyn").setup({
				filewatching = "roslyn",
				broad_search = false,
				lock_target = false,
				silent = false,
			})

			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					if client and client.name == "roslyn" then
	
						if client.server_capabilities.codeLensProvider then
							vim.lsp.codelens.refresh()
							vim.api.nvim_create_autocmd("BufWritePost", {
								buffer = args.buf,
								callback = function()
									vim.lsp.codelens.refresh({ bufnr = args.buf })
								end,
							})
						end
					end
				end,
			})

			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "cs", "csharp" },
				callback = function(args)
					local opts = { buffer = args.buf, silent = true, noremap = true }
					vim.keymap.set("n", "<leader>lR", "<cmd>Roslyn restart<cr>", vim.tbl_extend("force", opts, { desc = "Roslyn: Restart" }))
					vim.keymap.set("n", "<leader>lt", "<cmd>Roslyn target<cr>", vim.tbl_extend("force", opts, { desc = "Roslyn: Choose Target" }))
					vim.keymap.set("n", "<leader>lcl", vim.lsp.codelens.refresh, vim.tbl_extend("force", opts, { desc = "Refresh Code Lens" }))
					vim.keymap.set("n", "<leader>lch", function()
						vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = args.buf }), { bufnr = args.buf })
					end, vim.tbl_extend("force", opts, { desc = "Toggle Inlay Hints" }))
				end,
			})
		end,
	},
}
