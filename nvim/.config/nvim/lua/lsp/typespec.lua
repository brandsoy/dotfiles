return function()
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
