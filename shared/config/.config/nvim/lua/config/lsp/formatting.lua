local M = {}

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
			return { lsp_fallback = true, timeout_ms = 1000 }
		end,
		formatters_by_ft = {
			lua = { "stylua" },
			javascript = { "prettierd", "prettier", stop_after_first = true },
			javascriptreact = { "prettierd", "prettier", stop_after_first = true },
			typescript = { "prettierd", "prettier", stop_after_first = true },
			typescriptreact = { "prettierd", "prettier", stop_after_first = true },
			json = { "prettierd", "prettier", stop_after_first = true },
			yaml = { "prettierd", "prettier", stop_after_first = true },
			markdown = { "prettierd", "prettier", stop_after_first = true },
			go = { "golines", "gofumpt" },
			sql = { "pg_format" },
			terraform = { "terraform_fmt" },
			hcl = { "terraform_fmt" },
		},
	})
end

return M
