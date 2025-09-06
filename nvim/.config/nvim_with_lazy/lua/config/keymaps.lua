-- ================================================================================================
-- TITLE: NeoVim keymaps
-- ABOUT: sets some quality-of-life keymaps
-- ================================================================================================

------------------------------------------------------------------------------
--- Normal Mode
------------------------------------------------------------------------------

-- Disable Space bar since it'll be used as the leader key
vim.keymap.set("n", "<leader>", "<nop>")

-- Center screen when jumping
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })

-- Buffer navigation
vim.keymap.set("n", "<leader>bn", "<Cmd>bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bp", "<Cmd>bprevious<CR>", { desc = "Previous buffer" })

-- Better window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Splitting & Resizing
vim.keymap.set("n", "<leader>sv", "<Cmd>vsplit<CR>", { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>sh", "<Cmd>split<CR>", { desc = "Split window horizontally" })
vim.keymap.set("n", "<C-Up>", "<Cmd>resize +2<CR>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", "<Cmd>resize -2<CR>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>", "<Cmd>vertical resize -2<CR>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", "<Cmd>vertical resize +2<CR>", { desc = "Increase window width" })

-- Better J behavior
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines and keep cursor position" })

-- Quick config editing
vim.keymap.set("n", "<leader>rc", "<Cmd>e ~/.config/nvim/init.lua<CR>", { desc = "Edit config" })

-- Markdown
-- Insert hyperlinks
vim.keymap.set("n", "<leader>ml", "i[]()<Esc>F[a", { desc = "Insert markdown link" })
vim.keymap.set("n", "<leader>mL", "i[]()<Esc>F(a<C-r>+<Esc>F[a", { desc = "Insert buffered markdown link" })

--------------------------------------------------------------------------
--- Visual Mode
--------------------------------------------------------------------------
-- Disable Space bar since it'll be used as the leader key
vim.keymap.set("v", "<leader>", "<nop>")

-- Better indenting in visual mode
vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })

vim.keymap.set("v", "<leader>l", function()
	local s = vim.fn.getreg("v") -- selected text
	vim.cmd([[normal! gv]]) -- reselect
	vim.cmd([[normal! c[]()]]) -- replace with []
	vim.api.nvim_put({ s }, "c", true, true) -- put selection inside []
	vim.cmd([[normal! F[a]]) -- move cursor into ()
end, { desc = "Wrap selection in markdown link" })

-- Insert a markdown to-do checkbox
vim.keymap.set("n", "<leader>mt", "0i- [ ] <Esc>", { desc = "Insert markdown todo" })
vim.keymap.set("v", "<leader>mt", ":s/^/- [ ] /<CR>:noh<CR>", { desc = "Make lines markdown todos" })
vim.keymap.set("n", "<leader>mx", function()
	local line = vim.api.nvim_get_current_line()
	if line:match("%[ %]") then
		line = line:gsub("%[ %]", "[x]", 1)
	elseif line:match("%[x%]") then
		line = line:gsub("%[x%]", "[ ]", 1)
	end
	vim.api.nvim_set_current_line(line)
end, { desc = "Toggle markdown todo checkbox" })


--------------------------------------------------------------------------
--- Interactive Mode
--------------------------------------------------------------------------

-- JK Escape
vim.keymap.set("i", "jk", [[<C-\><C-n>]])
