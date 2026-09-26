local M = {}

function M.setup()
	require('tabout').setup({
		tabkey = '<Tab>',
		backwards_tabkey = '<S-Tab>',
		act_as_tab = true,
		completion = true,
	})
end

return M
