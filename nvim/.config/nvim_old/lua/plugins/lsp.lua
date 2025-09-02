return {
  {
    "mason-org/mason.nvim",
    dependencies = {
      "mason-org/mason-lspconfig.nvim",
      "neovim/nvim-lspconfig",
      "artemave/workspace-diagnostics.nvim",
      "saghen/blink.cmp",
    },
    opts = {
      servers = {
        lua_ls = {
          settings = {
            Lua = {
              version = "LuaJIT",
              diagnostics = {
                globals = {
                  "vim",
                  "require",
                },
              },
              workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
              },
              telemetry = {
                enable = false,
              },
            },
            ts_ls = {
              on_attach = function(client, bufnr)
                require("workspace-diagnostics").populate_workspace_diagnostics(client, bufnr)
              end,
            },
            eslint = {},
            tailwindcss = {},
          },
        },
      },
    },
    config = function(_, opts)
      require("mason").setup()

      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "pyright",
          "gopls",
          "jsonls",
          "ts_ls",
          "bashls",
          "dockerls",
          "dockerls",
          "yamlls",
          "tailwindcss",
          "eslint",
          "sqls",
        },
      })

      require("mason").setup({
        ensure_installed = {
          "prettier",
          "prettierd",
          "eslint_d",
          "biome",
          "shfmt",
          "stylua",
        },
      })

      local lspconfig = require("lspconfig")

      for server, config in pairs(opts.servers) do
        -- vim.lsp.config(server,config)
        lspconfig[server].setup(config)
        vim.lsp.enable(server)
      end
    end,
  },
}
-- local M = {}
--
-- M.on_attach = function(client, bufnr)
-- 	-- Enable inlay hints if supported
-- 	if client.server_capabilities.inlayHintProvider then
-- 		vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
-- 	end
--
-- 	-- Prefer external formatters (Conform) for these servers
-- 	local disable_fmt = {
-- 		tsserver = true,
-- 		ts_ls = true,
-- 		lua_ls = true,
-- 		jsonls = true,
-- 		yamlls = true,
-- 	}
-- 	if disable_fmt[client.name] then
-- 		client.server_capabilities.documentFormattingProvider = false
-- 		client.server_capabilities.documentRangeFormattingProvider = false
-- 	end
--
-- 	local keymap = vim.keymap.set
-- 	local opts = { noremap = true, silent = true, buffer = bufnr }
--
-- 	-- Order Imports (if supported by the client LSP)
-- 	if client.supports_method("textDocument/codeAction") then
-- 		keymap("n", "<leader>oi", function()
-- 			vim.lsp.buf.code_action({
-- 				context = {
-- 					only = { "source.organizeImports" },
-- 					diagnostics = {},
-- 				},
-- 				apply = true,
-- 				bufnr = bufnr,
-- 			})
-- 			-- format after changing import order
-- 			vim.defer_fn(function()
-- 				local ok, conform = pcall(require, "conform")
-- 				if ok then
-- 					conform.format({ bufnr = bufnr, lsp_fallback = true, timeout_ms = 1500 })
-- 				else
-- 					vim.lsp.buf.format({ bufnr = bufnr })
-- 				end
-- 			end, 50)
-- 		end, opts)
-- 	end
--
-- 	-- Toggle inlay hints
-- 	if client.server_capabilities.inlayHintProvider then
-- 		keymap("n", "<leader>ih", function()
-- 			vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
-- 		end, opts)
-- 	end
-- end
--
-- M.enable = function(server)
-- 	local ok, config = pcall(require, "servers." .. server)
-- 	if ok then
-- 		config.on_attach = M.on_attach
-- 		config.capabilities = M.capabilities
-- 		-- Ensure root_dir is set for proper workspace detection
-- 		if not config.root_dir then
-- 			config.root_dir = vim.fs.root(0, { ".git", "package.json", "Cargo.toml", "go.mod", "pyproject.toml" })
-- 		end
--
-- 		-- Start the server via nvim-lspconfig
-- 		local lspconfig_ok, lspconfig = pcall(require, "lspconfig")
-- 		if not lspconfig_ok then
-- 			vim.notify("nvim-lspconfig not available", vim.log.levels.ERROR)
-- 			return
-- 		end
-- 		if not lspconfig[server] then
-- 			vim.notify("lspconfig has no server named: " .. server, vim.log.levels.WARN)
-- 			return
-- 		end
-- 		lspconfig[server].setup(config)
-- 	else
-- 		vim.notify("LSP config not found for " .. server, vim.log.levels.WARN)
-- 	end
-- end
--
-- return M
