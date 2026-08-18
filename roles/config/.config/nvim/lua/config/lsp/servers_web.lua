local M = {}

function M.get()
	local schemastore_ok, schemastore = pcall(require, 'schemastore')

	local htmx_filetypes = {
		'aspnetcorerazor',
		'astro',
		'astro-markdown',
		'blade',
		'clojure',
		'django-html',
		'edge',
		'eelixir',
		'elixir',
		'ejs',
		'erb',
		'eruby',
		'gohtml',
		'gohtmltmpl',
		'haml',
		'handlebars',
		'hbs',
		'htmx',
		'htmldjango',
		'htmlangular',
		'html-eex',
		'heex',
		'jade',
		'leaf',
		'liquid',
		'mdx',
		'mustache',
		'njk',
		'nunjucks',
		'php',
		'razor',
		'reason',
		'rescript',
		'slim',
		'svelte',
		'templ',
		'twig',
		'vue',
	}

	return {
		html = {},
		htmx = {
			filetypes = htmx_filetypes,
		},
		tsc = {
			cmd = { 'tsc', '--lsp', '--stdio' },
			filetypes = {
				'javascript',
				'javascriptreact',
				'javascript.jsx',
				'typescript',
				'typescriptreact',
				'typescript.tsx',
			},
			root_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' },
		},
		templ = {},
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
					schemaStore = { enable = false, url = '' },
					schemas = schemastore.yaml.schemas(),
				},
			},
		} or {},
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
