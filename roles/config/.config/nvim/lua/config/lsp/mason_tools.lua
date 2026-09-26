local M = {}

function M.get()
	return {
		'ansible-lint',
		'hadolint',
		'hclfmt',
		'shfmt',
		'ruff',
		'prettierd',
		'gofumpt',
		'golines',
		'pgformatter',
		'sqlfluff',
		'yamllint',
		'roslyn',
		'dotenv-linter',
	}
end

return M
