return function()
  local ts = require("nvim-treesitter.configs")
  ts.setup({
    ensure_installed = { "lua", "go", "gomod", "gosum", "gotmpl", "json", "yaml", "bash", "vim", "vimdoc" },
    auto_install = true,
    highlight = { enable = true },
    indent = { enable = true },
    incremental_selection = { enable = true },
  })
end
