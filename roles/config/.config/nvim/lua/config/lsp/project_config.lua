local M = {}

M.biome_files = {
	"biome.json",
	"biome.jsonc",
	".biome.json",
	".biome.jsonc",
}

M.prettier_files = {
	".prettierrc",
	".prettierrc.json",
	".prettierrc.json5",
	".prettierrc.yaml",
	".prettierrc.yml",
	".prettierrc.toml",
	".prettierrc.js",
	".prettierrc.cjs",
	".prettierrc.mjs",
	"prettier.config.js",
	"prettier.config.cjs",
	"prettier.config.mjs",
	"prettier.config.ts",
	"prettier.config.cts",
	"prettier.config.mts",
}

M.eslint_files = {
	"eslint.config.js",
	"eslint.config.cjs",
	"eslint.config.mjs",
	"eslint.config.ts",
	"eslint.config.cts",
	"eslint.config.mts",
	".eslintrc",
	".eslintrc.js",
	".eslintrc.cjs",
	".eslintrc.json",
	".eslintrc.yaml",
	".eslintrc.yml",
}

local function buf_dir(bufnr)
	local name = vim.api.nvim_buf_get_name(bufnr)
	if name == "" then
		return vim.uv.cwd()
	end
	return vim.fs.dirname(name)
end

function M.find_file(bufnr, names)
	return vim.fs.find(names, {
		path = buf_dir(bufnr),
		upward = true,
		type = "file",
	})[1]
end

local function package_has_field(package_json, field)
	local lines = vim.fn.readfile(package_json)
	local ok, package = pcall(vim.json.decode, table.concat(lines, "\n"))
	return ok and type(package) == "table" and package[field] ~= nil
end

local function package_has_dependency(package_json, dependency)
	local lines = vim.fn.readfile(package_json)
	local ok, package = pcall(vim.json.decode, table.concat(lines, "\n"))
	if not ok or type(package) ~= "table" then
		return false
	end

	for _, section in ipairs({ 'dependencies', 'devDependencies', 'peerDependencies', 'optionalDependencies' }) do
		if type(package[section]) == 'table' and package[section][dependency] ~= nil then
			return true
		end
	end

	return false
end

local function find_package_dependency(bufnr, dependency)
	local dir = buf_dir(bufnr)
	while dir do
		local package_json = vim.fs.joinpath(dir, 'package.json')
		if vim.fn.filereadable(package_json) == 1 and package_has_dependency(package_json, dependency) then
			return package_json
		end

		local parent = vim.fs.dirname(dir)
		if parent == dir then
			break
		end
		dir = parent
	end
end

function M.find_package_field(bufnr, field)
	local dir = buf_dir(bufnr)
	while dir do
		local package_json = vim.fs.joinpath(dir, "package.json")
		if
			vim.fn.filereadable(package_json) == 1
			and package_has_field(package_json, field)
		then
			return package_json
		end

		local parent = vim.fs.dirname(dir)
		if parent == dir then
			break
		end
		dir = parent
	end
end

function M.has_biome(bufnr)
	return M.find_file(bufnr, M.biome_files) ~= nil
end

function M.has_prettier(bufnr)
	return M.find_file(bufnr, M.prettier_files) ~= nil
		or M.find_package_field(bufnr, "prettier") ~= nil
		or find_package_dependency(bufnr, 'prettier') ~= nil
end

function M.has_eslint(bufnr)
	return M.find_file(bufnr, M.eslint_files) ~= nil
		or M.find_package_field(bufnr, "eslintConfig") ~= nil
end

-- A .sqlproj identifies a SQL Server database project.  Search upward so SQL
-- files anywhere below its database/ directory get the T-SQL toolchain.
function M.find_sqlproj(bufnr)
	local dir = buf_dir(bufnr)
	while dir do
		local handle = vim.uv.fs_scandir(dir)
		if handle then
			while true do
				local name, file_type = vim.uv.fs_scandir_next(handle)
				if not name then
					break
				end
				if file_type == "file" and name:sub(-8) == ".sqlproj" then
					return vim.fs.joinpath(dir, name)
				end
			end
		end

		local parent = vim.fs.dirname(dir)
		if parent == dir then
			break
		end
		dir = parent
	end
end

function M.sql_dialect(bufnr)
	return M.find_sqlproj(bufnr) and "tsql" or "postgres"
end

function M.root_with_config(files, package_field)
	return function(bufnr, on_dir)
		local file = M.find_file(bufnr, files)
		if file then
			on_dir(vim.fs.dirname(file))
			return
		end

		if package_field then
			local package_json = M.find_package_field(bufnr, package_field)
			if package_json then
				on_dir(vim.fs.dirname(package_json))
			end
		end
	end
end

return M
