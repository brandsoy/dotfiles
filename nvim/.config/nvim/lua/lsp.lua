return function()
	-- Install stuff
	vim.pack.add({
		{ src = "https://github.com/neovim/nvim-lspconfig" },
		{ src = "https://github.com/mason-org/mason.nvim" },
		{ src = "https://github.com/mason-org/mason-lspconfig.nvim" },
		{ src = "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim" },
		{ src = "https://github.com/saghen/blink.cmp" },
		{ src = "https://github.com/L3MON4D3/LuaSnip" },
		{ src = "https://github.com/rafamadriz/friendly-snippets" },
		{ src = "https://github.com/stevearc/conform.nvim" },
		{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
		{ src = "https://github.com/ray-x/go.nvim" },
		{ src = "https://github.com/ray-x/guihua.lua" },
	})
	-- LSP Stuff
	local lspconfig = require("lspconfig")
	local capabilities = require("blink.cmp").get_lsp_capabilities()

	-- Default server configs
	local servers = {
		lua_ls = {
			settings = {
				Lua = {
					runtime = { version = "LuaJIT" },
					diagnostics = { globals = { "vim" } },
					-- workspace = { checkThirdParty = false },
					workspace = { library = vim.api.nvim_get_runtime_file("", true) },
					telemetry = { enable = false },
				},
			},
		},
		gopls = {
			settings = {
				analyses = {
					unusedparams = true,
					nilness = true,
					unusedwrite = true,
					useany = true,
					shadow = true,
				},
				codelenses = {
					generate = true,
					gc_details = true,
					test = true,
					tidy = true,
					vendor = true,
					regenerate_cgo = true,
					upgrade_dependency = true,
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
				usePlaceholders = true,
				completeUnimported = true,
				staticcheck = true,
				matcher = "Fuzzy",
				directoryFilters = { "-node_modules" },
				gofumpt = true,
			},
		},
		ts_ls = true,
		jsonls = true,
		yamlls = true,
		dockerls = true,
		sqls = true,
		tailwindcss = true,
		bashls = true,
		biome = true,
		tsp_server = true,
	}

	-- Tools (non-LSP)
	local tools = {
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
		"roslyn",
	}

	-- Mason installer: install servers + tools
	require("mason").setup({
		registries = {
			"github:mason-org/mason-registry",
			"github:Crashdummyy/mason-registry",
		},
	})

	require("mason-tool-installer").setup({
		ensure_installed = vim.list_extend(vim.tbl_keys(servers), tools),
	})

	-- Loop through servers for lspconfig setup
	for name, config in pairs(servers) do
		if config == true then
			config = {}
		end
		config.capabilities = capabilities
		lspconfig[name].setup(config)
	end

	-- Manual Rosly LSP setup
	vim.lsp.enable("roslyn")
	-- Optionally for custom executable:
	vim.lsp.config("roslyn", {
		cmd = {
			"dotnet",
			vim.fn.expand(
				"~/.local/share/nvim/mason/packages/roslyn/libexec/Microsoft.CodeAnalysis.LanguageServer.dll"
			),
			"--logLevel=Information",
			"--extensionLogDirectory=" .. vim.fs.dirname(vim.lsp.log.get_filename()),
		},
		filetypes = { "cs", "vb" },
		root_dir = vim.fs.dirname(vim.fs.find({ ".sln", ".csproj", ".git" }, { upward = true })[10]),
		-- root_dir = lspconfig.util.root_pattern("*.sln", "*.csproj", ".git"),
	})

	-- ================================================================================================
	-- COMPLETION
	-- ================================================================================================

	-- Recommended completeopt for modern completion UIs
	vim.opt.completeopt = { "menu", "menuone", "noselect" }

	require("luasnip.loaders.from_vscode").lazy_load() -- now safe

	-- Blink CMP setup
	require("blink.cmp").setup({
		keymap = {
			preset = "default", -- <Tab> confirm, <C-n>/<C-p> navigate
		},
		appearance = {
			nerd_font_variant = "mono",
		},
		fuzzy = {
			implementation = "prefer_rust",
			prebuilt_binaries = {
				force_version = nil,
			},
		},
		completion = {
			documentation = { auto_show = true }, -- show docs automatically
			ghost_text = { enabled = true }, -- inline ghost text
		},
		snippets = {
			expand = function(body)
				require("luasnip").lsp_expand(body)
			end,
		},
		sources = {
			default = { "lsp", "path", "snippets", "buffer" },
		},
	})

	-- LSP completion + inlay hints when available
	vim.api.nvim_create_autocmd("LspAttach", {
		callback = function(ev)
			local client = vim.lsp.get_client_by_id(ev.data.client_id)
			if not client then
				return
			end

			-- Enable completion (let blink handle popup UI)
			if client:supports_method("textDocument/completion") then
				vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
			end

			-- Enable inlay hints
			if client.server_capabilities.inlayHintProvider then
				pcall(vim.lsp.inlay_hint.enable, true, { bufnr = ev.buf })
			end
		end,
	})

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
