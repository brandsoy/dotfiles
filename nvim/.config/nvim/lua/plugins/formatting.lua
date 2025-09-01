return {
	{
		"stevearc/conform.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = function()
			local util = require("conform.util")

			local function has(files)
				return util.root_file(files) ~= nil
			end

			return {
				notify_on_error = false,
				format_on_save = function(bufnr)
					if vim.bo[bufnr].buftype ~= "" or vim.api.nvim_buf_line_count(bufnr) > 10000 then
						return
					end
					return { lsp_fallback = true, timeout_ms = 1500 }
				end,

				-- Prefer Biome; otherwise Prettier; otherwise ESLint (when configs exist)
				formatters_by_ft = {
					javascript = { "biome", "prettierd", "prettier", "eslint_d", stop_after_first = true },
					typescript = { "biome", "prettierd", "prettier", "eslint_d", stop_after_first = true },
					javascriptreact = { "biome", "prettierd", "prettier", "eslint_d", stop_after_first = true },
					typescriptreact = { "biome", "prettierd", "prettier", "eslint_d", stop_after_first = true },
					json = { "biome", "prettierd", "prettier", stop_after_first = true },
					jsonc = { "biome", "prettierd", "prettier", stop_after_first = true },
					markdown = { "biome", "prettierd", "prettier", stop_after_first = true },
					yaml = { "prettierd", "prettier", stop_after_first = true }, -- Biome doesn't handle YAML; use Prettier
					lua = { "stylua" },
					sh = { "shfmt" },
					go = {},
					rust = {},
					cs = {},
				},

				-- Only activate a formatter if the project uses it
				formatters = {
					biome = {
						condition = function(_ctx)
							return has({ "biome.json", "biome.jsonc" })
						end,
					},
					-- Try prettierd first (daemon), then prettier
					prettierd = {
						condition = function(_ctx)
							return has({
								".prettierrc",
								".prettierrc.json",
								".prettierrc.js",
								".prettierrc.cjs",
								".prettierrc.mjs",
								".prettierrc.yaml",
								".prettierrc.yml",
								"prettier.config.js",
								"prettier.config.cjs",
								"prettier.config.mjs",
							})
						end,
					},
					prettier = {
						prefer_local = "node_modules/.bin",
						condition = function(_ctx)
							return has({
								".prettierrc",
								".prettierrc.json",
								".prettierrc.js",
								".prettierrc.cjs",
								".prettierrc.mjs",
								".prettierrc.yaml",
								".prettierrc.yml",
								"prettier.config.js",
								"prettier.config.cjs",
								"prettier.config.mjs",
							})
						end,
					},
					eslint_d = {
						prefer_local = "node_modules/.bin",
						condition = function(_ctx)
							return has({
								".eslintrc",
								".eslintrc.cjs",
								".eslintrc.js",
								".eslintrc.mjs",
								".eslintrc.json",
								".eslintrc.yaml",
								".eslintrc.yml",
								"eslint.config.js",
								"eslint.config.cjs",
								"eslint.config.mjs",
								"eslint.config.ts",
							})
						end,
					},
				},
			}
		end,
	},
	{
		"windwp/nvim-ts-autotag",
		config = function()
			require("nvim-ts-autotag").setup()
		end,
	},
}
