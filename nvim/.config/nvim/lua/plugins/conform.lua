return {
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
				javascript = { "biome", "prettierd", "prettier", "eslint_d" },
				typescript = { "biome", "prettierd", "prettier", "eslint_d" },
				javascriptreact = { "biome", "prettierd", "prettier", "eslint_d" },
				typescriptreact = { "biome", "prettierd", "prettier", "eslint_d" },
				json = { "biome", "prettierd", "prettier" },
				jsonc = { "biome", "prettierd", "prettier" },
				markdown = { "biome", "prettierd", "prettier" },
				yaml = { "prettierd", "prettier" }, -- Biome doesn't handle YAML; use Prettier
				lua = { "stylua" },
				sh = { "shfmt" },
				-- let LSP handle go/rust if you prefer
				go = {},
				rust = {},
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
}
