return function()
	-- Install roslyn.nvim for enhanced C# support
	vim.pack.add({
		{ src = "https://github.com/seblyng/roslyn.nvim" },
	})

	-- Configure roslyn.nvim with optimal settings
	require("roslyn").setup({
		-- File watching configuration - "roslyn" makes roslyn handle file watching
		-- which is more efficient for C# projects
		filewatching = "roslyn",

		-- Enable broad search to find solution files in parent directories
		-- Useful if you have complex project structures
		broad_search = true,

		-- Lock target after first attach to avoid switching solutions accidentally
		-- You can still change with :Roslyn target command
		lock_target = false,

		-- Keep notifications enabled for better feedback
		silent = false,

		-- Optional: Custom target selection logic
		-- choose_target = function(targets)
		-- 	-- You can add custom logic here to automatically select a solution
		-- 	-- For example, prefer .sln files over .csproj files
		-- 	return vim.iter(targets):find(function(target)
		-- 		return target:match("%.sln$")
		-- 	end) or targets[1]
		-- end,

		-- Optional: Ignore specific targets
		-- ignore_target = function(target)
		-- 	-- Example: ignore test solutions or specific frameworks
		-- 	return target:match("Test%.sln$") ~= nil
		-- end,
	})

	-- Configure C# LSP settings using vim.lsp.config
	vim.lsp.config("roslyn", {
		settings = {
			-- Inlay hints configuration
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

			-- Code lens configuration
			["csharp|code_lens"] = {
				dotnet_enable_references_code_lens = true,
				dotnet_enable_tests_code_lens = true,
			},

			-- Background analysis for better diagnostics
			["csharp|background_analysis"] = {
				background_analysis_dotnet_analyzer_diagnostics_scope = "fullSolution",
				background_analysis_dotnet_compiler_diagnostics_scope = "fullSolution",
			},

			-- Completion settings
			["csharp|completion"] = {
				dotnet_provide_regex_completions = true,
				dotnet_show_completion_items_from_unimported_namespaces = true,
				dotnet_show_name_completion_suggestions = true,
			},

			-- Symbol search
			["csharp|symbol_search"] = {
				dotnet_search_reference_assemblies = true,
			},

			-- Formatting
			["csharp|formatting"] = {
				dotnet_organize_imports_on_format = true,
			},
		},
	})

	-- Auto-commands for C# specific features
	vim.api.nvim_create_autocmd("LspAttach", {
		callback = function(args)
			local client = vim.lsp.get_client_by_id(args.data.client_id)
			if client and client.name == "roslyn" then
				-- Enable inlay hints for C# files
				if client.server_capabilities.inlayHintProvider then
					vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
				end

				-- Enable code lens for C# files
				if client.server_capabilities.codeLensProvider then
					vim.lsp.codelens.refresh()
					-- Auto-refresh code lens on save
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

	-- Roslyn-specific keymaps
	vim.api.nvim_create_autocmd("FileType", {
		pattern = { "cs", "csharp" },
		callback = function(args)
			local opts = { buffer = args.buf, silent = true, noremap = true }

			-- Roslyn specific commands
			vim.keymap.set("n", "<leader>lr", "<cmd>Roslyn restart<cr>", 
				vim.tbl_extend("force", opts, { desc = "Roslyn: Restart" }))
			vim.keymap.set("n", "<leader>lt", "<cmd>Roslyn target<cr>", 
				vim.tbl_extend("force", opts, { desc = "Roslyn: Choose Target" }))

			-- Code lens refresh
			vim.keymap.set("n", "<leader>lcl", vim.lsp.codelens.refresh, 
				vim.tbl_extend("force", opts, { desc = "Refresh Code Lens" }))
			vim.keymap.set("n", "<leader>lch", function()
				vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = args.buf }), { bufnr = args.buf })
			end, vim.tbl_extend("force", opts, { desc = "Toggle Inlay Hints" }))
		end,
	})
end