return {
  -- Main LSP Configuration
  'neovim/nvim-lspconfig',
  dependencies = {
    -- Automatically install LSPs and related tools to stdpath for Neovim
    -- Mason must be loaded before its dependents so we need to set it up here.
    {
      'williamboman/mason.nvim',
      opts = {
        -- You can add Mason UI or other Mason settings here if desired, e.g.:
        ui = {
          border = 'rounded',
          icons = {
            package_installed = '✓',
            package_pending = '➜',
            package_uninstalled = '✗',
          },
        },
      },
    },
    'williamboman/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',

    -- Useful status updates for LSP.
    { 'j-hui/fidget.nvim', opts = {} },
  },
  config = function()
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
      callback = function(event)
        local map = function(keys, func, desc, mode)
          mode = mode or 'n'
          vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        map('gd', require('fzf-lua').lsp_definitions, '[G]oto [D]efinition')
        map('gr', require('fzf-lua').lsp_references, '[G]oto [R]eferences')
        map('gI', require('fzf-lua').lsp_implementations, '[G]oto [I]mplementation')
        map('<leader>D', require('fzf-lua').lsp_typedefs, 'Type [D]efinition')
        map('<leader>ds', require('fzf-lua').lsp_document_symbols, '[D]ocument [S]ymbols')
        map('<leader>ws', require('fzf-lua').lsp_live_workspace_symbols, '[W]orkspace [S]ymbols')
        map('<leader>cr', vim.lsp.buf.rename, '[R]e[n]ame')
        map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })
        map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

        local function client_supports_method(client, method, bufnr)
          if vim.fn.has 'nvim-0.11' == 1 then
            return client:supports_method(method, bufnr)
          else
            return client.supports_method(method, { bufnr = bufnr })
          end
        end

        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
          local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })
          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })
          vim.api.nvim_create_autocmd('LspDetach', {
            group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
            end,
          })
        end

        if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
          map('<leader>th', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
          end, '[T]oggle Inlay [H]ints')
        end
      end,
    })

    vim.diagnostic.config {
      severity_sort = true,
      float = { border = 'rounded', source = 'if_many' },
      underline = { severity = vim.diagnostic.severity.ERROR },
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = '󰅚 ',
          [vim.diagnostic.severity.WARN] = '󰀪 ',
          [vim.diagnostic.severity.INFO] = '󰋽 ',
          [vim.diagnostic.severity.HINT] = '󰌶 ',
        },
      },
      virtual_text = {
        source = 'if_many',
        spacing = 2,
        format = function(diagnostic)
          local diagnostic_message = {
            [vim.diagnostic.severity.ERROR] = diagnostic.message,
            [vim.diagnostic.severity.WARN] = diagnostic.message,
            [vim.diagnostic.severity.INFO] = diagnostic.message,
            [vim.diagnostic.severity.HINT] = diagnostic.message,
          }
          return diagnostic_message[diagnostic.severity]
        end,
      },
    }

    local original_capabilities = vim.lsp.protocol.make_client_capabilities()
    local capabilities = require('blink.cmp').get_lsp_capabilities(original_capabilities)
    -- capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

    local servers = {
      -- bashls = {},
      marksman = {},
      gopls = {
        analyses = {
          unusedparams = true,
        },
        staticcheck = true,
        usePlaceholders = true,
        completeUnimported = true, -- This enables auto-import
        gofumpt = true,
      },
      pyright = {},
      vtsls = {},
      -- html = {},
      -- tailwindcss = {},
      taplo = {}, -- TOML LSP
      lua_ls = {
        -- Example settings for lua_ls, uncomment and customize as needed
        -- settings = {
        --   Lua = {
        --     workspace = { checkThirdParty = false },
        --     telemetry = { enable = false },
        --     completion = { callSnippet = 'Replace' },
        --     -- diagnostics = { disable = { 'missing-fields' } },
        --   },
        -- },
      },
    }

    -- Configure mason-lspconfig to handle LSP server installations and setup
    require('mason-lspconfig').setup {
      -- A list of LSP servers to ensure are installed.
      -- These are drawn from the keys of the 'servers' table defined above.
      ensure_installed = vim.tbl_keys(servers),
      -- Whether servers that are set up (via lspconfig) should be automatically installed if they are not already.
      -- This relies on the `ensure_installed` list primarily.
      automatic_installation = true, -- Set to false if you want to manually install via :Mason
      automatic_enable = true,
      handlers = {
        -- Default handler: Sets up servers with their configurations from the 'servers' table
        function(server_name)
          local server_config = servers[server_name] or {}
          -- Apply global capabilities, allowing server-specific ones to override
          server_config.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server_config.capabilities or {})
          require('lspconfig')[server_name].setup(server_config)
        end,
        -- You can add custom handlers for specific LSPs here if needed, for example:
        -- ['lua_ls'] = function()
        --   local lua_ls_opts = vim.tbl_deep_extend('force', {
        --     capabilities = capabilities,
        --   }, servers.lua_ls or {})
        --   require('lspconfig').lua_ls.setup(lua_ls_opts)
        -- end,
      },
    }

    -- Define other tools (linters, formatters, etc.) for mason-tool-installer
    -- These are tools that are not LSP servers or are handled separately.
    local other_tools_to_install = {
      'stylua', -- Lua formatter
      'prettierd', -- Prettier daemon (for various filetypes)
      'ruff', -- Python linter & formatter
      'pylint', -- Python linter
      'eslint_d', -- ESLint daemon (JavaScript/TypeScript linter)
      'yamllint', -- YAML linter
      -- 'jsonlint', -- JSON linter (often provided by other tools like prettier)
      'markdownlint', -- Markdown linter
      'golangci-lint', -- Go linter
      'sqlfluff', -- SQL linter & formatter
      -- 'taplo' is managed by mason-lspconfig as it's in the `servers` list.
      -- If you had a separate taplo CLI tool package from Mason, you could list it here.
      -- Usually, the 'taplo' package provides both.
    }

    -- Ensure the non-LSP tools are installed by mason-tool-installer
    require('mason-tool-installer').setup {
      ensure_installed = other_tools_to_install,
      -- You can add other mason-tool-installer options here if needed
      -- auto_update = false,
      -- run_on_start = true,
    }
  end,
}
