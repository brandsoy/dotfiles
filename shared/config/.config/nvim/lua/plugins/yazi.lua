local M = {}

function M.setup()
	local ok_yazi, yazi = pcall(require, "yazi")
	if not ok_yazi then
		return
	end

	yazi.setup({
		open_for_directories = true,
	})

	local map = vim.keymap.set
	map("n", "<leader>-", function()
		require("yazi").yazi()
	end, { desc = "Open Yazi" })
end

return M
