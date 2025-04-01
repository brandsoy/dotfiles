-- Oil: Open parent dir in Oil
vim.keymap.set("n", "-", "<cmd>Oil --float<CR>", { desc = "Open Parent Directory in Oil" })

vim.keymap.set("n", "gl", function()
    vim.diagnostic.open_float()
end, { desc = "Open Diagnostics in Float" })

vim.keymap.set("n", "<leader>cf", function()
    require("conform").format({
        lsp_format = "fallback",
    })
end, { desc = "Format current file" })

vim.keymap.set("i", "jj", "<Esc>", { noremap = false, desc = "jj to escape" })
vim.keymap.set("i", "jk", "<Esc>", { noremap = false, desc = "jk to escape" })
