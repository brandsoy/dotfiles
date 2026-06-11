local M = {}

local function notify(message, level)
	vim.notify(message, level or vim.log.levels.INFO, { title = 'Clipboard' })
end

local function get_platform()
	if vim.fn.has('mac') == 1 then
		return 'mac'
	end
	if vim.env.WAYLAND_DISPLAY then
		return 'wayland'
	end
	if vim.env.DISPLAY then
		return 'x11'
	end
	return nil
end

local function ensure_dir(path)
	if vim.fn.isdirectory(path) == 1 then
		return true
	end
	return vim.fn.mkdir(path, 'p') ~= 0
end

local attachment_subdirs = {
	'attachments',
	'assets',
}

function M.attachment_dir(base_dir)
	return vim.fs.joinpath(base_dir, attachment_subdirs[1])
end

function M.attachment_link(filename)
	return string.format('![](%s/%s)', attachment_subdirs[1], filename)
end

function M.attachment_candidates(base_dir, file)
	local candidates = {
		vim.fn.fnamemodify(file, ':p'),
		vim.fs.joinpath(base_dir, file),
	}

	for _, subdir in ipairs(attachment_subdirs) do
		candidates[#candidates + 1] = vim.fs.joinpath(base_dir, subdir, file)
	end

	return candidates
end

function M.paste_image()
	if vim.bo.filetype ~= 'markdown' and vim.bo.filetype ~= 'mdx' then
		notify('Not a markdown file', vim.log.levels.WARN)
		return
	end

	local filepath = vim.fn.expand('%:p')
	if filepath == '' then
		notify('Buffer must be saved first', vim.log.levels.ERROR)
		return
	end

	local dir = vim.fn.expand('%:p:h')
	local platform = get_platform()
	if not platform then
		notify('Unsupported platform (no display detected)', vim.log.levels.ERROR)
		return
	end

	local attachments_dir = M.attachment_dir(dir)
	local filename = 'paste-' .. os.date('%Y%m%d-%H%M%S') .. '.png'
	local outpath = vim.fs.joinpath(attachments_dir, filename)
	local write_cmd

	if platform == 'mac' then
		local check = vim.fn.system("osascript -e 'clipboard info'")
		if
			check:match('«class PNGf»')
			or check:match('TIFF')
			or check:match('public.png')
			or check:match('public.tiff')
		then
			write_cmd = string.format(
				[[osascript -e 'set png to (the clipboard as «class PNGf»)' -e 'set f to open for access POSIX file "%s" with write permission' -e 'write png to f' -e 'close access f']],
				outpath
			)
		else
			notify('No image in clipboard', vim.log.levels.WARN)
			return
		end
	elseif platform == 'x11' then
		if vim.fn.executable('xclip') ~= 1 then
			notify('xclip not found. Install with: sudo apt install xclip', vim.log.levels.ERROR)
			return
		end

		local check = vim.fn.system('xclip -selection clipboard -t TARGETS -o 2>/dev/null')
		if not check:match('image/png') then
			notify('No image in clipboard', vim.log.levels.WARN)
			return
		end

		write_cmd = string.format('xclip -selection clipboard -t image/png -o > %q', outpath)
	elseif platform == 'wayland' then
		if vim.fn.executable('wl-paste') ~= 1 then
			notify('wl-paste not found. Install with: sudo apt install wl-clipboard', vim.log.levels.ERROR)
			return
		end

		local check = vim.fn.system('wl-paste --list-types 2>/dev/null')
		if not check:match('image/png') then
			notify('No image in clipboard', vim.log.levels.WARN)
			return
		end

		write_cmd = string.format('wl-paste --type image/png > %q', outpath)
	end

	if not ensure_dir(attachments_dir) then
		notify('Failed to create attachments directory', vim.log.levels.ERROR)
		return
	end

	local result = vim.fn.system(write_cmd)
	if vim.v.shell_error ~= 0 then
		notify('Failed to write image: ' .. result, vim.log.levels.ERROR)
		return
	end

	if vim.fn.filereadable(outpath) ~= 1 then
		notify('Image file was not created', vim.log.levels.ERROR)
		return
	end

	vim.api.nvim_put({ M.attachment_link(filename) }, 'c', true, true)
	notify('Pasted image: ' .. filename, vim.log.levels.INFO)
end

return M
