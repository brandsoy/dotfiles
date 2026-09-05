local M = {}

function M.setup()
	local ok, lint = pcall(require, 'lint')
	if not ok then
		return
	end

	local project_config = require('config.lsp.project_config')
	local sqlfluff = require('lint.linters.sqlfluff')
	sqlfluff.args = function()
		return { 'lint', '--format=json', '--dialect', project_config.sql_dialect(0), '-' }
	end
	lint.linters.sqlfluff = sqlfluff

	lint.linters_by_ft = {
		bash = { 'shellcheck' },
		dockerfile = { 'hadolint' },
		dotenv = { 'dotenv_linter' },
		sh = { 'shellcheck' },
		sql = { 'sqlfluff' },
		yaml = { 'yamllint' },
		['yaml.ansible'] = { 'yamllint' },
		['yaml.docker-compose'] = { 'yamllint' },
		['yaml.gitlab'] = { 'yamllint' },
		['yaml.helm-values'] = { 'yamllint' },
	}

	vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
		group = vim.api.nvim_create_augroup("NvimLint", { clear = true }),
		callback = function(args)
			if not vim.api.nvim_buf_is_valid(args.buf) then
				return
			end
			if vim.b[args.buf].large_file then
				return
			end

			vim.api.nvim_buf_call(args.buf, function()
				lint.try_lint(nil, { ignore_errors = true })
			end)
		end,
	})
end

return M
