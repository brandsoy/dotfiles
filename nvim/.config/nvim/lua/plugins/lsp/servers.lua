-- Install LSP and completion related packages
vim.pack.add({
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/mason-org/mason.nvim" },
	{ src = "https://github.com/mason-org/mason-lspconfig.nvim" },
	{ src = "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim" },
	{ src = "https://github.com/saghen/blink.cmp" },
})

local lspconfig = require("lspconfig")
local capabilities = require("blink.cmp").get_lsp_capabilities()

-- Default server configs
local servers = {
	lua_ls = {
		settings = {
			Lua = {
				runtime = { version = "LuaJIT" },
				diagnostics = { globals = { "vim" } },
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