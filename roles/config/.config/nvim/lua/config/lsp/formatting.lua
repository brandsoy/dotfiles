local M = {}

local project_config = require("config.lsp.project_config")

local function project_formatter(bufnr, opts)
	opts = opts or {}

	if opts.allow_biome ~= false and project_config.has_biome(bufnr) then
		return opts.biome or { "biome", stop_after_first = true }
	end

	if project_config.has_prettier(bufnr) then
		return opts.prettier or { "prettierd", "prettier", stop_after_first = true }
	end

	return {}
end

local function project_web_formatter(bufnr)
	return project_formatter(bufnr)
end

local function project_prettier_formatter(bufnr)
	return project_formatter(bufnr, { allow_biome = false })
end

function M.setup_conform()
	local ok, conform = pcall(require, "conform")
	if not ok then
		return
	end

	conform.setup({
		format_on_save = function(bufnr)
			if vim.b[bufnr].large_file then
				return nil
			end
			return { lsp_format = "fallback", timeout_ms = 1000 }
		end,
		formatters_by_ft = {
			lua = { "stylua" },
			python = { "ruff_fix", "ruff_format" },
			astro = project_web_formatter,
			css = project_web_formatter,
			graphql = project_web_formatter,
			html = project_web_formatter,
			javascript = project_web_formatter,
			javascriptreact = project_web_formatter,
			json = project_web_formatter,
			jsonc = project_web_formatter,
			svelte = project_web_formatter,
			typescript = project_web_formatter,
			typescriptreact = project_web_formatter,
			vue = project_web_formatter,
			yaml = project_prettier_formatter,
			markdown = project_prettier_formatter,
			go = { "golines", "gofumpt" },
			sql = { "pg_format" },
			terraform = { "terraform_fmt" },
			hcl = { "terraform_fmt" },
		},
	})
end

return M
