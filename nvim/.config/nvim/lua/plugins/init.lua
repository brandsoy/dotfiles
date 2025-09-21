return function()
	-- Load all plugin modules
	require("plugins.editor")()
	require("plugins.finder")()
	require("plugins.treesitter")()
	require("plugins.roslyn")()
	require("plugins.lsp")
end
