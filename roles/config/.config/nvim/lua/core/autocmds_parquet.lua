local M = {}

function M.setup()
	vim.api.nvim_create_autocmd({ 'BufReadCmd' }, {
		pattern = '*.parquet',
		callback = function(args)
			local file = vim.fn.fnameescape(args.file)

			-- Query top 100 rows using DuckDB's built-in box formatting
			local cmd =
				string.format('duckdb -c "SELECT * FROM \'%s\' LIMIT 100"', file)
			local output = vim.fn.systemlist(cmd)

			if vim.v.shell_error ~= 0 then
				vim.notify(
					'Failed to read Parquet file with DuckDB',
					vim.log.levels.ERROR
				)
				return
			end

			-- Fill the current buffer with the table output
			vim.api.nvim_buf_set_lines(0, 0, -1, false, output)

			-- Buffer options: view-only, unmodifiable, non-file buffer
			vim.bo.buftype = 'nofile'
			vim.bo.bufhidden = 'hide'
			vim.bo.swapfile = false
			vim.bo.modifiable = false
		end,
	})
end

return M
