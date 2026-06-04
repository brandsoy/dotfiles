local M = {}

local project_config = require("config.lsp.project_config")

local function configure_servers()
	if not (vim.lsp and vim.lsp.config and vim.lsp.enable) then
		vim.notify("Neovim 0.11+ required for this LSP setup", vim.log.levels.ERROR)
		return
	end

	local schemastore_ok, schemastore = pcall(require, "schemastore")

	vim.diagnostic.config({
		virtual_text = { prefix = "●" },
		severity_sort = true,
		float = { border = "rounded", source = "if_many" },
		update_in_insert = false,
	})

	local capabilities = vim.lsp.protocol.make_client_capabilities()

	local servers = {
		lua_ls = {
			settings = {
				Lua = {
					completion = { callSnippet = "Replace" },
					diagnostics = { globals = { "vim" } },
					hint = { enable = true },
					runtime = { version = "LuaJIT" },
					workspace = { checkThirdParty = false },
					telemetry = { enable = false },
				},
			},
		},
		ruff = {},
		basedpyright = {
			settings = {
				basedpyright = {
					disableOrganizeImports = true,
					analysis = {
						typeCheckingMode = "standard",
						autoImportCompletions = true,
					},
				},
			},
		},
		gopls = {
			settings = {
				gopls = {
					analyses = {
						nilness = true,
						shadow = true,
						unusedparams = true,
						unusedwrite = true,
						useany = true,
					},
					usePlaceholders = true,
					completeUnimported = true,
					staticcheck = true,
					matcher = "Fuzzy",
					directoryFilters = { "-node_modules" },
					gofumpt = true,
				},
			},
		},
		tsgo = {},
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
			filetypes = {
				"html",
				"javascriptreact",
				"typescriptreact",
				"vue",
				"svelte",
				"astro",
			},
		},
		bashls = {},
		biome = {
			root_dir = project_config.root_with_config(project_config.biome_files),
		},
		eslint = {
			root_dir = project_config.root_with_config(project_config.eslint_files, "eslintConfig"),
		},
		svelte = {},
		terraformls = { filetypes = { "terraform", "terraform-vars" } },
		prismals = { filetypes = { "prisma" } },
		taplo = {},
		tsp_server = {
			cmd = { "tsp-server", "--stdio" },
		},
		postgres_lsp = {
			filetypes = { "sql" },
			workspace_required = false,
			cmd = { "postgres-language-server", "lsp-proxy" },
		},
	}

	local ft_to_servers = {}
	for name, cfg in pairs(servers) do
		local ok, err = pcall(vim.lsp.config, name, vim.tbl_deep_extend("force", cfg, { capabilities = capabilities }))
		if not ok then
			vim.notify(string.format("Failed to configure %s: %s", name, err), vim.log.levels.ERROR)
		end

		local resolved = vim.lsp.config[name]
		local fts = (resolved and resolved.filetypes) or cfg.filetypes
		if type(fts) == "table" then
			for _, ft in ipairs(fts) do
				ft_to_servers[ft] = ft_to_servers[ft] or {}
				table.insert(ft_to_servers[ft], name)
			end
		end
	end

	vim.api.nvim_create_autocmd("FileType", {
		group = vim.api.nvim_create_augroup("LspFileTypeEnable", { clear = true }),
		callback = function(ev)
			if vim.b.large_file then
				return
			end

			for _, name in ipairs(ft_to_servers[ev.match] or {}) do
				if not vim.lsp.get_clients({ name = name, bufnr = ev.buf })[1] then
					pcall(vim.lsp.enable, name, { bufnr = ev.buf })
				end
			end
		end,
	})
end

function M.setup()
	configure_servers()
end

return M
