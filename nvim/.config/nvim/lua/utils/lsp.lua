local M = {}

M.on_attach = function(client, bufnr)
	-- Enable inlay hints if supported
	if client.server_capabilities.inlayHintProvider then
		vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
	end

	-- Prefer external formatters (Conform) for these servers
	local disable_fmt = {
		tsserver = true,
		ts_ls = true,
		lua_ls = true,
		jsonls = true,
		yamlls = true,
	}
	if disable_fmt[client.name] then
		client.server_capabilities.documentFormattingProvider = false
		client.server_capabilities.documentRangeFormattingProvider = false
	end

	local keymap = vim.keymap.set
	local opts = { noremap = true, silent = true, buffer = bufnr }

	-- native neovim keymaps
	keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts) -- goto definition
	keymap("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts) -- goto declaration
	keymap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts) -- goto implementation
	keymap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts) -- goto references
	keymap("n", "<leader>gT", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts) -- goto type definition
	keymap("n", "<leader>gS", "<cmd>vsplit | lua vim.lsp.buf.definition()<CR>", opts) -- goto definition in split
	keymap("n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts) -- Code actions
	keymap("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts) -- Rename symbol
	keymap("n", "<leader>D", "<cmd>lua vim.diagnostic.open_float({ scope = 'line' })<CR>", opts) -- Line diagnostics (float)
	keymap("n", "<leader>d", "<cmd>lua vim.diagnostic.open_float()<CR>", opts) -- Cursor diagnostics
	keymap("n", "<leader>pd", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts) -- previous diagnostic
	keymap("n", "<leader>nd", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts) -- next diagnostic
	keymap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts) -- hover documentation
	keymap("n", "<leader>sh", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts) -- signature help
	keymap("n", "<leader>fm", "<cmd>lua vim.lsp.buf.format({ async = true })<CR>", opts) -- format document

	-- Workspace management
	keymap("n", "<leader>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", opts) -- add workspace folder
	keymap("n", "<leader>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", opts) -- remove workspace folder
	keymap("n", "<leader>wl", "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>", opts) -- list workspace folders

	-- Call hierarchy
	keymap("n", "<leader>ci", "<cmd>lua vim.lsp.buf.incoming_calls()<CR>", opts) -- incoming calls
	keymap("n", "<leader>co", "<cmd>lua vim.lsp.buf.outgoing_calls()<CR>", opts) -- outgoing calls

	-- Visual mode LSP operations
	keymap("v", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts) -- Code actions (visual)
	keymap("v", "<leader>fm", "<cmd>lua vim.lsp.buf.format()<CR>", opts) -- format selection

	-- Additional common LSP operations
	keymap("n", "<leader>rs", "<cmd>lua vim.lsp.buf.document_symbol()<CR>", opts) -- document symbols
	keymap("n", "<leader>ws", "<cmd>lua vim.lsp.buf.workspace_symbol()<CR>", opts) -- workspace symbols

	-- fzf-lua keymaps (enhanced LSP features)
	keymap("n", "<leader>gd", "<cmd>FzfLua lsp_finder<CR>", opts) -- LSP Finder (definition + references)
	keymap("n", "<leader>gr", "<cmd>FzfLua lsp_references<CR>", opts) -- Show all references to the symbol under the cursor
	keymap("n", "<leader>gt", "<cmd>FzfLua lsp_typedefs<CR>", opts) -- Jump to the type definition of the symbol under the cursor
	keymap("n", "<leader>gi", "<cmd>FzfLua lsp_implementations<CR>", opts) -- Go to implementation

	-- Order Imports (if supported by the client LSP)
	if client.supports_method("textDocument/codeAction") then
		keymap("n", "<leader>oi", function()
			vim.lsp.buf.code_action({
				context = {
					only = { "source.organizeImports" },
					diagnostics = {},
				},
				apply = true,
				bufnr = bufnr,
			})
			-- format after changing import order
			vim.defer_fn(function()
				local ok, conform = pcall(require, "conform")
				if ok then
					conform.format({ bufnr = bufnr, lsp_fallback = true, timeout_ms = 1500 })
				else
					vim.lsp.buf.format({ bufnr = bufnr })
				end
			end, 50)
		end, opts)
	end

	-- Toggle inlay hints
	if client.server_capabilities.inlayHintProvider then
		keymap("n", "<leader>ih", function()
			vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
		end, opts)
	end
end

M.enable = function(server)
  local ok, config = pcall(require, "servers." .. server)
  if ok then
    config.on_attach = M.on_attach
    config.capabilities = M.capabilities
    -- Ensure root_dir is set for proper workspace detection
    if not config.root_dir then
      config.root_dir = vim.fs.root(0, { ".git", "package.json", "Cargo.toml", "go.mod", "pyproject.toml" })
    end

    -- Start the server via nvim-lspconfig
    local lspconfig_ok, lspconfig = pcall(require, "lspconfig")
    if not lspconfig_ok then
      vim.notify("nvim-lspconfig not available", vim.log.levels.ERROR)
      return
    end
    if not lspconfig[server] then
      vim.notify("lspconfig has no server named: " .. server, vim.log.levels.WARN)
      return
    end
    lspconfig[server].setup(config)
  else
    vim.notify("LSP config not found for " .. server, vim.log.levels.WARN)
  end
end

return M