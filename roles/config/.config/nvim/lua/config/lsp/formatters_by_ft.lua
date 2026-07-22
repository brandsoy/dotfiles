local M = {}

local project_formatters = require('config.lsp.formatters_project')

function M.get()
	return {
		lua = { 'stylua' },
		python = { 'ruff_fix', 'ruff_format' },
		astro = project_formatters.web,
		css = project_formatters.web,
		graphql = project_formatters.web,
		htmx = project_formatters.web,
		html = project_formatters.web,
		javascript = project_formatters.web,
		javascriptreact = project_formatters.web,
		json = project_formatters.web,
		jsonc = project_formatters.web,
		svelte = project_formatters.web,
		typescript = project_formatters.web,
		typescriptreact = project_formatters.web,
		vue = project_formatters.web,
		yaml = project_formatters.prettier_only,
		markdown = project_formatters.prettier_only,
		go = { 'golines', 'gofumpt' },
		sql = function(bufnr)
			if require('config.lsp.project_config').sql_dialect(bufnr) == 'tsql' then
				return { 'sqlfluff_tsql' }
			end
			return { 'pg_format' }
		end,
		terraform = { 'terraform_fmt' },
		hcl = { 'terraform_fmt' },
		templ = { 'templ' },
	}
end

return M
