local M = {}

function M.setup()
	pcall(function()
		require("oc2").setup({ theme = "oc-2" })
	end)

	pcall(function()
		require("tokyonight").setup({ style = "night" })
	end)

	pcall(function()
		require("nightfox").setup()
	end)

	require("core.theme").startup("carbonfox")
end

return M
