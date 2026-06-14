local M = {}

function M.setup()
	pcall(function()
		require('mini.ai').setup()
	end)

	pcall(function()
		require('mini.move').setup({
			mappings = {
				down = '<A-j>',
				up = '<A-k>',
				line_down = '<A-j>',
				line_up = '<A-k>',
			},
		})
	end)

	pcall(function()
		require('mini.pairs').setup({
			modes = { insert = true, command = false, terminal = false },
		})
	end)

	pcall(function()
		require('mini.comment').setup()
	end)

	pcall(function()
		require('mini.diff').setup({})
	end)

	pcall(function()
		require('mini.git').setup()
	end)

	pcall(function()
		require('mini.surround').setup()
	end)

	pcall(function()
		local anchor = 'NE' -- top-right
		require('mini.clue').setup({
			window = {
				config = { anchor = anchor, row = 'auto', col = 'auto', width = 'auto' },
			},
			triggers = {
				{ mode = 'n', keys = '<leader>' },
				{ mode = 'x', keys = '<leader>' },
				{ mode = 'n', keys = 'g' },
				{ mode = 'n', keys = '[' },
				{ mode = 'n', keys = ']' },
			},
			clues = {
				require('mini.clue').gen_clues.builtin_completion(),
				require('mini.clue').gen_clues.g(),
				require('mini.clue').gen_clues.marks(),
				require('mini.clue').gen_clues.registers(),
				require('mini.clue').gen_clues.windows(),
				require('mini.clue').gen_clues.z(),
			},
		})
	end)

	pcall(function()
		require('colorizer').setup()
	end)
end

return M
