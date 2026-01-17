-- TITLE: NeoVim keymaps
-- ABOUT: sets some quality-of-life keymaps
-- ================================================================================================

local function map(mode, lhs, rhs, desc, opts)
	local options = { silent = true, desc = desc }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	vim.keymap.set(mode, lhs, rhs, options)
end

local function notify_option(label, enabled)
	local ok = vim.notify ~= nil
	if not ok then
		return
	end
	vim.notify(
		string.format("%s %s", label, enabled and "enabled" or "disabled"),
		vim.log.levels.INFO,
		{ title = "Neovim" }
	)
end

------------------------------------------------------------------------------
--- Normal Mode
------------------------------------------------------------------------------

-- Disable Space bar since it'll be used as the leader key
map("n", "<leader>", "<nop>", "Disable bare leader key")

-- Center screen when jumping
map("n", "n", "nzzzv", "Next search result (centered)")
map("n", "N", "Nzzzv", "Previous search result (centered)")
map("n", "<C-d>", "<C-d>zz", "Half page down (centered)")
map("n", "<C-u>", "<C-u>zz", "Half page up (centered)")

-- Quick buffer switch
map("n", "<leader><leader>", "<Cmd>b#<CR>", "Switch to last buffer")

-- Clear search highlight
map("n", "<leader>h", "<Cmd>nohlsearch<CR>", "Clear search highlight")

-- Buffer navigation
map("n", "<leader>bn", "<Cmd>bnext<CR>", "Next buffer")
map("n", "<leader>bp", "<Cmd>bprevious<CR>", "Previous buffer")
map("n", "<leader>br", "<Cmd>edit!<CR>", "Revert buffer from disk")

-- Better window navigation
map("n", "<C-h>", "<C-w>h", "Move to left window")
map("n", "<C-j>", "<C-w>j", "Move to bottom window")
map("n", "<C-k>", "<C-w>k", "Move to top window")
map("n", "<C-l>", "<C-w>l", "Move to right window")

-- Splitting & Resizing
map("n", "<leader>sv", "<Cmd>vsplit<CR>", "Split window vertically")
map("n", "<leader>sh", "<Cmd>split<CR>", "Split window horizontally")
map("n", "<leader>sx", "<Cmd>close<CR>", "Close current window")
map("n", "<leader>se", "<C-w>=", "Equalize window sizes")
map("n", "<C-Up>", "<Cmd>resize +2<CR>", "Increase window height")
map("n", "<C-Down>", "<Cmd>resize -2<CR>", "Decrease window height")
map("n", "<C-Left>", "<Cmd>vertical resize -2<CR>", "Decrease window width")
map("n", "<C-Right>", "<Cmd>vertical resize +2<CR>", "Increase window width")

-- Better J behavior
map("n", "J", "mzJ`z", "Join lines and keep cursor position")

-- Quick config editing
map("n", "<leader>rc", "<Cmd>e ~/.config/nvim/init.lua<CR>", "Edit Neovim config")

-- Saving and quitting
map("n", "<leader>ww", "<Cmd>write<CR>", "Save current buffer")
map("n", "<leader>wa", "<Cmd>wall<CR>", "Save all buffers")
map("n", "<leader>wq", "<Cmd>wq<CR>", "Save and quit window")
map("n", "<leader>qq", "<Cmd>confirm qall<CR>", "Quit Neovim")
map("n", "<leader>qQ", "<Cmd>qall!<CR>", "Force quit Neovim")

-- Clipboard helpers
map({ "n", "v" }, "<leader>y", '"+y', "Yank to system clipboard")
map("n", "<leader>Y", '"+Y', "Yank line to system clipboard")
map({ "n", "v" }, "<leader>p", '"+p', "Paste from system clipboard")

-- Option toggles
map("n", "<leader>un", function()
	vim.wo.relativenumber = not vim.wo.relativenumber
	notify_option("Relative number", vim.wo.relativenumber)
end, "Toggle relative line numbers")

map("n", "<leader>uc", function()
	vim.wo.cursorline = not vim.wo.cursorline
	notify_option("Cursor line", vim.wo.cursorline)
end, "Toggle cursor line")

map("n", "<leader>uw", function()
	vim.wo.wrap = not vim.wo.wrap
	notify_option("Line wrap", vim.wo.wrap)
end, "Toggle soft wrap")

map("n", "<leader>us", function()
	vim.wo.spell = not vim.wo.spell
	notify_option("Spell check", vim.wo.spell)
end, "Toggle spell checking")

-- Ensure splits open where you like (optional)
vim.opt.splitright = true -- vertical splits open to the right
vim.opt.splitbelow = true -- horizontal splits open below

-- LSP: go to definition in a vertical split (keep normal `gd` unchanged)
map({ "n" }, "<leader>gd", function()
	vim.cmd("vsplit")
	vim.lsp.buf.definition()
end, "LSP: go to definition in vertical split")

