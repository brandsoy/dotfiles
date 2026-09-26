local M = {}

local project_config = require('config.lsp.project_config')

function M.project_formatter(bufnr, opts)
	opts = opts or {}

	if opts.allow_biome ~= false and project_config.has_biome(bufnr) then
		return opts.biome or { 'biome', stop_after_first = true }
	end

	if project_config.has_prettier(bufnr) then
		return opts.prettier or { 'prettierd', 'prettier', stop_after_first = true }
	end

	return {}
end

function M.web(bufnr)
	return M.project_formatter(bufnr)
end

function M.prettier_only(bufnr)
	return M.project_formatter(bufnr, { allow_biome = false })
end

return M
