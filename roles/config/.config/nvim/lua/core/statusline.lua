local M = {}

local parts = require('core.statusline_parts')

function M.render()
	local left = table.concat({ parts.mode_label(), parts.file_label() }, ' ')

	local middle_parts = {}
	local git = parts.git_label()
	if git ~= '' then
		table.insert(middle_parts, git)
	end
	table.insert(middle_parts, parts.lsp_label())
	local diag = parts.diagnostics_label()
	if diag ~= '' then
		table.insert(middle_parts, diag)
	end
	local middle = table.concat(middle_parts, '  ')

	return table.concat({ left, '%=', middle, '%=', parts.right_label() }, ' ')
end

function M.setup()
	vim.o.statusline = "%!v:lua.require'core.statusline'.render()"
end

return M
