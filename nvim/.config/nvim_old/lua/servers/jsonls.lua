return {
	filetypes = { "json", "jsonc" },
	settings = {
		json = {
			schemas = {
				{
					fileMatch = { "package.json" },
					url = "https://json.schemastore.org/package.json",
				},
				{
					fileMatch = { "tsconfig*.json" },
					url = "https://json.schemastore.org/tsconfig.json",
				},
				{
					fileMatch = { "jsconfig*.json" },
					url = "https://json.schemastore.org/jsconfig.json",
				},
				{
					fileMatch = { ".prettierrc", ".prettierrc.json" },
					url = "https://json.schemastore.org/prettierrc.json",
				},
				{
					fileMatch = { ".eslintrc", ".eslintrc.json" },
					url = "https://json.schemastore.org/eslintrc.json",
				},
				{
					fileMatch = { "babel.config.json" },
					url = "https://json.schemastore.org/babelrc.json",
				},
			},
			validate = { enable = true },
		},
	},
}
