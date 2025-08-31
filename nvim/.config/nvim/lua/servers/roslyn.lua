-- ================================================================================================
-- TITLE : Roslyn Nvim (C# Language Server) LSP Setup
-- LINKS :
--   > github: https://github.com/seblyng/roslyn.nvim
-- ================================================================================================

vim.lsp.config("roslyn", {
	on_attach = function()
		print("Roslyn LSP Live")
	end,
	settings = {
		["csharp|inlay_hints"] = {
			csharp_enable_inlay_hints_for_implicit_object_creation = true,
			csharp_enable_inlay_hints_for_implicit_variable_types = true,
		},
		["csharp|code_lens"] = {
			dotnet_enable_references_code_lens = true,
		},
	},
	filetypes = { "cs" },
})
