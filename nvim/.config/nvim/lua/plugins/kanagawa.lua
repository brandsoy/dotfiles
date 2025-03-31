return {
	"rebelot/kanagawa.nvim",
		config = function()
			require('kanagawa').setup({
				compile = true,             -- enable compiling the colorscheme
				undercurl = true,            -- enable undercurls
				commentStyle = { italic = true },
				functionStyle = {},
				keywordStyle = { italic = true},
				statementStyle = { bold = true },
				typeStyle = {},
				transparent = true,         -- do not set background 
				dimInactive = false,         -- dim inactive window `:h hl-NormalNC
				terminalColors = true,       -- define vim.g.terminal_color_{0,17
				overrides=function(colors)
					return {
						["@markup.link.url.markdown_inline"] = { link = "Special" }, -- (url
						["@markup.link.label.markdown_inline"] = { link = "WarningMsg" }, -- [label
						["@markup.italic.markdown_inline"] = { link = "Exception" }, -- *italic
						["@markup.raw.markdown_inline"] = { link = "String" }, -- `code
						["@markup.list.markdown"] = { link = "Function" }, -- + 
						["@markup.quote.markdown"] = { link = "Error" }, -- > 
						["@markup.list.checked.markdown"] = { link = "WarningMsg" } -- - [X] checked list 
					}
				end
			});
			vim.cmd("colorscheme kanagawa")
		end,
	}

