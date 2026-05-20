local M = {}

local modes = {
	n = "N",
	no = "N?",
	v = "V",
	V = "VL",
	["\22"] = "VB",
	s = "S",
	S = "SL",
	i = "I",
	R = "R",
	c = "C",
	t = "T",
}

local function mode_label()
	return modes[vim.api.nvim_get_mode().mode] or "?"
end

local function file_label()
	local name = vim.api.nvim_buf_get_name(0)
	if name == "" then
		name = "[No Name]"
	else
		name = vim.fn.pathshorten(vim.fn.fnamemodify(name, ":~:."))
	end

	if vim.bo.modified then
		name = name .. " [+]"
	end
	if not vim.bo.modifiable or vim.bo.readonly then
		name = name .. " [RO]"
	end

	name = name:gsub("%%", "%%%%")
	return name
end

local function git_label()
	local head = vim.b.gitsigns_head
	if head and head ~= "" then
		return "git:" .. head
	end
	return ""
end

local function diagnostics_label()
	local e = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
	local w = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
	if e == 0 and w == 0 then
		return ""
	end
	return string.format("E:%d W:%d", e, w)
end

local function lsp_label()
	local names = {}
	for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
		if client.name ~= "copilot" then
			names[#names + 1] = client.name
		end
	end
	if #names == 0 then
		return "LSP:-"
	end
	table.sort(names)
	return "LSP:" .. table.concat(names, ",")
end

function M.render()
	local left = table.concat({ mode_label(), file_label() }, " ")

	local middle_parts = {}
	local git = git_label()
	if git ~= "" then
		table.insert(middle_parts, git)
	end
	table.insert(middle_parts, lsp_label())
	local diag = diagnostics_label()
	if diag ~= "" then
		table.insert(middle_parts, diag)
	end
	local middle = table.concat(middle_parts, "  ")

	local ft = vim.bo.filetype ~= "" and vim.bo.filetype or "text"
	local enc = (vim.bo.fileencoding ~= "" and vim.bo.fileencoding) or vim.o.encoding
	local ff = vim.bo.fileformat
	local right = string.format("%s %s %s  %%p%%%% %%l:%%c", ft, enc, ff)

	return table.concat({ left, "%=", middle, "%=", right }, " ")
end

function M.setup()
	vim.o.statusline = "%!v:lua.require'core.statusline'.render()"
end

return M
