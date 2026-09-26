local M = {}

function M.setup()
	vim.opt.completeopt = { 'menu', 'menuone', 'noselect', 'popup' }

	local ok, blink = pcall(require, 'blink.cmp')
	if not ok then
		return
	end

	blink.setup({
		keymap = {
			preset = 'default',
			-- Keep <Tab> available for Copilot's inline suggestions.
			['<Tab>'] = false,
			['<S-Tab>'] = false,
			['<M-l>'] = { 'snippet_forward', 'fallback' },
			['<M-h>'] = { 'snippet_backward', 'fallback' },
		},
		appearance = {
			nerd_font_variant = 'mono',
		},
		completion = {
			documentation = { auto_show = false },
		},
		sources = {
			default = { 'lsp', 'path', 'buffer' },
		},
		fuzzy = {
			implementation = 'prefer_rust_with_warning',
		},
	})
end

return M
