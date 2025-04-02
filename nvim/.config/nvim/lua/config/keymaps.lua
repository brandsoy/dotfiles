-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("i", "jj", "<ESC>", { silent = true })
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

-- For Ctrl+D (half-page down)
vim.api.nvim_set_keymap("n", "<C-d>", "<C-d>zz", { noremap = true, silent = true })

-- For Ctrl+U (half-page up)
vim.api.nvim_set_keymap("n", "<C-u>", "<C-u>zz", { noremap = true, silent = true })
