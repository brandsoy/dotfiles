local M = {}

function M.setup()
	vim.filetype.add({
		extension = {
			htmx = 'htmx',
		},
	})
end

return M
