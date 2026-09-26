local M = {}

local function map(mode, lhs, rhs, desc, opts)
	local options = { silent = true, desc = desc }
	if opts then
		options = vim.tbl_extend('force', options, opts)
	end
	vim.keymap.set(mode, lhs, rhs, options)
end

function M.setup()
	map('n', '<leader>mt', '0i- [ ] <Esc>', 'Insert markdown todo')
	map('v', '<leader>mt', ':s/^/- [ ] /<CR>:noh<CR>', 'Make lines markdown todos')
	map('n', '<leader>mx', function()
		local line = vim.api.nvim_get_current_line()
		if line:match('%[ %]') then
			line = line:gsub('%[ %]', '[x]', 1)
		elseif line:match('%[x%]') then
			line = line:gsub('%[x%]', '[ ]', 1)
		end
		vim.api.nvim_set_current_line(line)
	end, 'Toggle markdown todo checkbox')

	map('n', '<leader>ml', 'i[]()<Esc>F[a', 'Insert markdown link')
	map('n', '<leader>mL', 'i[]()<Esc>F(a<C-r>+<Esc>F[a', 'Insert buffered markdown link')
	map('n', '<leader>mi', function()
		require('core.clipboard').paste_image()
	end, 'Paste clipboard image to attachments')
	map('n', '<leader>mp', '<cmd>MarkdownPreviewToggle<cr>', 'Markdown preview')
	map('n', '<leader>mr', '<cmd>RenderMarkdown toggle<cr>', 'Toggle markdown rendering')
end

return M
