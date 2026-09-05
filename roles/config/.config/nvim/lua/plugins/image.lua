local M = {}

function M.setup()
	local ok, image = pcall(require, 'image')
	if not ok then
		return
	end

	image.setup({
		integrations = {
			markdown = {
				download_remote_images = false,
			},
		},
	})

	-- vim.keymap.set(
	-- 	'n',
	-- 	'<leader>oh',
	-- 	'<cmd>image Help<cr>',
	-- 	{ desc = 'image help' }
	-- )
	-- vim.keymap.set(
	-- 	'n',
	-- 	'<leader>gd',
	-- 	'<cmd>Gitsigns diffthis<cr>',
	-- 	{ desc = 'Git diff' }
	-- )
end

return M
