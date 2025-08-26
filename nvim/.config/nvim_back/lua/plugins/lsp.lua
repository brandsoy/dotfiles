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
        -- Shell
        'bash-language-server',
        'shfmt',
        'shellcheck',
        -- Lua tools
        'lua_ls',
        'stylua',
        -- Go tools
        'gopls',
        'gofumpt',
        'golines',
        'staticcheck',
        'golangci-lint',
        'golangci-lint-langserver',
        -- TS Tools
        'ts_ls',
        'svelte-language-server',
        'eslint-lsp',
        -- Python Tools
        'pyright', -- Modern Python LSP
        'ruff', -- Fast Python formatter/linter
        'black', -- Optional fallback formatter
        -- C#
        'csharp-language-server',
        -- 'omnisharp',
        -- SQL
        'sqls',
        -- Markdown
        'marksman',
        'markdownlint-cli2',
        -- YAML
        'yaml-language-server',
        'yamllint',
        -- JSON
        'json-lsp',
        -- Docker
        'dockerls',
        'hadolint',
        -- TOML
        'taplo',
        -- Tools
        'prettierd',
        'eslint_d',
        'editorconfig-checker',
        'codespell',
        -- SQL
        'pgformatter',
        'sql-formatter',
        'sqlfluff',
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
    lspconfig.sqls.setup {
      cmd = { 'sqls' },
      filetypes = { 'sql' },
      settings = {
        sqls = {
          connections = {}, -- empty = offline mode
        },
      },
    }
  end,
}
