local options = {
  notify_on_error = false,
  format_on_save = function(bufnr)
    -- Disable "format_on_save lsp_fallback" for languages that don't
    -- have a well standardized coding style. You can add additional
    -- languages here or re-enable it for the disabled ones.
    local disable_filetypes = { c = true, cpp = true }
    if disable_filetypes[vim.bo[bufnr].filetype] then
      return nil
    else
      return {
        timeout_ms = 500,
        lsp_format = 'fallback',
      }
    end
  end,

  formatters_by_ft = {
    go = { 'gofumpt, goimports-reviser' },
    javascript = { 'biome' },
    typescript = { 'biome' },
    javascriptreact = { 'biome' },
    typescriptreact = { 'biome' },
    json = { 'biome' },
    html = { 'biome' },
    yaml = { 'biome' },
    css = { 'biome' },
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
