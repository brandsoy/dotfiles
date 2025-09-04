return function()
  -- Lua
  vim.lsp.config("lua_ls", {
    settings = {
      Lua = {
        runtime = { version = "LuaJIT" },
        diagnostics = { globals = { "vim", "require" } },
        workspace = { library = vim.api.nvim_get_runtime_file("", true) },
        telemetry = { enable = false },
      },
    },
  })

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

  -- TypeSpec
  vim.lsp.config("tsp_server", {
    root_dir = function()
      return vim.fs.root(0, { "tspconfig.yaml", "package.json", ".git" })
    end,
  })

  -- Optional: filetype detection for .tsp
  vim.filetype.add({
    extension = { tsp = "typespec" },
  })
end
