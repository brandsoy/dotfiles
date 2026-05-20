local M = {}

function M.setup()
	local ok, lint = pcall(require, "lint")
	if not ok then
		return
	end

	lint.linters_by_ft = {
		dotenv = { "dotenv_linter" },
	}

	vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
		group = vim.api.nvim_create_augroup("NvimLint", { clear = true }),
		callback = function(args)
			local name = vim.api.nvim_buf_get_name(args.buf)
			if vim.fn.fnamemodify(name, ":t"):match("^%.env") then
				lint.try_lint({ "dotenv_linter" })
			end
		end,
	})
end

return M
