return function()
	-- Setup Mason
	require("mason").setup()
	-- Ensure LSP installed
	require("mason-lspconfig").setup({
		ensure_installed = {
			"lua_ls",
			"bashls",
			"dockerls",
			"sqls",
			"tailwindcss",
			"gopls",
			"ts_ls",
			"jsonls",
			"yamlls",
			"biome",
			"tsp_server",
		},
	})

	-- Ensure other stuff
	require("mason-tool-installer").setup({
		ensure_installed = {
			"eslint_d",
			"prettier",
			"prettierd",
			"golines",
			"stylua",
			"shfmt",
			"golangci-lint",
			"gofumpt",
			"gomodifytags",
			"gotests",
			"iferr",
		},
	})

	-- Setup lsp config
	local lspconfig = require("lspconfig")
	local capabilities = require("blink.cmp").get_lsp_capabilities()

	-- format on save autocmd
	local lsp_formatting = function(bufnr)
		vim.api.nvim_create_autocmd("BufWritePre", {
			buffer = bufnr,
			callback = function()
				vim.lsp.buf.format({ async = false })
			end,
		})
	end

	-- keymaps for LSP
	local on_attach = function(client, bufnr)
		local opts = { noremap = true, silent = true, buffer = bufnr }
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
		vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
		vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
		vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
		vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
		vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
		vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

		-- enable format on save
		if client.supports_method("textDocument/formatting") then
			lsp_formatting(bufnr)
		end
	end

	-- setup gopls
	lspconfig.gopls.setup({
		on_attach = on_attach,
		capabilities = capabilities,
		settings = {
			gopls = {
				analyses = {
					unusedparams = true,
					unreachable = true,
				},
				staticcheck = true,
			},
		},
	})

	lspconfig.ts_ls.setup({
		on_attach = on_attach,
		capabilities = capabilities,
		settings = {},
	})

	-- blink.cmp basic setup
	require("blink.cmp").setup({
		keymap = {
			preset = "default", -- <Tab> to confirm, <C-n>/<C-p> to navigate, etc.
		},
		sources = {
			default = { "lsp", "path", "buffer" },
		},
	})

	-- Conform.nvim (formatters/linters)
	require("conform").setup({
		format_on_save = {
			lsp_fallback = true,
			timeout_ms = 2000,
		},
		formatters_by_ft = {
			lua = { "stylua" },
			javascript = { "prettierd" },
			typescript = { "prettierd" },
			typescriptreact = { "prettierd" },
			javascriptreact = { "prettierd" },
			json = { "prettierd" },
			yaml = { "prettierd" },
			markdown = { "prettierd" },
			go = { "golines", "gofumpt" }, -- or rely on gopls
		},
	})

	-- nvim-lint (eslint_d diagnostics)
	require("lint").linters_by_ft = {
		javascript = { "eslint_d" },
		javascriptreact = { "eslint_d" },
		typescript = { "eslint_d" },
		typescriptreact = { "eslint_d" },
	}

	vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
		callback = function()
			require("lint").try_lint()
		end,
	})
end
