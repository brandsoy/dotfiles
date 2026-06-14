local M = {}

local project_config = require('config.lsp.project_config')

function M.get()
	return {
		lua_ls = {
			settings = {
				Lua = {
					completion = { callSnippet = 'Replace' },
					diagnostics = { globals = { 'vim' } },
					hint = { enable = true },
					runtime = { version = 'LuaJIT' },
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
						typeCheckingMode = 'standard',
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
					matcher = 'Fuzzy',
					directoryFilters = { '-node_modules' },
					gofumpt = true,
				},
			},
		},
		bashls = {},
		biome = {
			root_dir = project_config.root_with_config(project_config.biome_files),
		},
		eslint = {
			root_dir = project_config.root_with_config(project_config.eslint_files, 'eslintConfig'),
		},
		taplo = {},
		postgres_lsp = {
			filetypes = { 'sql' },
			workspace_required = false,
			cmd = { 'postgres-language-server', 'lsp-proxy' },
		},
	}
end

return M
