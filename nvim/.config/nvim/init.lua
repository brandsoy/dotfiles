vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.winborder = "rounded"

vim.pack.add({
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/mason-org/mason.nvim" },
	{ src = "https://github.com/mason-org/mason-lspconfig.nvim" },
	{ src = "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim" },
	{ src = "https://github.com/rose-pine/neovim" },
	{ src = "https://github.com/folke/which-key.nvim" },
	{ src = "https://github.com/nvim-mini/mini.pick" },
})

require("which-key").setup()
require("mini.pick").setup()

require("mason").setup()
require("mason-lspconfig").setup()
require("mason-tool-installer").setup({
	ensure_installed = {
		"lua_ls",
		"bashls",
		"pyright",
		"ruff",
		"dockerls",
		"eslint",
		"sqls",
		"prettier",
		"prettierd",
		"tailwindcss",
		"shfmt",
		"stylua",
		"gopls",
		"ts_ls",
		"jsonls",
		"yamlls",
		"biome",

	},
})

vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			runtime = { version = "LuaJIT" },
			diagnostics = { globals = { "vim", "require" } },
			workspace = { library = vim.api.nvim_get_runtime_file("", true) },
			telemetry = { enable = false },
		},
	},
})

vim.cmd("colorscheme rose-pine")
vim.cmd("set completeopt+=noselect")

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if client ~= nil and client:supports_method("textDocument/completion") then
			vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
		end
	end,
})

-- Autocmd for keymaps
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		local bufnr = ev.buf
		local opts = { buffer = bufnr, silent = true, noremap = true }

		local keymap = vim.keymap.set

		keymap("n", "gd", vim.lsp.buf.definition, opts)
		keymap("n", "gD", vim.lsp.buf.declaration, opts)
		keymap("n", "gi", vim.lsp.buf.implementation, opts)
		keymap("n", "gr", vim.lsp.buf.references, opts)
		keymap("n", "K", vim.lsp.buf.hover, opts)
		keymap("n", "<leader>rn", vim.lsp.buf.rename, opts)
		keymap("n", "<leader>ca", vim.lsp.buf.code_action, opts)
		keymap("n", "<leader>f", function()
			vim.lsp.buf.format({ async = true })
		end, opts)

		keymap("n", "[d", vim.diagnostic.goto_prev, opts)
		keymap("n", "]d", vim.diagnostic.goto_next, opts)
		keymap("n", "<leader>e", vim.diagnostic.open_float, opts)
		keymap("n", "<leader>q", vim.diagnostic.setloclist, opts)

		keymap("i", "<C-k>", vim.lsp.buf.signature_help, opts)
	end,
})
