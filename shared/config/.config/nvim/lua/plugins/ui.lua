return {
	{
		"oskarnurm/koda.nvim",
		lazy = true,
		cmd = "Colorscheme",
		priority = 1000,
		config = function()
			require("koda").setup({ transparent = true })
		end,
	},
	{
		"folke/tokyonight.nvim",
		lazy = true,
		cmd = "Colorscheme",
		priority = 1000,
	},
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = true,
		cmd = "Colorscheme",
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				flavour = "auto",
				background = { light = "latte", dark = "mocha" },
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
		end,
	},
	{
		"projekt0n/github-nvim-theme",
		name = "github-theme",
		lazy = true,
		priority = 1000,
		config = function()
			require("github-theme").setup({})
		end,
	},
	{
		"rose-pine/neovim",
		name = "rose-pine",
		lazy = true,
		cmd = "Colorscheme",
		priority = 1000,
	},

	{
		"p00f/alabaster.nvim",
		name = "alabaster",
		lazy = true,
		cmd = "Colorscheme",
		priority = 1000,
	},
	{
		"zenbones-theme/zenbones.nvim",
		name = "zenbones",
		lazy = true,
		priority = 1000,
		dependencies = { "rktjmp/lush.nvim" },
		cmd = "Colorscheme",
	},
	{
		"navarasu/onedark.nvim",
		name = "onedark",
		lazy = true,
		cmd = "Colorscheme",
		config = function()
			require("onedark").setup({
				style = "darker",
			})
		end,
	},
	{
		"0xleodevv/oc-2.nvim",
		lazy = false,
		cmd = "Colorscheme",
		priority = 1,
		config = function()
			require("oc2").setup({
				theme = "oc-2",
			})
			require("core.theme").startup("tokyonight-night")
		end,
	},
	-- END THEMES
	{
		"nvim-mini/mini.statusline",
		event = "VeryLazy",
		config = function()
			local mini_statusline = require("mini.statusline")

			local function active_content()
				local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
				local git = MiniStatusline.section_git({ trunc_width = 40 })
				local diff = MiniStatusline.section_diff({ trunc_width = 75 })
				local diagnostics = MiniStatusline.section_diagnostics({ trunc_width = 75 })
				local lsp = MiniStatusline.section_lsp({ trunc_width = 75 })
				local filename = MiniStatusline.section_filename({ trunc_width = 140 })
				local fileinfo = MiniStatusline.section_fileinfo({ trunc_width = 120 })
				local location = MiniStatusline.section_location({ trunc_width = 75 })
				local search = MiniStatusline.section_searchcount({ trunc_width = 75 })

				return MiniStatusline.combine_groups({
					{ hl = mode_hl, strings = { mode } },
					{ hl = "MiniStatuslineFilename", strings = { filename } },
					{ hl = "MiniStatuslineDevinfo", strings = { git, diff, diagnostics, lsp } },
					"%=",
					{ hl = "MiniStatuslineFileinfo", strings = { search, location, fileinfo } },
				})
			end

			local function inactive_content()
				local filename = MiniStatusline.section_filename({ trunc_width = 140 })
				local fileinfo = MiniStatusline.section_fileinfo({ trunc_width = 120 })
				local location = MiniStatusline.section_location({ trunc_width = 75 })

				return MiniStatusline.combine_groups({
					{ hl = "MiniStatuslineInactive", strings = { filename } },
					"%=",
					{ hl = "MiniStatuslineInactive", strings = { fileinfo, location } },
				})
			end

			local function apply_statusline_theme()
				if vim.g.colors_name == "oc-2" or vim.g.colors_name == "oc-2-noir" then
					local oc2 = require("oc2")
					local variant = oc2.config.theme == "oc-2-noir" and "noir" or "dark"
					local colors = require("oc2.palettes").get(variant)

					vim.api.nvim_set_hl(0, "MiniStatuslineModeNormal", { bg = colors.orange, fg = colors.bg, bold = true })
					vim.api.nvim_set_hl(0, "MiniStatuslineModeInsert", { bg = colors.red, fg = colors.bg, bold = true })
					vim.api.nvim_set_hl(0, "MiniStatuslineModeVisual", { bg = colors.green, fg = colors.bg, bold = true })
					vim.api.nvim_set_hl(0, "MiniStatuslineModeReplace", { bg = colors.orange, fg = colors.bg, bold = true })
					vim.api.nvim_set_hl(0, "MiniStatuslineModeCommand", { bg = colors.teal, fg = colors.bg, bold = true })
					vim.api.nvim_set_hl(0, "MiniStatuslineModeOther", { bg = colors.teal, fg = colors.bg, bold = true })
					vim.api.nvim_set_hl(0, "MiniStatuslineDevinfo", { bg = colors.bg2, fg = colors.grey2 })
					vim.api.nvim_set_hl(0, "MiniStatuslineFilename", { bg = colors.bg2, fg = colors.grey3 })
					vim.api.nvim_set_hl(0, "MiniStatuslineFileinfo", { bg = colors.bg2, fg = colors.grey3 })
					vim.api.nvim_set_hl(0, "MiniStatuslineInactive", { bg = colors.bg2, fg = colors.orange, bold = true })
					return
				end

				vim.api.nvim_set_hl(0, "MiniStatuslineModeNormal", { link = "Cursor" })
				vim.api.nvim_set_hl(0, "MiniStatuslineModeInsert", { link = "DiffChange" })
				vim.api.nvim_set_hl(0, "MiniStatuslineModeVisual", { link = "DiffAdd" })
				vim.api.nvim_set_hl(0, "MiniStatuslineModeReplace", { link = "DiffDelete" })
				vim.api.nvim_set_hl(0, "MiniStatuslineModeCommand", { link = "DiffText" })
				vim.api.nvim_set_hl(0, "MiniStatuslineModeOther", { link = "IncSearch" })
				vim.api.nvim_set_hl(0, "MiniStatuslineDevinfo", { link = "StatusLine" })
				vim.api.nvim_set_hl(0, "MiniStatuslineFilename", { link = "StatusLineNC" })
				vim.api.nvim_set_hl(0, "MiniStatuslineFileinfo", { link = "StatusLine" })
				vim.api.nvim_set_hl(0, "MiniStatuslineInactive", { link = "StatusLineNC" })
			end

			mini_statusline.setup({
				content = {
					active = active_content,
					inactive = inactive_content,
				},
			})
			apply_statusline_theme()

			vim.api.nvim_create_autocmd("ColorScheme", {
				callback = apply_statusline_theme,
				desc = "Apply theme-aware MiniStatusline highlights",
			})
		end,
	},

	{
		"j-hui/fidget.nvim",
		event = "LspAttach",
		opts = {
			notification = {
				window = { winblend = 0 },
			},
		},
	},
}
