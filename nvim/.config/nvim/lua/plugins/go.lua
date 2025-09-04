return function()
  local has_go, go = pcall(require, "go")
  if not has_go then return end
  go.setup({
    lsp_cfg = false,
    lsp_gofumpt = true,
    lsp_inlay_hints = { enable = true },
    dap_debug = true,
    dap_debug_gui = {},
  })

  -- Format on save using goimports via go.nvim
  local grp = vim.api.nvim_create_augroup("GoFormat", { clear = true })
  vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*.go",
    callback = function()
      pcall(function() require("go.format").goimports() end)
    end,
    group = grp,
  })

  -- Go convenience keymaps (buffer local via FileType)
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "go" },
    callback = function(ev)
      local opts = { buffer = ev.buf, silent = true, noremap = true }
      local keymap = vim.keymap.set
      keymap("n", "<leader>gb", ":GoBuild<CR>", vim.tbl_extend("force", opts, { desc = "Go: Build" }))
      keymap("n", "<leader>gr", ":GoRun<CR>", vim.tbl_extend("force", opts, { desc = "Go: Run" }))
      keymap("n", "<leader>gt", ":GoTest<CR>", vim.tbl_extend("force", opts, { desc = "Go: Test All" }))
      keymap("n", "<leader>gT", ":GoTestFile<CR>", vim.tbl_extend("force", opts, { desc = "Go: Test File" }))
      keymap("n", "<leader>gn", ":GoTestFunc<CR>", vim.tbl_extend("force", opts, { desc = "Go: Test Nearest" }))
      keymap("n", "<leader>gi", ":GoImports<CR>", vim.tbl_extend("force", opts, { desc = "Go: Organize Imports" }))
      keymap("n", "<leader>gf", function() require("go.format").goimports() end, vim.tbl_extend("force", opts, { desc = "Go: Format (imports)" }))
      keymap("n", "<leader>ga", ":GoAddTag json<CR>", vim.tbl_extend("force", opts, { desc = "Go: Add json tags" }))
      keymap("n", "<leader>gA", ":GoRmTag json<CR>", vim.tbl_extend("force", opts, { desc = "Go: Remove json tags" }))
      keymap("n", "<leader>gc", function() require("go.comment").gen() end, vim.tbl_extend("force", opts, { desc = "Go: Generate comment" }))
      keymap("n", "<leader>gs", ":GoFillStruct<CR>", vim.tbl_extend("force", opts, { desc = "Go: Fill struct" }))
      keymap("n", "<leader>gS", ":GoIfErr<CR>", vim.tbl_extend("force", opts, { desc = "Go: Add if err" }))
      keymap("n", "<leader>go", ":GoAlt<CR>", vim.tbl_extend("force", opts, { desc = "Go: Toggle test/source" }))
    end,
  })
end
