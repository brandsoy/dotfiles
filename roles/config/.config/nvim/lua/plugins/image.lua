local M = {}

function M.setup()
	local ok, image = pcall(require, 'image')
	if not ok then
		return
	end

	image.setup({
		opts = {
			image = {
				resolve = function(path, src)
					local api = require('obsidian.api')
					if api.path_is_note(path) then
						return api.resolve_attachment_path(src)
					end
				end,
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
