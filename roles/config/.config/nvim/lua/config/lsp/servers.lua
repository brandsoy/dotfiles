local M = {}

local function configure_servers()
	if not (vim.lsp and vim.lsp.config and vim.lsp.enable) then
		vim.notify('Neovim 0.11+ required for this LSP setup', vim.log.levels.ERROR)
		return
	end

	local schemastore_ok, _ = pcall(require, 'schemastore')

	vim.diagnostic.config({
		virtual_text = { prefix = '●' },
		severity_sort = true,
		float = { border = 'rounded', source = 'if_many' },
		update_in_insert = false,
	})

	local capabilities = vim.lsp.protocol.make_client_capabilities()

	local server_tables = {
		require('config.lsp.servers_general').get(),
		require('config.lsp.servers_web').get(),
		require('config.lsp.servers_infra').get(),
	}

	local servers = vim.tbl_deep_extend('force', {}, unpack(server_tables))

	if not schemastore_ok then
		servers.jsonls = servers.jsonls or {}
		servers.yamlls = servers.yamlls or {}
	end

	local ft_to_servers = {}
	for name, cfg in pairs(servers) do
		local ok, err = pcall(vim.lsp.config, name, vim.tbl_deep_extend('force', cfg, { capabilities = capabilities }))
		if not ok then
			vim.notify(string.format('Failed to configure %s: %s', name, err), vim.log.levels.ERROR)
		end

		local resolved = vim.lsp.config[name]
		local fts = (resolved and resolved.filetypes) or cfg.filetypes
		if type(fts) == 'table' then
			for _, ft in ipairs(fts) do
				ft_to_servers[ft] = ft_to_servers[ft] or {}
				table.insert(ft_to_servers[ft], name)
			end
		end
	end

	vim.api.nvim_create_autocmd('FileType', {
		group = vim.api.nvim_create_augroup('LspFileTypeEnable', { clear = true }),
		callback = function(ev)
			if vim.b.large_file then
				return
			end

			for _, name in ipairs(ft_to_servers[ev.match] or {}) do
				if not vim.lsp.get_clients({ name = name, bufnr = ev.buf })[1] then
					pcall(vim.lsp.enable, name, { bufnr = ev.buf })
				end
			end
		end,
	})
end

function M.setup()
	configure_servers()
end

return M
