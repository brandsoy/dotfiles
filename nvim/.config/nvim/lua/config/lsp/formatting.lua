local M = {}

local function root_has_file(filename, patterns)
	local root = vim.fs.dirname(filename)
	return vim.fs.find(patterns, { path = root, upward = true })[1] ~= nil
end

function M.setup_conform()
	local conform = require("conform")
	conform.setup({
		format_on_save = { lsp_fallback = true, timeout_ms = 1000 },
		formatters = {
			biome = {
				condition = function(ctx)
					return root_has_file(ctx.filename, {
						"biome.json",
						"biome.jsonc",
						"biome.config.json",
						"biome.config.jsonc",
					})
				end,
			},
			prettier = {
				condition = function(ctx)
					return root_has_file(ctx.filename, {
						".prettierrc",
						".prettierrc.json",
						".prettierrc.js",
						".prettierrc.yaml",
						".prettierrc.yml",
						"prettier.config.js",
						"prettier.config.cjs",
						"prettier.config.mjs",
						"package.json",
					})
				end,
			},
		},
		formatters_by_ft = {
			lua = { "stylua" },
			javascript = { "biome", "prettierd", "prettier" },
			javascriptreact = { "biome", "prettierd", "prettier" },
			typescript = { "biome", "prettierd", "prettier" },
			typescriptreact = { "biome", "prettierd", "prettier" },
			json = { "biome", "prettierd", "prettier" },
			yaml = { "biome", "prettierd", "prettier" },
			markdown = { "prettierd", "prettier" },
			go = { "golines", "gofumpt" },
			sql = { "pg_format" },
		},
	})
end

function M.setup_lint()
	local lint = require("lint")
	lint.linters_by_ft = {
		javascript = { "eslint_d" },
		javascriptreact = { "eslint_d" },
		typescript = { "eslint_d" },
		typescriptreact = { "eslint_d" },
	}

	vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
		callback = function()
			require("lint").try_lint()
		end,
	})
end

return M
