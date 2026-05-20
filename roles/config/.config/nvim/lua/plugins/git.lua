local M = {}

function M.setup()
	local ok, gitsigns = pcall(require, "gitsigns")
	if not ok then
		return
	end

	gitsigns.setup({
		signs = {
			add = { text = "|" },
			change = { text = "|" },
			delete = { text = "_" },
			topdelete = { text = "-" },
			changedelete = { text = "~" },
		},
		current_line_blame = false,
		on_attach = function(bufnr)
			local bt = vim.bo[bufnr].buftype
			if bt ~= "" and bt ~= "acwrite" then
				return false
			end

			local ft = vim.bo[bufnr].filetype
			if ft == "checkhealth" then
				return false
			end

			local name = vim.api.nvim_buf_get_name(bufnr)
			if name:match("^health://") then
				return false
			end

			return true
		end,
	})

	vim.keymap.set("n", "<leader>gb", "<cmd>Gitsigns toggle_current_line_blame<cr>", { desc = "Toggle git blame" })
	vim.keymap.set("n", "<leader>gd", "<cmd>Gitsigns diffthis<cr>", { desc = "Git diff" })
	vim.keymap.set("n", "]h", "<cmd>Gitsigns next_hunk<cr>", { desc = "Next hunk" })
	vim.keymap.set("n", "[h", "<cmd>Gitsigns prev_hunk<cr>", { desc = "Previous hunk" })
end

return M
