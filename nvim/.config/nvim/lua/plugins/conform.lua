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
      lua = { 'stylua' },
      go = { 'gofumpt', 'golines' },
      svelte = { 'prettierd' },
      json = { 'prettierd' },
      jsonc = { 'prettierd' },
      html = { 'prettierd' },
      css = { 'prettierd' },
      scss = { 'prettierd' },
      yaml = { 'prettierd' },
      toml = { 'taplo' },
      sh = { 'shfmt' },
      bash = { 'shfmt' },
      markdown = { 'markdownlint-cli2' },

      -- Dynamic formatting for python
      python = function()
        local function file_exists(path)
          return vim.loop.fs_stat(path) ~= nil
        end

        local root = vim.fs.dirname(vim.fs.find({ 'pyproject.toml', 'ruff.toml' }, { upward = true })[1] or vim.api.nvim_buf_get_name(0))
        if root and file_exists(root .. '/pyproject.toml') then
          return { 'ruff' } -- primary formatter
        else
          return { 'black' } -- fallback
        end
      end,

      -- Dynamic formatting for js
      javascript = function()
        local function file_exists(path)
          return vim.loop.fs_stat(path) ~= nil
        end

        local root_files = {
          'biome.json',
          'biome.jsonc',
          '.eslintrc',
          '.eslintrc.js',
          '.prettierrc',
          '.prettierrc.js',
          '.prettierrc.json',
        }
        local root = vim.fs.dirname(vim.fs.find(root_files, { upward = true })[1] or vim.api.nvim_buf_get_name(0))
        if root then
          if file_exists(root .. '/biome.json') or file_exists(root .. '/biome.jsonc') then
            return { 'biome' }
          elseif file_exists(root .. '/.eslintrc') or file_exists(root .. '/.eslintrc.js') then
            return { 'eslint' }
          elseif file_exists(root .. '/.prettierrc') or file_exists(root .. '/.prettierrc.js') or file_exists(root .. '/.prettierrc.json') then
            return { 'prettier' }
          end
        end
        -- Fallback if nothing found
        return { 'prettier' }
      end,

      -- Dynamic formatting for ts
      typescript = function()
        local function file_exists(path)
          return vim.loop.fs_stat(path) ~= nil
        end

        local root_files = {
          'biome.json',
          'biome.jsonc',
          '.eslintrc',
          '.eslintrc.js',
          '.prettierrc',
          '.prettierrc.js',
          '.prettierrc.json',
        }
        local root = vim.fs.dirname(vim.fs.find(root_files, { upward = true })[1] or vim.api.nvim_buf_get_name(0))
        if root then
          if file_exists(root .. '/biome.json') or file_exists(root .. '/biome.jsonc') then
            return { 'biome' }
          elseif file_exists(root .. '/.eslintrc') or file_exists(root .. '/.eslintrc.js') then
            return { 'eslint' }
          elseif file_exists(root .. '/.prettierrc') or file_exists(root .. '/.prettierrc.js') or file_exists(root .. '/.prettierrc.json') then
            return { 'prettier' }
          end
        end
        -- Fallback if nothing found
        return { 'prettier' }
      end,

      -- Dynamic formatting for SQL
      sql = function()
        local root_file = vim.fs.find({ '.sqlfluff' }, { upward = true })[1]
        local root = root_file and vim.fs.dirname(root_file) or nil

        if root and vim.loop.fs_stat(root .. '/.sqlfluff') then
          return { 'sqlfluff' }
        end

        local file = vim.fn.expand '%:t'
        if file:match '%.psql%.sql$' then
          return { 'pg_format' }
        elseif file:match '%.mssql%.sql$' then
          return { 'sql-formatter' }
        end

        return { 'sql-formatter' }
      end,
    },

    -- Add formatter configuration
    formatters = {
      pg_format = {
        command = 'pg_format',
        args = { '-' }, -- Reads input from stdin
        stdin = true,
      },
      ruff = {
        command = 'ruff',
        args = { '--fix', '-' },
        stdin = true,
      },
      black = {
        command = 'black',
        args = { '-' },
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
        timeout_ms = 3000, -- Timeout for formatting in milliseconds
        lsp_fallback = true,
      }
    end,

    -- Configuration options for error handling
    notify_on_error = false,
  },
}
