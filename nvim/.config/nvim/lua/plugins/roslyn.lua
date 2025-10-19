return {
	{
		"seblyng/roslyn.nvim",
		ft = { "cs", "csx", "vb", "csproj" },
		config = function()
			require("roslyn").setup({
				filewatching = "roslyn",
				broad_search = true,
				lock_target = false,
				silent = false,
			})

			vim.lsp.config("roslyn", {
				settings = {
					["csharp|inlay_hints"] = {
						csharp_enable_inlay_hints_for_implicit_object_creation = true,
						csharp_enable_inlay_hints_for_implicit_variable_types = true,
						csharp_enable_inlay_hints_for_lambda_parameter_types = true,
						csharp_enable_inlay_hints_for_types = true,
						dotnet_enable_inlay_hints_for_indexer_parameters = true,
						dotnet_enable_inlay_hints_for_literal_parameters = true,
						dotnet_enable_inlay_hints_for_object_creation_parameters = true,
						dotnet_enable_inlay_hints_for_other_parameters = true,
						dotnet_enable_inlay_hints_for_parameters = true,
						dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = true,
						dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = true,
						dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = true,
					},
					["csharp|code_lens"] = {
						dotnet_enable_references_code_lens = true,
						dotnet_enable_tests_code_lens = true,
					},
					["csharp|background_analysis"] = {
						background_analysis_dotnet_analyzer_diagnostics_scope = "fullSolution",
						background_analysis_dotnet_compiler_diagnostics_scope = "fullSolution",
					},
					["csharp|completion"] = {
						dotnet_provide_regex_completions = true,
						dotnet_show_completion_items_from_unimported_namespaces = true,
						dotnet_show_name_completion_suggestions = true,
					},
					["csharp|symbol_search"] = {
						dotnet_search_reference_assemblies = true,
					},
					["csharp|formatting"] = {
						dotnet_organize_imports_on_format = true,
					},
				},
			})

			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					if client and client.name == "roslyn" then
						if client.server_capabilities.inlayHintProvider then
							vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
						end

						if client.server_capabilities.codeLensProvider then
							vim.lsp.codelens.refresh()
							vim.api.nvim_create_autocmd({ "BufWritePost", "CursorHold" }, {
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
					vim.keymap.set("n", "<leader>lr", "<cmd>Roslyn restart<cr>", vim.tbl_extend("force", opts, { desc = "Roslyn: Restart" }))
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
