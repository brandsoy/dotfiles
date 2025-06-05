-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Diagnostic keymaps
vim.keymap.set("n", "<leader>dq", vim.diagnostic.setloclist, { desc = "[D]iagnostic: Open [Q]uickfix list" })
vim.keymap.set("n", "gl", function()
  vim.diagnostic.open_float()
end, { desc = "[G]o to [L]ine Diagnostics in Float" })

-- Exit terminal mode
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Disable arrow keys in normal mode
vim.keymap.set("n", "<left>", '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set("n", "<right>", '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set("n", "<up>", '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set("n", "<down>", '<cmd>echo "Use j to move!!"<CR>')

-- window splits
vim.keymap.set("n", "<leader>sv", "<C-w>v", { desc = "[S]plit: [V]ertical" })
vim.keymap.set("n", "<leader>sh", "<C-w>s", { desc = "[S]plit: [H]orizontal" })
vim.keymap.set("n", "<leader>se", "<C-w>=", { desc = "[S]plit: [E]qual size" })
vim.keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "[S]plit: [X] Close current" })

-- Tab management
vim.keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "[T]ab: [O]pen new" })
vim.keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "[T]ab: [X] Close current" })
vim.keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "[T]ab: [N]ext" })
vim.keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "[T]ab: [P]revious" })
vim.keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "[T]ab: Open current buffer in new tab" })

-- Window navigation
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- Personal keymaps
vim.keymap.set("i", "jk", "<ESC>", { silent = true, desc = "Exit insert mode" })

-- Spell check toggles
vim.keymap.set("n", "<leader>cn", function()
  vim.opt.spelllang = "nb"
  vim.notify("Spell check: Norwegian Bokmål")
end, { desc = "[C]ode: [N]orwegian spell check" })

vim.keymap.set("n", "<leader>ce", function()
  vim.opt.spelllang = "en"
  vim.notify("Spell check: English")
end, { desc = "[C]ode: [E]nglish spell check" })

-- Center line on page up and down
vim.keymap.set("n", "<C-d>", "<C-d>zz", { noremap = true, silent = true, desc = "Page down and center" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { noremap = true, silent = true, desc = "Page up and center" })

-- File explorer
vim.keymap.set("n", "-", "<cmd>Oil --float<CR>", { desc = "Open Parent Directory in Oil" })

-- Markdown checkbox toggle
local checkbox = require("user.checkbox")
vim.keymap.set("n", "<leader>tt", checkbox.toggle, { desc = "[T]oggle: Markdown checkbox" })

-- Visual mode text movement
local opts = { noremap = true, silent = true }
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move text down", unpack(opts) })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move text up", unpack(opts) })

-- Copy block between braces
vim.keymap.set("n", "YY", "va{Vy", { desc = "Copy everything between {}", unpack(opts) })

-- Go test toggle (if you have this utility)
vim.keymap.set("n", "<C-P>", ':lua require("config.utils").toggle_go_test()<CR>', { desc = "Toggle Go test", unpack(opts) })
