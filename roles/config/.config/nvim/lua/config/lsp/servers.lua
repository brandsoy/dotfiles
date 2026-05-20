local M = {}

local function configure_servers()
	local lspconfig_ok, lspconfig = pcall(require, "lspconfig")
	if not lspconfig_ok then
		vim.notify("nvim-lspconfig is required for this LSP setup", vim.log.levels.ERROR)
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
		biome = {},
		svelte = {},
		terraformls = { filetypes = { "terraform", "terraform-vars" } },
		prismals = { filetypes = { "prisma" } },
	}

	for name, cfg in pairs(servers) do
		local server = lspconfig[name]
		if server and server.setup then
			local ok, err = pcall(server.setup, vim.tbl_deep_extend("force", cfg, { capabilities = capabilities }))
			if not ok then
				vim.notify(string.format("Failed to configure %s: %s", name, err), vim.log.levels.ERROR)
			end
		else
			vim.notify(string.format("lspconfig server not found: %s", name), vim.log.levels.WARN)
		end
	end

	local custom_servers = {
		tsp_server = {
			cmd = { "tsp-server", "--stdio" },
		},
		postgres_lsp = {
			filetypes = { "sql" },
			workspace_required = false,
			cmd = { "postgres-language-server", "lsp-proxy" },
		},
	}

	if vim.lsp and vim.lsp.config and vim.lsp.enable then
		for name, cfg in pairs(custom_servers) do
			pcall(vim.lsp.config, name, vim.tbl_deep_extend("force", cfg, { capabilities = capabilities }))
		end

		local ft_to_servers = {}
		for name, cfg in pairs(custom_servers) do
			if type(cfg.filetypes) == "table" then
				for _, ft in ipairs(cfg.filetypes) do
					ft_to_servers[ft] = ft_to_servers[ft] or {}
					table.insert(ft_to_servers[ft], name)
				end
			end
		end

		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("CustomLspFileTypeEnable", { clear = true }),
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
end

function M.setup()
	configure_servers()
end

return M
