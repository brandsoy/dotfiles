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
		require('mini.surround').setup()
	end)

	pcall(function()
		require('mini.indentscope').setup({
			symbol = '│',
			options = { try_as_border = true },
		})
	end)

	pcall(function()
		require('colorizer').setup({
			'*', -- Highlight all supported filetypes.
			'!markdown', -- Disable color highlighting in Markdown files.
		})
	end)
end

return M
