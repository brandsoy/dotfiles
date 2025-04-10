return {
  -- Main LSP Configuration
  'neovim/nvim-lspconfig',
  -- event = { 'BufReadPre', 'BufNewFile' },
  dependencies = {
    -- Mason for LSP server management
    { 'williamboman/mason.nvim', opts = {} },
    'williamboman/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',

    -- LSP status updates
    { 'j-hui/fidget.nvim', opts = {} },

    -- -- Completion capabilities
    -- 'hrsh7th/cmp-nvim-lsp',

    -- -- Additional features
    -- { 'antosha417/nvim-lsp-file-operations', config = true }, -- Support for file operations
  },

  config = function()
    -- LSP capabilities (for nvim-cmp)
    local capabilities = vim.tbl_deep_extend('force', vim.lsp.protocol.make_client_capabilities(), require('cmp_nvim_lsp').default_capabilities())

    -- Diagnostic signs
    local signs = {
      [vim.diagnostic.severity.ERROR] = ' ',
      [vim.diagnostic.severity.WARN] = ' ',
      [vim.diagnostic.severity.HINT] = '󰠠 ',
      [vim.diagnostic.severity.INFO] = ' ',
    }
    for type, icon in pairs(signs) do
      vim.fn.sign_define('DiagnosticSign' .. type, {
        text = icon,
        texthl = 'DiagnosticSign' .. type,
        numhl = '',
      })
    end

    -- Diagnostics configuration
    vim.diagnostic.config {
      severity_sort = true,
      float = { border = 'rounded', source = 'if_many' },
      underline = { severity = vim.diagnostic.severity.ERROR },
      virtual_text = {
        source = 'if_many',
        spacing = 2,
        format = function(diagnostic)
          return diagnostic.message
        end,
      },
    }

    -- LSP server configurations
    local servers = {
      gopls = {},
      vtsls = {},
      pyright = {},
      marksman = {},
      html = {},
      cssls = {},
      tailwindcss = {},
      eslint = {},
      lua_ls = {
        settings = {
          Lua = {
            completion = {
              callSnippet = 'Replace',
            },
            diagnostics = { globals = { 'vim' } },
          },
        },
      },
    }

    -- Install tools via Mason
    require('mason-tool-installer').setup {
      ensure_installed = vim.tbl_extend('force', vim.tbl_keys(servers), {
        -- Formatters
        'stylua',
        'prettierd',
        'prettier',
        'isort',
        'black',
        -- Linters
        'eslint_d',
        'pylint',
        'markdownlint-cli2',
      }),
      automatic_installation = true,
    }

    -- LSP event handler (on attach)
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
      callback = function(event)
        local map = function(keys, func, desc, mode)
          local modes = mode or 'n'
          vim.keymap.set(modes, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        -- LSP keymaps
        map('gR', '<cmd>Telescope lsp_references<CR>', 'Show LSP references')
        map('gD', vim.lsp.buf.declaration, 'Go to declaration')
        map('gd', '<cmd>Telescope lsp_definitions<CR>', 'Show LSP definitions')
        map('gi', '<cmd>Telescope lsp_implementations<CR>', 'Show LSP implementations')
        map('gt', '<cmd>Telescope lsp_type_definitions<CR>', 'Show LSP type definitions')
        map('<leader>ca', vim.lsp.buf.code_action, 'See available code actions', { 'n', 'v' })
        map('<leader>rn', vim.lsp.buf.rename, 'Smart rename')
        map('<leader>D', '<cmd>Telescope diagnostics bufnr=0<CR>', 'Show buffer diagnostics')
        map('<leader>d', vim.diagnostic.open_float, 'Show line diagnostics')
        map('[d', vim.diagnostic.goto_prev, 'Go to previous diagnostic')
        map(']d', vim.diagnostic.goto_next, 'Go to next diagnostic')
        map('K', vim.lsp.buf.hover, 'Show documentation')
        map('<leader>rs', ':LspRestart<CR>', 'Restart LSP')
        map('<leader>ds', require('telescope.builtin').lsp_document_symbols, 'Document Symbols')
        map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Workspace Symbols')

        -- Document highlight (references)
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
          local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
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
            group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
            callback = function()
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds { group = highlight_augroup, buffer = event.buf }
            end,
          })
        end

        -- Toggle inlay hints
        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
          map('<leader>th', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
          end, 'Toggle Inlay Hints')
        end
      end,
    })

    -- Configure and setup LSP servers
    require('mason-lspconfig').setup {
      handlers = {
        function(server_name)
          local server = servers[server_name] or {}
          server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
          require('lspconfig')[server_name].setup(server)
        end,
        -- Special handler for Svelte
        svelte = function()
          require('lspconfig').svelte.setup {
            capabilities = capabilities,
            on_attach = function(client, bufnr)
              vim.api.nvim_create_autocmd('BufWritePost', {
                pattern = { '*.js', '*.ts' },
                callback = function(ctx)
                  client.notify('$/onDidChangeTsOrJsFile', { uri = ctx.match })
                end,
              })
            end,
          }
        end,
      },
    }
  end,
}
