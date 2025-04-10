return {
  'williamboman/mason.nvim',
  dependencies = {
    'williamboman/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
  },
  config = function()
    local mason = require 'mason'
    local mason_lspconfig = require 'mason-lspconfig'
    local mason_tool_installer = require 'mason-tool-installer'

    -- Mason setup
    mason.setup {
      ui = {
        icons = {
          package_installed = '✓',
          package_pending = '➜',
          package_uninstalled = '✗',
        },
      },
    }

    -- Mason LSP configuration
    mason_lspconfig.setup {
      ensure_installed = {
        'vtsls',
        'html',
        'cssls',
        'tailwindcss',
        'lua_ls',
        'pyright',
        'gopls',
      },
    }

    -- Mason tool installer
    mason_tool_installer.setup {
      ensure_installed = {
        'prettierd',
        'prettier',
        'stylua',
        'isort',
        'black',
        'pylint',
        'biome',
        'eslint_d', -- Ensure eslint_d is installed
        'yamllint',
        'jsonlint',
        'markdownlint',
        'golangci-lint',
        'sqlfluff',
        'pgformatter',
      },
    }
  end,
}
