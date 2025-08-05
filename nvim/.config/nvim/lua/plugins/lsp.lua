return {
  'neovim/nvim-lspconfig',
  dependencies = {
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
  },
  config = function()
    -- Setup Mason tools
    require('mason').setup()
    require('mason-lspconfig').setup()
    require('mason-tool-installer').setup {
      ensure_installed = {
        -- Lua tools
        'lua_ls',
        'stylua',
        -- Go tools
        'gopls',
        'gofumpt',
        'golines',
        'golangci-lint',
        -- TS Tools
        'ts_ls',
        -- Tools
        'prettierd',
        'eslint_d',
      },
    }

    -- Setup LSP server for Lua
    local lspconfig = require 'lspconfig'
    lspconfig.lua_ls.setup {
      settings = {
        Lua = {
          runtime = {
            version = 'LuaJIT',
          },
          diagnostics = {
            globals = { 'vim' },
          },
          workspace = {
            library = vim.api.nvim_get_runtime_file('', true),
            checkThirdParty = false,
          },
          telemetry = {
            enable = false,
          },
        },
      },
    }

    -- You can configure more servers here as needed
  end,
}
