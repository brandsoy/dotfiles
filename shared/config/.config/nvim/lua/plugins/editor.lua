local M = {}

function M.setup()
	vim.keymap.set("n", "<leader>e", "<cmd>Explore<cr>", { desc = "Explorer" })
	vim.keymap.set("n", "<leader>fe", "<cmd>Lexplore<cr>", { desc = "Explorer focus" })
	vim.keymap.set("n", "<leader>gg", function()
		if vim.fn.executable("lazygit") == 1 then
			vim.cmd("terminal lazygit")
		else
			vim.notify("lazygit executable not found", vim.log.levels.WARN)
		end
	end, { desc = "LazyGit" })

	pcall(function()
		require("mini.bufremove").setup()
	end)
	vim.keymap.set("n", "<leader>bd", function()
		local ok, bufremove = pcall(require, "mini.bufremove")
		if ok then
			bufremove.delete()
		end
	end, { desc = "Delete buffer" })
	vim.keymap.set("n", "<leader>bD", function()
		local ok, bufremove = pcall(require, "mini.bufremove")
		if ok then
			bufremove.delete(0, true)
		end
	end, { desc = "Delete buffer (force)" })
	pcall(function()
		require("mini.ai").setup()
	end)
	pcall(function()
		require("mini.move").setup({
			mappings = {
				down = "<A-j>",
				up = "<A-k>",
				line_down = "<A-j>",
				line_up = "<A-k>",
			},
		})
	end)
	pcall(function()
		require("mini.pairs").setup({ modes = { insert = true, command = false, terminal = false } })
	end)
	pcall(function()
		require("mini.comment").setup()
	end)
	pcall(function()
		local mini_notify = require("mini.notify")
		mini_notify.setup()
		vim.notify = mini_notify.make_notify()
	end)
	pcall(function()
		require("mini.diff").setup({})
	end)
	pcall(function()
		require("mini.git").setup()
	end)
	pcall(function()
		require("mini.surround").setup()
	end)
	pcall(function()
		require("mini.clue").setup({
			triggers = {
				{ mode = "n", keys = "<leader>" },
				{ mode = "x", keys = "<leader>" },
				{ mode = "n", keys = "g" },
				{ mode = "n", keys = "[" },
				{ mode = "n", keys = "]" },
			},
			clues = {
				require("mini.clue").gen_clues.builtin_completion(),
				require("mini.clue").gen_clues.g(),
				require("mini.clue").gen_clues.marks(),
				require("mini.clue").gen_clues.registers(),
				require("mini.clue").gen_clues.windows(),
				require("mini.clue").gen_clues.z(),
			},
		})
	end)
end

return M
