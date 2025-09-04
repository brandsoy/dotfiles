return function()
  local ts = require("nvim-treesitter.configs")
  ts.setup({
    ensure_installed = {
      "bash",
      "css",
      "dockerfile",
      "go",
      "gomod",
      "gosum",
      "gotmpl",
      "html",
      "javascript",
      "json",
      "lua",
      "markdown",
      "markdown_inline",
      "python",
      "svelte",
      "typescript",
      "vue",
      "yaml",
      "vim",
      "vimdoc"
    },
    sync_install = true,
    auto_install = true,
    ignore_install = {},
    modules = {},
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
    },
    indent = { enable = true },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<CR>",
        node_incremental = "<CR>",
        scope_incremental = "<TAB>",
        node_decremental = "<S-TAB>",
      },
    },
  })
end
