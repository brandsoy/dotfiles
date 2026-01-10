local M = {}

function M.setup()
	local blink_ok, blink = pcall(require, "blink.cmp")
	if not blink_ok then
		vim.notify("blink.cmp not available; completion disabled", vim.log.levels.WARN)
		return
	end

	vim.opt.completeopt = { "menu", "menuone", "noselect" }

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
			documentation = { auto_show = false }, -- avoid extra UI work
			ghost_text = { enabled = false }, -- reduce inline rendering
		},
		sources = {
			default = { "lsp", "path" },
		},
	})
end

return M
