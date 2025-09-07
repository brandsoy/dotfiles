return function()
	vim.pack.add({
		{ src = "https://github.com/neovim/nvim-lspconfig" },
		{ src = "https://github.com/mason-org/mason.nvim" },
		{ src = "https://github.com/mason-org/mason-lspconfig.nvim" },
		{ src = "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim" },
		{ src = "https://github.com/saghen/blink.cmp" },
		{ src = "https://github.com/rafamadriz/friendly-snippets" },
		{ src = "https://github.com/stevearc/conform.nvim" },
		{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
		{ src = "https://github.com/ray-x/go.nvim" },
		{ src = "https://github.com/ray-x/guihua.lua" },
	})

	require("mason").setup()
	require("mason-lspconfig").setup()

	require("mason-tool-installer").setup({
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

	local lspconfig = require("lspconfig")
	local capabilities = require("blink.cmp").get_lsp_capabilities()

	-- Setup servers (you can loop if you want to reduce repetition)
	lspconfig.gopls.setup({
		capabilities = capabilities,
		settings = {
			gopls = {
				analyses = { unusedparams = true, unreachable = true },
				staticcheck = true,
			},
		},
	})
	lspconfig.ts_ls.setup({ capabilities = capabilities })

	-- Blink
	require("blink.cmp").setup({
		keymap = { preset = "default" },
		appearance = { nerd_font_variant = "mono" },
		completion = { documentation = { auto_show = true } },
		sources = { default = { "lsp", "path", "snippets", "buffer" } },
		opts_extend = { "sources.default" },
	})
	vim.opt.completeopt:append("noselect")

	-- Conform
	require("conform").setup({
		format_on_save = { lsp_fallback = true, timeout_ms = 2000 },
		formatters_by_ft = {
			lua = { "stylua" },
			javascript = { "prettierd" },
			typescript = { "prettierd" },
			typescriptreact = { "prettierd" },
			javascriptreact = { "prettierd" },
			json = { "prettierd" },
			yaml = { "prettierd" },
			markdown = { "prettierd" },
			go = { "golines", "gofumpt" },
		},
	})

	-- nvim-lint
	require("lint").linters_by_ft = {
		javascript = { "eslint_d" },
		javascriptreact = { "eslint_d" },
		typescript = { "eslint_d" },
		typescriptreact = { "eslint_d" },
	}

	-- ================================================================================================
	-- AUTOCMDS
	-- ================================================================================================
	vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
		callback = function()
			require("lint").try_lint()
		end,
	})

	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("UserLspConfig", {}),
		callback = function(ev)
			local bufnr = ev.buf
			local client = vim.lsp.get_client_by_id(ev.data.client_id)
			if not client then
				return
			end

			-- Enable completion
			if client:supports_method("textDocument/completion") then
				vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
			end
			-- Enable inlay hints
			if client.server_capabilities.inlayHintProvider then
				pcall(vim.lsp.inlay_hint.enable, true, { bufnr = bufnr })
			end

			-- Omnifunc
			vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"

			-- Keymaps
			local opts = { buffer = bufnr, silent = true, noremap = true }
			local keymap = vim.keymap.set

			local function map(mode, lhs, rhs, desc)
				keymap(mode, lhs, rhs, vim.tbl_extend("force", opts, { desc = desc }))
			end

			map("n", "gd", vim.lsp.buf.definition, "Go to Definition")
			map("n", "gD", vim.lsp.buf.declaration, "Go to Declaration")
			map("n", "gi", vim.lsp.buf.implementation, "Go to Implementation")
			map("n", "gr", vim.lsp.buf.references, "List References")
			map("n", "K", vim.lsp.buf.hover, "Hover Documentation")
			map("n", "<leader>lr", vim.lsp.buf.rename, "Rename Symbol")
			map("n", "<leader>la", vim.lsp.buf.code_action, "Code Action")
			map("n", "<leader>lk", vim.lsp.buf.signature_help, "Signature Help")
			map("n", "<leader>lf", function()
				vim.lsp.buf.format({ async = true })
			end, "Format Buffer")

			map("n", "[d", vim.diagnostic.goto_prev, "Previous Diagnostic")
			map("n", "]d", vim.diagnostic.goto_next, "Next Diagnostic")
			map("n", "<leader>le", vim.diagnostic.open_float, "Show Diagnostics (Float)")
			map("n", "<leader>lq", vim.diagnostic.setloclist, "Diagnostics to Location List")
		end,
	})
end
