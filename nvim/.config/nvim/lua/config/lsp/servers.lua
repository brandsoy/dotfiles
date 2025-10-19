local M = {}

local function configure_servers()
	local util_ok, util = pcall(require, "lspconfig.util")
	if not util_ok then
		vim.notify("nvim-lspconfig util module missing; skipping LSP setup", vim.log.levels.ERROR)
		return
	end

	if not (vim.lsp and vim.lsp.config) then
		vim.notify("vim.lsp.config API unavailable; update Neovim to 0.11+", vim.log.levels.ERROR)
		return
	end

	local blink_ok, blink = pcall(require, "blink.cmp")
	local capabilities = blink_ok and blink.get_lsp_capabilities() or vim.lsp.protocol.make_client_capabilities()

	local schemastore_ok, schemastore = pcall(require, "schemastore")

	local neodev_ok, neodev = pcall(require, "neodev")
	if neodev_ok then
		neodev.setup({
			library = { plugins = false },
		})
	end

	vim.diagnostic.config({
		virtual_text = { prefix = "●" },
		severity_sort = true,
		float = { border = "rounded", source = "if_many" },
	})

	local bundle_path = vim.fn.stdpath("data") .. "/mason/packages/powershell-editor-services/PowerShellEditorServices"

	local servers = {
		lua_ls = {
			settings = {
				Lua = {
					completion = { callSnippet = "Replace" },
					diagnostics = { globals = { "vim" } },
					hint = { enable = true },
					runtime = { version = "LuaJIT" },
					workspace = { checkThirdParty = false, library = vim.api.nvim_get_runtime_file("", true) },
					telemetry = { enable = false },
				},
			},
		},
		gopls = {
			settings = {
				analyses = {
					nilness = true,
					shadow = true,
					unusedparams = true,
					unusedwrite = true,
					useany = true,
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
		vtsls = {
			settings = {
				vtsls = {
					autoUseWorkspaceTsdk = true,
					experimental = {
						maxInlayHintLength = 25,
					},
				},
				typescript = {
					inlayHints = {
						includeInlayEnumMemberValueHints = true,
						includeInlayFunctionLikeReturnTypeHints = true,
						includeInlayFunctionParameterTypeHints = true,
						includeInlayParameterNameHints = "all",
						includeInlayParameterNameHintsWhenArgumentMatchesName = false,
						includeInlayPropertyDeclarationTypeHints = true,
						includeInlayVariableTypeHints = true,
					},
				},
				javascript = {
					inlayHints = {
						includeInlayEnumMemberValueHints = true,
						includeInlayFunctionLikeReturnTypeHints = true,
						includeInlayFunctionParameterTypeHints = true,
						includeInlayParameterNameHints = "all",
						includeInlayParameterNameHintsWhenArgumentMatchesName = false,
						includeInlayPropertyDeclarationTypeHints = true,
						includeInlayVariableTypeHints = true,
					},
				},
			},
			filetypes = {
				"javascript",
				"javascriptreact",
				"javascript.jsx",
				"typescript",
				"typescriptreact",
				"typescript.tsx",
				"vue",
				"svelte",
			},
		},
		jsonls = schemastore_ok and {
			settings = {
				json = {
					schemas = schemastore.json.schemas(),
					validate = { enable = true },
				},
			},
		} or {},
		yamlls = schemastore_ok and {
			settings = {
				yaml = {
					keyOrdering = false,
					schemaStore = { enable = false, url = "" },
					schemas = schemastore.yaml.schemas(),
				},
			},
		} or {},
		dockerls = {},
		tailwindcss = {
			filetypes = { "html", "javascriptreact", "typescriptreact", "vue", "svelte", "astro" },
			root_dir = util.root_pattern(
				"tailwind.config.js",
				"tailwind.config.ts",
				"postcss.config.js",
				"package.json",
				"node_modules"
			),
		},
		bashls = {},
		biome = {},
		tsp_server = {},
		svelte = {},
		vuels = {
			filetypes = { "vue", "typescript", "javascript" },
			init_options = {
				vue = {
					hybridMode = false,
				},
				typescript = {
					tsdk = vim.fn.getcwd() .. "/node_modules/typescript/lib",
				},
			},
		},
		powershell_es = {
			cmd = {
				"pwsh",
				"-NoLogo",
				"-NoProfile",
				"-Command",
				bundle_path .. "/Start-EditorServices.ps1",
				"-HostName",
				"nvim",
				"-HostProfileId",
				"0",
				"-HostVersion",
				"1.0.0",
				"-LogPath",
				vim.fn.stdpath("cache") .. "/powershell_es.log",
				"-LogLevel",
				"Normal",
				"-SessionDetailsPath",
				vim.fn.stdpath("cache") .. "/powershell_es.session.json",
				"-FeatureFlags",
				"@()",
			},
			filetypes = { "ps1" },
		},
		copilot = {},
	}

	local tools = {
		"eslint_d",
		"prettier",
		"prettierd",
		"biome",
		"golines",
		"stylua",
		"shfmt",
		"golangci-lint",
		"gofumpt",
		"gomodifytags",
		"gotests",
		"pgformatter",
		"iferr",
	}

	local server_names = vim.tbl_keys(servers)

	local mason = require("mason")
	local mason_lspconfig = require("mason-lspconfig")
	local mason_tool_installer = require("mason-tool-installer")

	mason.setup({
		registries = {
			"github:mason-org/mason-registry",
			"github:Crashdummyy/mason-registry",
		},
	})

	mason_lspconfig.setup({
		ensure_installed = server_names,
		automatic_enable = false,
	})

	mason_tool_installer.setup({
		ensure_installed = vim.list_extend(vim.list_extend({}, server_names), tools),
	})

	local function setup_server(name)
		local server = vim.tbl_deep_extend("force", {}, servers[name] or {}, { capabilities = capabilities })
		local ok, err = pcall(vim.lsp.config, name, server)
		if not ok then
			vim.notify(string.format("Failed to configure %s: %s", name, err), vim.log.levels.ERROR)
			return
		end

		local enable_ok, enable_err = pcall(vim.lsp.enable, name)
		if not enable_ok then
			vim.notify(string.format("Failed to enable %s: %s", name, enable_err), vim.log.levels.ERROR)
		end
	end

	for _, server_name in ipairs(server_names) do
		setup_server(server_name)
	end
end

function M.setup()
	configure_servers()
end

return M
