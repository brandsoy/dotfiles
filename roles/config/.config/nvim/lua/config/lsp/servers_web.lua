local M = {}

function M.get()
	local schemastore_ok, schemastore = pcall(require, 'schemastore')

	local yaml_filetypes = { 'yaml', 'yaml.ansible', 'yaml.docker-compose', 'yaml.gitlab', 'yaml.helm-values' }

	return {
		cssls = {},
		html = {},
		lemminx = {},
		htmx = {
			filetypes = { 'html', 'htmx' },
		},
		tsc = {},
		templ = {},
		jinja_lsp = {
			cmd = { 'jinja-lsp', '--stdio' },
			filetypes = { 'jinja' },
			root_markers = { 'jinja-lsp.toml', 'pyproject.toml', 'Cargo.toml', '.git' },
		},
		jsonls = schemastore_ok and {
			settings = {
				json = {
					schemas = schemastore.json.schemas(),
					validate = { enable = true },
				},
			},
		} or {},
		yamlls = {
			filetypes = yaml_filetypes,
			settings = schemastore_ok and {
				yaml = {
					keyOrdering = false,
					schemaStore = { enable = false, url = '' },
					schemas = schemastore.yaml.schemas(),
				},
			} or {},
		},
		tailwindcss = {
			filetypes = {
				'html',
				'css',
				'javascript',
				'javascriptreact',
				'typescript',
				'typescriptreact',
				'vue',
				'svelte',
				'astro',
				'templ',
			},
		},
		svelte = {},
	}
end

return M
