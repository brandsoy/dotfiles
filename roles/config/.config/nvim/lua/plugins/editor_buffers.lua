local M = {}

function M.setup()
	pcall(function()
		require('mini.bufremove').setup()
	end)

	vim.keymap.set('n', '<leader>bd', function()
		local ok, bufremove = pcall(require, 'mini.bufremove')
		if ok then
			bufremove.delete()
		end
	end, { desc = 'Delete buffer' })

	vim.keymap.set('n', '<leader>bD', function()
		local ok, bufremove = pcall(require, 'mini.bufremove')
		if ok then
			bufremove.delete(0, true)
		end
	end, { desc = 'Delete buffer (force)' })
end

return M
