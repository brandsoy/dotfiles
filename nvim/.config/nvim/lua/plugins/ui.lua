return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = false,
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				flavour = "auto",
				background = {
					light = "latte",
					dark = "mocha",
				},
				transparent_background = true,
				integrations = {
					blink_cmp = true,
					fzf = true,
					mason = true,
					markdown = true,
					mini = { enabled = true },
					native_lsp = { enabled = true },
					treesitter = true,
					which_key = true,
				},
			})

			vim.cmd.colorscheme("catppuccin")
		end,
	},
	{
		"nvim-mini/mini.statusline",
		event = "VeryLazy",
		config = function()
			local palette = require("catppuccin.palettes").get_palette()
			local set_hl = vim.api.nvim_set_hl
			set_hl(0, "MiniStatuslineModeNormal", { fg = palette.base, bg = palette.blue, bold = true })
			set_hl(0, "MiniStatuslineModeInsert", { fg = palette.base, bg = palette.green, bold = true })
			set_hl(0, "MiniStatuslineModeVisual", { fg = palette.base, bg = palette.mauve, bold = true })
			set_hl(0, "MiniStatuslineModeReplace", { fg = palette.base, bg = palette.red, bold = true })
			set_hl(0, "MiniStatuslineModeCommand", { fg = palette.base, bg = palette.peach, bold = true })
			set_hl(0, "MiniStatuslineModeOther", { fg = palette.base, bg = palette.teal, bold = true })
			set_hl(0, "MiniStatuslineDevinfo", { fg = palette.subtext0, bg = palette.surface0 })
			set_hl(0, "MiniStatuslineFileinfo", { fg = palette.subtext0, bg = palette.surface0 })
			set_hl(0, "MiniStatuslineFilename", { fg = palette.text, bg = palette.surface0 })
			set_hl(0, "MiniStatuslineInactive", { fg = palette.surface2, bg = palette.base })
			require("mini.statusline").setup()
		end,
	},
}
