local M = {}

function M.setup()
	pcall(function()
		local mini_notify = require('mini.notify')
		mini_notify.setup()
		vim.notify = mini_notify.make_notify()
		vim.keymap.set('n', '<leader>nh', function()
			mini_notify.show_history()
		end, { desc = 'Notification history' })
	end)
end

return M
