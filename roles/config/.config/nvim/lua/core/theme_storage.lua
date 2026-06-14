local M = {}

local data = require('core.theme_data')

function M.save_theme(name)
	local state_dir = vim.fn.fnamemodify(data.state_file, ':h')
	if vim.fn.isdirectory(state_dir) == 0 then
		vim.fn.mkdir(state_dir, 'p')
	end
	vim.fn.writefile({ name }, data.state_file)
end

function M.read_saved_theme()
	if vim.fn.filereadable(data.state_file) ~= 1 then
		return nil
	end
	local lines = vim.fn.readfile(data.state_file)
	local name = lines[1]
	if name and data.theme_lookup[name] then
		return name
	end
	return nil
end

return M
