return {
  {
    "williamboman/mason.nvim",
    lazy = false,
    config = function()
      require("mason").setup()
    end,
    opts = { ensure_installed = { "goimports", "gofumpt", "gomodifytags", "impl", "delve" } },
  },
  {
    "williamboman/mason-lspconfig.nvim",
    lazy = false,
    opts = {
      auto_install = true,
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gopls = {
          settings = {
            gopls = {
              gofumpt = true,
              codelenses = {
                gc_details = false,
                generate = true,
                regenerate_cgo = true,
                run_govulncheck = true,
                test = true,
                tidy = true,
                upgrade_dependency = true,
                vendor = true,
              },
              hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
              },
              analyses = {
                nilness = true,
                unusedparams = true,
                unusedwrite = true,
                useany = true,
              },
              usePlaceholders = true,
              completeUnimported = true,
              staticcheck = true,
              directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
              semanticTokens = true,
            },
          },
        },
        marksman = {
          settings = {
            markdown = {
              code_action = {
                toc = false, -- Disable Table of Contents generation
                create_missing_file = false, -- Prevent creating missing files
              },
              completion = {
                wiki = { style = "file-stem" }, -- Set wiki link style
              },
            },
          },
        },
      },
      setup = {
        gopls = function(_, opts)
          -- workaround for gopls not supporting semanticTokensProvider
          -- https://github.com/golang/go/issues/54531#issuecomment-1464982242
          LazyVim.lsp.on_attach(function(client, _)
            if not client.server_capabilities.semanticTokensProvider then
              local semantic = client.config.capabilities.textDocument.semanticTokens
              client.server_capabilities.semanticTokensProvider = {
                full = true,
                legend = {
                  tokenTypes = semantic.tokenTypes,
                  tokenModifiers = semantic.tokenModifiers,
                },
                range = true,
              }
            end
          end, "gopls")
          -- end workaround
        end,
      },
    },
  },

  -- {
  -- 	"neovim/nvim-lspconfig",
  -- 	lazy = false,
  -- 	config = function()
  -- 		local cmp_nvim_lsp = require("cmp_nvim_lsp")
  -- 		local capabilities = vim.tbl_deep_extend(
  -- 			"force",
  -- 			{},
  -- 			vim.lsp.protocol.make_client_capabilities(),
  -- 			cmp_nvim_lsp.default_capabilities()
  -- 		)
  --
  -- 		local lspconfig = require("lspconfig")
  --
  -- 		lspconfig.tailwindcss.setup({
  -- 			capabilities = capabilities,
  -- 		})
  -- 		lspconfig.lua_ls.setup({
  -- 			capabilities = capabilities,
  -- 		})
  --
  -- 		vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
  -- 		vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, {})
  -- 		vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, {})
  -- 		vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {})
  -- 		vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, {})
  -- 		vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, {})
  -- 	end,
  -- },
}
