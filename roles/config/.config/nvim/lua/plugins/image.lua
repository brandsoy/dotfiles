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
				-- ImageMagick can fail on SVGs that reference unavailable fonts.
				-- Leave those to the markdown preview instead of raising callbacks.
				resolve_image_path = function(document_path, image_path, fallback)
					if image_path:match('%.svg([?#].*)?$') then
						return nil
					end

					local api = require('obsidian.api')
					if api.path_is_note(document_path) then
						return api.resolve_attachment_path(image_path)
					end

					return fallback(document_path, image_path)
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
