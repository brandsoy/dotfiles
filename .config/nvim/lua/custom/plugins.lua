local plugins = {
  {
  "willamboman/mason.nvim",
opts = {
    ensure_installed = {
        "gopls",
      }
    }  },
}
return plugins
