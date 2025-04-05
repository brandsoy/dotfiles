local options = {
  notify_on_error = true,

  formatters_by_ft = {
    go = { 'gofumpt, goimports-reviser' },
    javascript = { 'prettierd', 'prettier', stop_after_first = true },
    typescript = { 'prettierd', 'prettier', stop_after_first = true },
    javascriptreact = { 'prettierd', 'prettier', stop_after_first = true },
    typescriptreact = { 'prettierd', 'prettier', stop_after_first = true },
    json = { 'prettier', 'prettierd', stop_after_first = true },
    html = { 'prettier', 'prettierd', stop_after_first = true },
    yaml = { 'prettier', 'prettierd', stop_after_first = true },
    css = { 'prettierd', 'prettierd', stop_after_first = true },
    lua = { 'stylua' },
    toml = { 'taplo' },
    cs = { 'csharpier' },
    sql = { 'sql_formatter' },
  },

  formatters = {
    sql_formatter = {
      command = 'sql_formatter',
      stdin = true,
      args = {
        '-c',
        '{ "expressionWidth": 81, "tabWidth": 2, "keywordCase": "upper", "language": "postgresql" }',
      },
    },
  },
}

return options
