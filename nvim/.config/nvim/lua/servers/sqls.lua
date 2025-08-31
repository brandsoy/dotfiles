return {
	filetypes = { "sql", "mysql", "plsql" },
	settings = {
		sqls = {
			connections = {
				-- You can configure database connections here
				-- Example:
				-- {
				-- 	driver = "postgresql",
				-- 	dataSourceName = "host=127.0.0.1 port=5432 user=postgres password=password dbname=test sslmode=disable",
				-- },
				-- {
				-- 	driver = "mysql",
				-- 	dataSourceName = "root:password@tcp(127.0.0.1:3306)/test",
				-- },
			},
		},
	},
}