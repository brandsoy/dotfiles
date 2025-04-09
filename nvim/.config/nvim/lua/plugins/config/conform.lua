-- Configuration options for formatting and error notifications
local options = {
  -- Disable notifications for errors
  notify_on_error = false,

  -- Function to handle "format on save" behavior
  format_on_save = function(bufnr)
    -- Define filetypes for which format on save should be disabled
    local disable_filetypes = { c = true, cpp = true }

    -- Check if the current buffer's filetype is in the disabled list
    if disable_filetypes[vim.bo[bufnr].filetype] then
      return nil
    end

    -- Return formatting options for enabled filetypes
    return {
      timeout_ms = 500, -- Timeout for formatting in milliseconds
      lsp_format = 'fallback', -- Use LSP fallback for formatting
    }
  end,

  -- Define formatters for specific filetypes
  formatters_by_ft = {
    -- Use gofumpt for Go files
    go = { 'gofumpt' },
    javascript = { 'eslint_d' },
    typescript = { 'eslint_d' },
    javascriptreact = { 'eslint_d' },
    typescriptreact = { 'eslint_d' },
    json = { 'prettierd' },
    html = { 'prettierd' },
    yaml = { 'prettierd' },
    css = { 'prettierd' },
    python = { 'isort', 'black' },
    -- Use Stylua for Lua files
    lua = { 'stylua' },

    -- Use Taplo for TOML files
    toml = { 'taplo' },

    -- Use CSharpier for C# files
    cs = { 'csharpier' },

    -- Use sql-formatter for SQL files with PostgreSQL language
    sql = {
      cmd = 'sql-formatter',
      args = { '--language', 'postgresql' },
      stop_after_first = true, -- Ensure only the first formatter is applied
    },
  },
}

return options
