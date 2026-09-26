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
		powershell_es = {
			filetypes = { 'ps1', 'psm1', 'psd1' },
			bundle_path = vim.fs.joinpath(
				vim.fn.stdpath('data'),
				'mason',
				'packages',
				'powershell-editor-services',
				'PowerShellEditorServices'
			),
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
			filetypes = {
				'astro',
				'css',
				'graphql',
				'html',
				'javascript',
				'javascriptreact',
				'json',
				'jsonc',
				'typescript',
				'typescriptreact',
				'vue',
			},
			root_dir = function(bufnr, on_dir)
				local config = project_config.find_file(bufnr, project_config.biome_files)
				on_dir(config and vim.fs.dirname(config) or vim.fs.root(bufnr, { '.git' }) or vim.uv.cwd())
			end,
		},
		eslint = {
			root_dir = project_config.root_with_config(project_config.eslint_files, 'eslintConfig'),
		},
		taplo = {},
		postgres_lsp = {
			filetypes = { 'sql' },
			workspace_required = false,
			cmd = { 'postgres-language-server', 'lsp-proxy' },
			-- Do not attach the PostgreSQL server to a SQL Server database project.
			root_dir = function(bufnr, on_dir)
				if project_config.sql_dialect(bufnr) ~= 'tsql' then
					on_dir(vim.fs.root(bufnr, { '.git' }) or vim.uv.cwd())
				end
			end,
		},
	}
end

return M
