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
		'html',
		'htmlangular',
		'html-eex',
		'heex',
		'jade',
		'leaf',
		'liquid',
		'markdown',
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
		htmx = {
			filetypes = htmx_filetypes,
		},
		tsgo = {},
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
			filetypes = { 'html', 'javascriptreact', 'typescriptreact', 'vue', 'svelte', 'astro' },
		},
		svelte = {},
	}
end

return M
