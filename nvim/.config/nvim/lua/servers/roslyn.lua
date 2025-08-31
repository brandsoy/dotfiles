-- ================================================================================================
-- TITLE : Roslyn Nvim (C# Language Server) LSP Setup
-- LINKS :
--   > github: https://github.com/seblyng/roslyn.nvim
-- ================================================================================================

local lsp = require("utils.lsp")

vim.lsp.config("roslyn", {
	on_attach = lsp.on_attach,
	capabilities = lsp.capabilities,
	settings = {
		["csharp|inlay_hints"] = {
			csharp_enable_inlay_hints_for_implicit_object_creation = true,
			csharp_enable_inlay_hints_for_implicit_variable_types = true,
			csharp_enable_inlay_hints_for_lambda_parameter_types = true,
			csharp_enable_inlay_hints_for_types = true,
		},
		["csharp|code_lens"] = {
			dotnet_enable_references_code_lens = true,
			dotnet_enable_tests_code_lens = true,
		},
		["csharp|completion"] = {
			dotnet_provide_regex_completions = true,
			dotnet_show_completion_items_from_unimported_namespaces = true,
			dotnet_show_name_completion_suggestions = true,
		},
		["csharp|highlighting"] = {
			dotnet_highlight_related_json_components = true,
			dotnet_highlight_related_regex_components = true,
		},
		["csharp|navigation"] = {
			dotnet_navigate_to_decompiled_sources = true,
		},
	},
	filetypes = { "cs", "csx", "cake" },
})
