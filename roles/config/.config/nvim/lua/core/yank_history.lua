local M = {}

local history = {}
local MAX_ENTRIES = 100

local function summarize(text)
	local one_line = text:gsub('\n', ' ⏎ '):gsub('%s+', ' ')
	if #one_line > 120 then
		return one_line:sub(1, 119) .. '…'
	end
	return one_line
end

local function push(entry)
	if entry.text == '' then
		return
	end

	local last = history[1]
	if last and last.text == entry.text and last.regtype == entry.regtype then
		return
	end

	table.insert(history, 1, entry)
	if #history > MAX_ENTRIES then
		table.remove(history)
	end
end

function M.record()
	local ev = vim.v.event
	if not ev or ev.operator ~= 'y' then
		return
	end

	push({
		text = vim.fn.getreg('"'),
		regtype = vim.fn.getregtype('"'),
		timestamp = os.time(),
		file = vim.api.nvim_buf_get_name(0),
	})
end

function M.pick()
	if #history == 0 then
		vim.notify('Yank history is empty', vim.log.levels.INFO, { title = 'Neovim' })
		return
	end

	local ok_fzf, fzf = pcall(require, 'fzf-lua')
	if not ok_fzf then
		vim.notify('fzf-lua not available', vim.log.levels.WARN, { title = 'Neovim' })
		return
	end

	local items = {}
	for i, entry in ipairs(history) do
		local file = entry.file ~= '' and vim.fn.fnamemodify(entry.file, ':.') or '[no file]'
		items[#items + 1] = string.format('%03d  %s  [%s]', i, summarize(entry.text), file)
	end

	fzf.fzf_exec(items, {
		prompt = 'Yank History> ',
		actions = {
			default = function(selected)
				local line = selected and selected[1]
				if not line then
					return
				end

				local idx = tonumber(line:match('^(%d+)'))
				local entry = idx and history[idx]
				if not entry then
					return
				end

				vim.fn.setreg('"', entry.text, entry.regtype)
				vim.schedule(function()
					vim.api.nvim_feedkeys('p', 'n', false)
				end)
			end,
		},
	})
end

return M
