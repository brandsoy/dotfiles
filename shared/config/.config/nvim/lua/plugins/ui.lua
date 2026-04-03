local M = {}

function M.setup()
	pcall(function()
		require("oc2").setup({ theme = "oc-2" })
	end)

	pcall(function()
		require("tokyonight").setup({ style = "night" })
	end)

	local ok_statusline, mini_statusline = pcall(require, "mini.statusline")
	if ok_statusline then
		mini_statusline.setup()
	end

	require("core.theme").startup("tokyonight-night")
end

return M
