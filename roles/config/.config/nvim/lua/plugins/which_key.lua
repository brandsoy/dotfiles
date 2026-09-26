local M = {}

function M.setup()
	local ok, which_key = pcall(require, 'which-key')
	if not ok then
		return
	end

	which_key.setup({
		triggers = {
			{ '<leader>', mode = { 'n', 'v' } },
			{ 'g', mode = { 'n', 'v' } },
			{ '[', mode = 'n' },
			{ ']', mode = 'n' },
		},
	})
end

return M
