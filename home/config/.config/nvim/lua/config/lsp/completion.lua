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
			["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
			["<C-e>"] = { "hide" },
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
			documentation = {
				auto_show = true, -- Show docs automatically for better DX
				auto_show_delay_ms = 200,
			},
			menu = {
				draw = {
					treesitter = { "lsp" }, -- Highlight LSP items with treesitter
				},
			},
			ghost_text = { enabled = false }, -- Keep this off for performance
		},
		sources = {
			default = { "lsp", "path", "buffer" }, -- Add buffer completion
			providers = {
				buffer = {
					min_keyword_length = 4, -- Only suggest buffer words > 3 chars
				},
			},
		},
	})
end

return M
