local M = {}

local config_cache = {
	prettier = {},
	eslint = {},
}

local function root_has_file(filename, patterns)
	if not filename or filename == "" then
		return false
	end
	local root = vim.fs.dirname(filename)
	if not root then
		return false
	end
	return vim.fs.find(patterns, { path = root, upward = true })[1] ~= nil
end

local function root_has_prettier_config(filename)
	if not filename or filename == "" then
		return false
	end
	local root = vim.fs.dirname(filename)
	if not root then
		return false
	end
	if config_cache.prettier[root] ~= nil then
		return config_cache.prettier[root]
	end

	if
		root_has_file(filename, {
			".prettierrc",
			".prettierrc.json",
			".prettierrc.js",
			".prettierrc.yaml",
			".prettierrc.yml",
			"prettier.config.js",
			"prettier.config.cjs",
			"prettier.config.mjs",
		})
	then
		config_cache.prettier[root] = true
		return true
	end

	local package_json = vim.fs.find("package.json", { path = root, upward = true })[1]
	if not package_json then
		config_cache.prettier[root] = false
		return false
	end

	local ok_read, lines = pcall(vim.fn.readfile, package_json)
	if not ok_read then
		config_cache.prettier[root] = false
		return false
	end

	local ok_decode, data = pcall(vim.json.decode, table.concat(lines, "\n"))
	if not ok_decode or type(data) ~= "table" then
		config_cache.prettier[root] = false
		return false
	end

	local enabled = data.prettier ~= nil
	config_cache.prettier[root] = enabled
	return enabled
end

local function is_package_json(filename)
	if not filename or filename == "" then
		return false
	end
	return filename:match("[/\\]package%.json$") ~= nil
end

local function root_has_eslint_config(filename)
	if not filename or filename == "" then
		return false
	end
	local root = vim.fs.dirname(filename)
	if not root then
		return false
	end
	if config_cache.eslint[root] ~= nil then
		return config_cache.eslint[root]
	end

	if
		root_has_file(filename, {
			".eslintrc",
			".eslintrc.json",
			".eslintrc.js",
			".eslintrc.cjs",
			".eslintrc.yaml",
			".eslintrc.yml",
			"eslint.config.js",
			"eslint.config.cjs",
			"eslint.config.mjs",
		})
	then
		config_cache.eslint[root] = true
		return true
	end

	local package_json = vim.fs.find("package.json", { path = root, upward = true })[1]
	if not package_json then
		config_cache.eslint[root] = false
		return false
	end

	local ok_read, lines = pcall(vim.fn.readfile, package_json)
	if not ok_read then
		config_cache.eslint[root] = false
		return false
	end

	local ok_decode, data = pcall(vim.json.decode, table.concat(lines, "\n"))
	if not ok_decode or type(data) ~= "table" then
		config_cache.eslint[root] = false
		return false
	end

	local enabled = data.eslintConfig ~= nil
	config_cache.eslint[root] = enabled
	return enabled
end

function M.setup_conform()
	local conform = require("conform")
	conform.setup({
		format_on_save = function(bufnr)
			-- Skip if buffer is large
			if vim.b[bufnr].large_file then
				return
			end

			local ft = vim.bo[bufnr].filetype
			if ft == "markdown" then
				local filename = vim.api.nvim_buf_get_name(bufnr)
				if not root_has_prettier_config(filename) then
					return nil
				end
			end

			if ft == "svelte" then
				return { lsp_format = "prefer", timeout_ms = 1000 }
			end
			return { lsp_fallback = true, timeout_ms = 1000 }
		end,
		formatters = {
			biome = {
				condition = function(_, ctx)
					return root_has_file(ctx.filename, {
						"biome.json",
						"biome.jsonc",
						"biome.config.json",
						"biome.config.jsonc",
					})
				end,
			},
			prettierd = {
				condition = function(_, ctx)
					return is_package_json(ctx.filename) or root_has_prettier_config(ctx.filename)
				end,
			},
			prettier = {
				condition = function(_, ctx)
					return is_package_json(ctx.filename) or root_has_prettier_config(ctx.filename)
				end,
			},
		},
		formatters_by_ft = {
			lua = { "stylua" },
			javascript = { "biome", "prettierd", "prettier", stop_after_first = true },
			javascriptreact = { "biome", "prettierd", "prettier", stop_after_first = true },
			typescript = { "biome", "prettierd", "prettier", stop_after_first = true },
			typescriptreact = { "biome", "prettierd", "prettier", stop_after_first = true },
			svelte = {},
			json = { "biome", "prettierd", "prettier", stop_after_first = true },
			yaml = { "prettierd", "prettier", stop_after_first = true },
			markdown = { "prettierd", "prettier", stop_after_first = true },
			go = { "golines", "gofumpt" },
			sql = { "pg_format" },
			python = { "ruff_format", "ruff_organize_imports" },
			terraform = { "terraform_fmt" },
			hcl = { "terraform_fmt" },
		},
	})
end

function M.setup_lint()
	local lint = require("lint")
	lint.linters.eslint_d.condition = function(ctx)
		return root_has_eslint_config(ctx.filename)
	end
	lint.linters_by_ft = {
		javascript = { "eslint_d" },
		javascriptreact = { "eslint_d" },
		typescript = { "eslint_d" },
		typescriptreact = { "eslint_d" },
	}

	local lint_group = vim.api.nvim_create_augroup("LintGroup", { clear = true })
	local lint_timer = vim.uv.new_timer()
	local lintable = {
		javascript = true,
		javascriptreact = true,
		typescript = true,
		typescriptreact = true,
	}
	vim.api.nvim_create_autocmd({ "BufWritePost" }, {
		group = lint_group,
		callback = function(args)
			local ft = vim.bo[args.buf].filetype
			if not lintable[ft] then
				return
			end
			lint_timer:stop()
			lint_timer:start(250, 0, function()
				vim.schedule(function()
					pcall(require("lint").try_lint)
				end)
			end)
		end,
	})

	vim.api.nvim_create_autocmd("BufWritePost", {
		group = lint_group,
		pattern = "package.json",
		callback = function(args)
			local root = vim.fs.dirname(args.file)
			if not root then
				return
			end
			config_cache.prettier[root] = nil
			config_cache.eslint[root] = nil
		end,
	})
end

return M
