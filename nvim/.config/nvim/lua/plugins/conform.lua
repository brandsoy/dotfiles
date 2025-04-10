return { -- Autoformat
  'stevearc/conform.nvim',
  event = { 'BufWritePre', 'BufNewFile' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>cf',
      function()
        require('conform').format { async = true, lsp_fallback = true }
      end,
      mode = '',
      desc = '[C]ode [F]ormat buffer',
    },
  },
  opts = {
    -- Define formatters for specific filetypes
    formatters_by_ft = {
      -- Use gofumpt for Go files
      go = { 'gofumpt' },
      lua = { 'stylua' },
      -- Javascript/Typescript ecosystem
      javascript = { 'prettierd', 'prettier' },
      typescript = { 'prettierd', 'prettier' },
      javascriptreact = { 'prettierd', 'prettier' },
      typescriptreact = { 'prettierd', 'prettier' },
      json = { 'prettierd' },
      jsonc = { 'prettierd' },
      html = { 'prettierd' },
      css = { 'prettierd' },
      scss = { 'prettierd' },
      yaml = { 'prettierd' },
      -- Python
      python = { 'isort', 'black' },
      -- Others
      markdown = { 'markdownlint' },
      toml = { 'taplo' },
      -- Add SQL formatter
      sql = { 'sqlfluff' },
    },

    -- Add formatter configuration
    formatters = {
      sqlfluff = {
        -- Add SQL dialect configuration
        args = { 'fix', '--dialect', 'postgres', '--disable-progress-bar', '-' },
        -- Specify stdin for input
        stdin = true,
      },
    },

    -- Function to handle "format on save" behavior
    format_on_save = function(bufnr)
      -- Define filetypes for which format on save should be disabled
      local disable_filetypes = { c = true, cpp = true }

      -- Check if the current buffer's filetype is in the disabled list
      if disable_filetypes[vim.bo[bufnr].filetype] then
        return
      end

      -- Return formatting options for enabled filetypes
      return {
        timeout_ms = 500, -- Timeout for formatting in milliseconds
        lsp_fallback = true,
      }
    end,

    -- Configuration options for error handling
    notify_on_error = false,
  },
}
