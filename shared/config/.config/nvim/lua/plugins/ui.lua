local M = {}

function M.setup()
	pcall(function()
		require("oc2").setup({ theme = "oc-2" })
	end)

	pcall(function()
		require("tokyonight").setup({ style = "night" })
	end)

	require("core.theme").startup("tokyonight-night")
end

return M
