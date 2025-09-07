return function()
  -- Go (gopls)
  vim.lsp.config("gopls", {
    root_dir = function()
      local fname = vim.api.nvim_buf_get_name(0)
      local find = vim.fs.find({ "go.work", "go.mod", ".git" }, { upward = true, path = vim.fs.dirname(fname) })
      return #find > 0 and vim.fs.dirname(find[1]) or vim.loop.cwd()
    end,
    settings = {
      gopls = {
        analyses = {
          unusedparams = true,
          nilness = true,
          unusedwrite = true,
          useany = true,
          shadow = true,
        },
        codelenses = {
          generate = true,
          gc_details = true,
          test = true,
          tidy = true,
          vendor = true,
          regenerate_cgo = true,
          upgrade_dependency = true,
        },
        hints = {
          assignVariableTypes = true,
          compositeLiteralFields = true,
          compositeLiteralTypes = true,
          constantValues = true,
          functionTypeParameters = true,
          parameterNames = true,
          rangeVariableTypes = true,
        },
        usePlaceholders = true,
        completeUnimported = true,
        staticcheck = true,
        matcher = "Fuzzy",
        directoryFilters = { "-node_modules" },
        gofumpt = true,
      },
    },
  })
  vim.lsp.enable("gopls")
end
