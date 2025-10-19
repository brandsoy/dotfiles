local M = {}

function M.setup()
	local blink_ok, blink = pcall(require, "blink.cmp")
	if not blink_ok then
		vim.notify("blink.cmp not available; completion disabled", vim.log.levels.WARN)
		return
	end

	vim.opt.completeopt = { "menu", "menuone", "noselect" }

	require("luasnip.loaders.from_vscode").lazy_load()

	blink.setup({
		keymap = {
			preset = "default", -- <Tab> confirm, <C-n>/<C-p> navigate
		},
		appearance = {
			nerd_font_variant = "mono",
		},
		fuzzy = {
			implementation = "prefer_rust",
			prebuilt_binaries = {
				force_version = "v1.7.0",
			},
		},
		completion = {
			documentation = { auto_show = true }, -- show docs automatically
			ghost_text = { enabled = true }, -- inline ghost text
		},
		snippets = {
			expand = function(body)
				require("luasnip").lsp_expand(body)
			end,
		},
		sources = {
			default = { "lsp", "path", "snippets", "buffer" },
		},
	})
end

return M
