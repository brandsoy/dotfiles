local M = {}

function M.setup()
	local group = vim.api.nvim_create_augroup('LargeFile', {})
	vim.api.nvim_create_autocmd('BufReadPre', {
		group = group,
		callback = function(args)
			local file = vim.api.nvim_buf_get_name(args.buf)
			local ok, stat = pcall(vim.uv.fs_stat, file)
			if not ok or not stat then
				return
			end
			if stat.size > 500 * 1024 then
				vim.b.large_file = true
				vim.cmd([[syntax off]])
				pcall(vim.treesitter.stop, args.buf)
				pcall(vim.diagnostic.disable, args.buf)
				vim.opt_local.swapfile = false
				vim.opt_local.foldmethod = 'manual'
				vim.opt_local.undolevels = -1
			end
		end,
	})
end

return M