-- LSP: go to definition in a horizontal split (optional)
map({ "n" }, "<leader>gdh", function()
	vim.cmd("split")
	vim.lsp.buf.definition()
end, "LSP: go to definition in horizontal split")

-- Native motion: run exact `gd` in a new split (if you prefer Vim’s native behavior)
map({ "n" }, "<leader>gD", function()
	vim.cmd("vsplit")
	vim.cmd("normal! gd")
end, "Native gd in vertical split")

map({ "n" }, "<leader>gDh", function()
	vim.cmd("split")
	vim.cmd("normal! gd")
end, "Native gd in horizontal split")

-- File under cursor (`gf`) in a vertical split
map("n", "gx", function()
	-- 1. Grab the full WORD (includes !, [, and ])
	local file = vim.fn.expand("<cWORD>")

	-- 2. Clean the string: Remove ![[ from start and ]] from end
	-- The % is an escape character for special symbols in Lua patterns
	file = file:gsub("^%!%[%[", ""):gsub("^%[%[", ""):gsub("%]%]$", "")

	-- Strip common Markdown link characters if present
	file = file:gsub("^%(", ""):gsub("%)$", "")

	-- 3. Define potential locations
	local current_dir = vim.fn.expand("%:p:h")
	local locations = {
		vim.fn.fnamemodify(file, ":p"), -- Absolute path
		current_dir .. "/" .. file, -- Same folder as note
		current_dir .. "/attachments/" .. file, -- 'attachments' subfolder
		current_dir .. "/assets/" .. file, -- 'assets' subfolder
	}

	-- 4. Try to find the file
	local found_path = nil
	for _, path in ipairs(locations) do
		if vim.fn.filereadable(path) == 1 then
			found_path = path
			break
		end
	end

	-- 5. Execute Open
	if found_path then
		if found_path:match("%.pdf$") then
			-- Force Preview for PDFs
			vim.fn.jobstart({ "open", "-a", "Preview", found_path }, { detach = true })
		else
			-- System default for everything else
			vim.ui.open(found_path)
		end
	elseif file:match("^https?://") then
		vim.ui.open(file)
	else
		print("File not found in current dir or attachments: " .. file)
	end
end, "Open embedded PDF or Wiki-link")

--------------------------------------------------------------------------
--- Visual Mode
--------------------------------------------------------------------------
-- Disable Space bar since it'll be used as the leader key
map("v", "<leader>", "<nop>", "Disable bare leader key")

-- Better indenting in visual mode
map("v", "<", "<gv", "Indent left and reselect")
map("v", ">", ">gv", "Indent right and reselect")

map("v", "<leader>mw", function()
	local s = vim.fn.getreg("v") -- selected text
	vim.cmd([[normal! gv]]) -- reselect
	vim.cmd([[normal! c[]()]]) -- replace with []
	vim.api.nvim_put({ s }, "c", true, true) -- put selection inside []
	vim.cmd([[normal! F[a]]) -- move cursor into ()
end, "Wrap selection in markdown link")

-- Insert a markdown todo checkbox
map("n", "<leader>mt", "0i- [ ] <Esc>", "Insert markdown todo")
map("v", "<leader>mt", ":s/^/- [ ] /<CR>:noh<CR>", "Make lines markdown todos")
map("n", "<leader>mx", function()
	local line = vim.api.nvim_get_current_line()
	if line:match("%[ %]") then
		line = line:gsub("%[ %]", "[x]", 1)
	elseif line:match("%[x%]") then
		line = line:gsub("%[x%]", "[ ]", 1)
	end
	vim.api.nvim_set_current_line(line)
end, "Toggle markdown todo checkbox")
-- Insert hyperlinks
map("n", "<leader>ml", "i[]()<Esc>F[a", "Insert markdown link")
map("n", "<leader>mL", "i[]()<Esc>F(a<C-r>+<Esc>F[a", "Insert buffered markdown link")

--------------------------------------------------------------------------
--- Interactive Mode
--------------------------------------------------------------------------

-- JK Escape
map("i", "jk", [[<C-\><C-n>]], "Exit insert mode")

------------------------------------------------------------------------------
--- Terminal Mode
------------------------------------------------------------------------------

map("t", "<Esc>", [[<C-\><C-n>]], "Exit terminal mode")
map("t", "<C-h>", [[<C-\><C-n><C-w>h]], "Terminal: move to left window")
map("t", "<C-j>", [[<C-\><C-n><C-w>j]], "Terminal: move to bottom window")
map("t", "<C-k>", [[<C-\><C-n><C-w>k]], "Terminal: move to top window")
map("t", "<C-l>", [[<C-\><C-n><C-w>l]], "Terminal: move to right window")
