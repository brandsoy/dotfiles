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

      formatters_by_ft = {
        javascript = function(bufnr)
          local utils = require 'conform.util'
          local root = utils.root_pattern('biome.json', 'biome.jsonc', '.eslintrc', '.eslintrc.js', '.prettierrc', '.prettierrc.js', '.prettierrc.json')(bufnr)
          if root then
            if utils.file_exists(root .. '/biome.json') or utils.file_exists(root .. '/biome.jsonc') then
              return { 'biome' }
            elseif utils.file_exists(root .. '/.eslintrc') or utils.file_exists(root .. '/.eslintrc.js') then
              return { 'eslint' }
            elseif
              utils.file_exists(root .. '/.prettierrc')
              or utils.file_exists(root .. '/.prettierrc.js')
              or utils.file_exists(root .. '/.prettierrc.json')
            then
              return { 'prettier' }
            end
          end
          -- Fallback if nothing found
          return { 'prettier' }
        end,
        typescript = function(bufnr)
          -- Repeat the same logic for typescript
          local utils = require 'conform.util'
          local root = utils.root_pattern('biome.json', 'biome.jsonc', '.eslintrc', '.eslintrc.js', '.prettierrc', '.prettierrc.js', '.prettierrc.json')(bufnr)
          if root then
            if utils.file_exists(root .. '/biome.json') or utils.file_exists(root .. '/biome.jsonc') then
              return { 'biome' }
            elseif utils.file_exists(root .. '/.eslintrc') or utils.file_exists(root .. '/.eslintrc.js') then
              return { 'eslint' }
            elseif
              utils.file_exists(root .. '/.prettierrc')
              or utils.file_exists(root .. '/.prettierrc.js')
              or utils.file_exists(root .. '/.prettierrc.json')
            then
              return { 'prettier' }
            end
          end
          return { 'prettier' }
        end,
        -- Repeat for other filetypes if needed
      },

      -- Javascript/Typescript ecosystem
      -- javascript = { 'prettierd', 'prettier' },
      -- typescript = { 'prettierd', 'prettier' },
      -- javascriptreact = { 'prettierd', 'prettier' },
      -- typescriptreact = { 'prettierd', 'prettier' },
      json = { 'prettierd' },
      jsonc = { 'prettierd' },
      html = { 'prettierd' },
      css = { 'prettierd' },
      scss = { 'prettierd' },
      yaml = { 'prettierd' },
      -- Python
      -- python = { 'isort', 'black' },
      -- Others
      markdown = { 'markdownlint-cli2' },
      toml = { 'taplo' },
      -- Add SQL formatter
      sql = { 'pg_format' },
    },

    -- Add formatter configuration
    formatters = {
      pg_format = {
        command = 'pg_format',
        args = { '-' }, -- Reads input from stdin
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
