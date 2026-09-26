local M = {}

function M.setup()
	vim.keymap.set('n', '<leader>gg', function()
		if vim.fn.executable('lazygit') == 1 then
			vim.cmd('terminal lazygit')
			local term_buf = vim.api.nvim_get_current_buf()
			vim.api.nvim_create_autocmd('TermClose', {
				buffer = term_buf,
				once = true,
				callback = function()
					vim.schedule(function()
						if vim.api.nvim_buf_is_valid(term_buf) then
							vim.api.nvim_buf_delete(term_buf, { force = true })
						end
					end)
				end,
			})
			vim.cmd('startinsert')
		else
			vim.notify('lazygit executable not found', vim.log.levels.WARN)
		end
	end, { desc = 'LazyGit' })
end

return M
