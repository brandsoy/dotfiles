-- Install remaining completion plugins
vim.pack.add({
	{ src = "https://github.com/L3MON4D3/LuaSnip" },
	{ src = "https://github.com/rafamadriz/friendly-snippets" },
})

-- Recommended completeopt for modern completion UIs
vim.opt.completeopt = { "menu", "menuone", "noselect" }

require("luasnip.loaders.from_vscode").lazy_load()

-- Blink CMP setup
require("blink.cmp").setup({
	keymap = {
		preset = "default", -- <Tab> confirm, <C-n>/<C-p> navigate
	},
	appearance = {
		nerd_font_variant = "mono",
	},
	fuzzy = {
		implementation = "prefer_rust",
		prebuilt_binaries = {
			force_version = nil,
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
