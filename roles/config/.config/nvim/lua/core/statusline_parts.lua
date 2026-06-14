local M = {}

local modes = {
	n = 'N',
	no = 'N?',
	v = 'V',
	V = 'VL',
	['\22'] = 'VB',
	s = 'S',
	S = 'SL',
	i = 'I',
	R = 'R',
	c = 'C',
	t = 'T',
}

function M.mode_label()
	return modes[vim.api.nvim_get_mode().mode] or '?'
end

function M.file_label()
	local name = vim.api.nvim_buf_get_name(0)
	if name == '' then
		name = '[No Name]'
	else
		name = vim.fn.pathshorten(vim.fn.fnamemodify(name, ':~:.'))
	end

	if vim.bo.modified then
		name = name .. ' [+]'
	end
	if not vim.bo.modifiable or vim.bo.readonly then
		name = name .. ' [RO]'
	end

	return name:gsub('%%', '%%%%')
end

function M.git_label()
	local head = vim.b.gitsigns_head
	if head and head ~= '' then
		return 'git:' .. head
	end
	return ''
end

function M.diagnostics_label()
	local e = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
	local w = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
	if e == 0 and w == 0 then
		return ''
	end
	return string.format('E:%d W:%d', e, w)
end

function M.lsp_label()
	local names = {}
	local seen = {}
	for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
		if client.name ~= 'copilot' and not seen[client.name] then
			seen[client.name] = true
			names[#names + 1] = client.name
		end
	end
	if #names == 0 then
		return 'LSP:-'
	end
	table.sort(names)
	return 'LSP:' .. table.concat(names, ',')
end

function M.right_label()
	local ft = vim.bo.filetype ~= '' and vim.bo.filetype or 'text'
	local enc = (vim.bo.fileencoding ~= '' and vim.bo.fileencoding) or vim.o.encoding
	local ff = vim.bo.fileformat
	return string.format('%s %s %s  %%p%%%% %%l:%%c', ft, enc, ff)
end

return M
