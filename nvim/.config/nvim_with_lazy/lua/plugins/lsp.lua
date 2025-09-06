return {{
    "mason-org/mason.nvim",
    dependencies = {"mason-org/mason-lspconfig.nvim", "neovim/nvim-lspconfig", "artemave/workspace-diagnostics.nvim",
                    "saghen/blink.cmp"},
    opts = {
        servers = {
            lua_ls = require("lsp.lua_ls"),
            gopls = require("lsp.gopls"),
            ts_ls = require("lsp.ts_ls"),
            eslint = {},
            tailwindcss = {},
            pyright = {},
            jsonls = {},
            bashls = {},
            dockerls = {},
            yamlls = {},
            sqls = {}
        }
    },
    config = function(_, opts)
        -- Add duplicate LSP prevention at the top
        local function prevent_duplicate_lsp_attach()
          -- Override LSP attach to prevent duplicates
          local original_start_client = vim.lsp.start_client
          vim.lsp.start_client = function(config)
            -- Check if client with same name is already running for this buffer
            local existing_clients = vim.lsp.get_active_clients({ name = config.name })
            if #existing_clients > 0 then
              local bufnr = vim.api.nvim_get_current_buf()
              for _, client in ipairs(existing_clients) do
                local client_buffers = vim.lsp.get_buffers_by_client_id(client.id)
                for _, buf in ipairs(client_buffers) do
                  if buf == bufnr then
                    -- Client already attached to this buffer
                    return client.id
                  end
                end
              end
            end
            return original_start_client(config)
          end
        end

        local function setup_lsp_diagnostics()
          -- Command to check active LSP clients
          vim.api.nvim_create_user_command('LspClients', function()
            local clients = vim.lsp.get_active_clients()
            local bufnr = vim.api.nvim_get_current_buf()
            local buffer_clients = vim.lsp.get_active_clients({ bufnr = bufnr })
            
            print("=== All Active LSP Clients ===")
            for _, client in ipairs(clients) do
              print(string.format("Client: %s (ID: %d, Root: %s)", client.name, client.id, client.config.root_dir or "unknown"))
            end
            
            print("\n=== Clients for Current Buffer ===")
            for _, client in ipairs(buffer_clients) do
              print(string.format("Client: %s (ID: %d, Root: %s)", client.name, client.id, client.config.root_dir or "unknown"))
            end
          end, {})

          -- Command to clean up duplicate gopls clients
          vim.api.nvim_create_user_command('LspCleanGopls', function()
            local all_clients = vim.lsp.get_active_clients({ name = "gopls" })
            if #all_clients <= 1 then
              print("No duplicate gopls clients found")
              return
            end
            
            -- Group by root directory and keep only one per unique root
            local root_to_client = {}
            local duplicates = {}
            
            for _, client in ipairs(all_clients) do
              local root = client.config.root_dir or "unknown"
              if root_to_client[root] then
                table.insert(duplicates, client)
              else
                root_to_client[root] = client
              end
            end
            
            -- Stop duplicate clients
            for _, client in ipairs(duplicates) do
              client.stop()
              print(string.format("Stopped duplicate gopls client (ID: %d, Root: %s)", client.id, client.config.root_dir or "unknown"))
            end
            
            print(string.format("Cleaned up %d duplicate gopls clients", #duplicates))
          end, {})

          -- Command to clean up duplicate lua_ls clients
          vim.api.nvim_create_user_command('LspCleanLua', function()
            local all_clients = vim.lsp.get_active_clients({ name = "lua_ls" })
            if #all_clients <= 1 then
              print("No duplicate lua_ls clients found")
              return
            end
            
            -- Group by root directory and keep only one per unique root
            local root_to_client = {}
            local duplicates = {}
            
            for _, client in ipairs(all_clients) do
              local root = client.config.root_dir or "unknown"
              if root_to_client[root] then
                table.insert(duplicates, client)
              else
                root_to_client[root] = client
              end
            end
            
            -- Stop duplicate clients
            for _, client in ipairs(duplicates) do
              client.stop()
              print(string.format("Stopped duplicate lua_ls client (ID: %d, Root: %s)", client.id, client.config.root_dir or "unknown"))
            end
            
            print(string.format("Cleaned up %d duplicate lua_ls clients", #duplicates))
          end, {})

          -- Autocommand to prevent duplicate LSP attachments
          vim.api.nvim_create_autocmd("LspAttach", {
            callback = function(args)
              local client = vim.lsp.get_client_by_id(args.data.client_id)
              local bufnr = args.buf
              
              -- Check for duplicates
              local clients = vim.lsp.get_active_clients({ bufnr = bufnr })
              local same_name_clients = {}
              
              for _, c in ipairs(clients) do
                if c.name == client.name then
                  table.insert(same_name_clients, c)
                end
              end
              
              -- Special handling for gopls and lua_ls - keep the one with the higher root directory
              if (client.name == "gopls" or client.name == "lua_ls") and #same_name_clients > 1 then
                table.sort(same_name_clients, function(a, b)
                  local a_root = a.config.root_dir or ""
                  local b_root = b.config.root_dir or ""
                  -- Keep the client with shorter root path (higher in directory tree)
                  return #a_root < #b_root
                end)
                
                -- Detach all but the first (highest level) client
                for i = 2, #same_name_clients do
                  vim.lsp.buf_detach_client(bufnr, same_name_clients[i].id)
                  print(string.format("Detached nested %s client: %s (ID: %d, Root: %s)", 
                    client.name, same_name_clients[i].name, same_name_clients[i].id, same_name_clients[i].config.root_dir or "unknown"))
                end
              elseif #same_name_clients > 1 then
                -- For other LSPs, detach the newer ones
                for i = 2, #same_name_clients do
                  vim.lsp.buf_detach_client(bufnr, same_name_clients[i].id)
                  print(string.format("Detached duplicate LSP client: %s (ID: %d)", same_name_clients[i].name, same_name_clients[i].id))
                end
              end
            end,
          })
        end

        setup_lsp_diagnostics()
        prevent_duplicate_lsp_attach()
        
        -- Simple Mason setup
        require("mason").setup({
            ui = {
                border = "rounded"
            }
        })
        
        require("mason-lspconfig").setup({
            ensure_installed = vim.tbl_keys(opts.servers),
            automatic_installation = false,  -- Prevent auto-setup
            handlers = {
                -- Default handler that does nothing (we handle setup manually)
                function() end,
                -- Only handle servers that don't have custom configs
                function(server_name)
                    if not opts.servers[server_name] then
                        require("lspconfig")[server_name].setup({
                            capabilities = capabilities,
                            on_attach = on_attach
                        })
                    end
                end
            }
        })

        local lspconfig = require("lspconfig")
        local capabilities = require("blink.cmp").get_lsp_capabilities()

        -- Simple on_attach function
        local function on_attach(client, bufnr)
            -- Enable completion triggered by <c-x><c-o>
            vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
            
            -- Setup buffer-local keymaps
            local map = function(keys, func, desc)
                vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
            end

            map("gd", vim.lsp.buf.definition, "Go to Definition")
            map("gr", vim.lsp.buf.references, "Go to References")
            map("K", vim.lsp.buf.hover, "Hover Documentation")
            map("<leader>ca", vim.lsp.buf.code_action, "Code Action")
            map("<F2>", vim.lsp.buf.rename, "Rename")
            map("[d", vim.diagnostic.goto_prev, "Previous Diagnostic")
            map("]d", vim.diagnostic.goto_next, "Next Diagnostic")
            map("gl", vim.diagnostic.open_float, "Show Diagnostic")

            -- Enable inlay hints for supported servers
            if client.server_capabilities.inlayHintProvider then
                vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
            end
            
            -- Disable formatting for servers where we prefer external formatters
            if client.name == "tsserver" or client.name == "lua_ls" then
                client.server_capabilities.documentFormattingProvider = false
            end
            
            -- Specific setup for ts_ls
            if client.name == "ts_ls" and 
               require("workspace-diagnostics") and 
               type(require("workspace-diagnostics").populate_workspace_diagnostics) == "function" then
                require("workspace-diagnostics").populate_workspace_diagnostics(client, bufnr)
            end
        end

        -- Setup each server
        for server, config in pairs(opts.servers) do
            -- Special handling for gopls to prevent multiple instances
            if server == "gopls" then
                -- For gopls, always use the topmost go.mod or .git directory
                config.root_dir = function(fname)
                    local util = require("lspconfig.util")
                    -- Find all go.mod files in parent directories
                    local go_mod = util.root_pattern("go.mod")(fname)
                    local git_root = util.root_pattern(".git")(fname)
                    
                    -- If we find a go.mod, check if there's a parent go.mod
                    if go_mod then
                        local parent_go_mod = util.root_pattern("go.mod")(vim.fn.fnamemodify(go_mod, ":h:h"))
                        if parent_go_mod then
                            return parent_go_mod
                        end
                        return go_mod
                    end
                    
                    -- Fall back to git root
                    return git_root
                end
                
                -- Ensure single workspace mode for gopls
                config.settings = vim.tbl_deep_extend("force", config.settings or {}, {
                    gopls = {
                        ["build.directoryFilters"] = { "-**/node_modules" },
                        ["formatting.gofumpt"] = true,
                        usePlaceholders = true,
                        completeUnimported = true,
                        staticcheck = true,
                        verboseOutput = false,
                    }
                })
            elseif server == "lua_ls" then
                -- Special handling for lua_ls to prevent multiple instances
                config.root_dir = function(fname)
                    local util = require("lspconfig.util")
                    -- For Neovim config files, always use the topmost .config/nvim directory
                    if fname:match("%.config/nvim") then
                        local nvim_config = fname:match("(.*/%.config/nvim)")
                        if nvim_config then
                            return nvim_config
                        end
                    end
                    
                    -- Otherwise use git root first
                    local git_root = util.root_pattern(".git")(fname)
                    if git_root then
                        return git_root
                    end
                    
                    -- Fall back to lua-specific patterns or current working directory
                    return util.root_pattern(".luarc.json", ".luarc.jsonc", ".luacheckrc", ".stylua.toml", "stylua.toml", "selene.toml", "selene.yml")(fname)
                        or vim.fn.getcwd()
                end
                
                -- Ensure single workspace mode for lua_ls
                config.single_file_support = false  -- Force workspace mode
                config.settings = vim.tbl_deep_extend("force", config.settings or {}, {
                    Lua = {
                        workspace = {
                            checkThirdParty = false,
                            maxPreload = 100000,
                            preloadFileSize = 10000,
                        },
                        telemetry = {
                            enable = false,
                        },
                    }
                })
            else
                -- Simple root directory detection for other servers
                config.root_dir = config.root_dir or lspconfig.util.root_pattern(
                    ".git", "package.json", "go.mod", "pyproject.toml", "Cargo.toml"
                )
            end
            
            -- Simple server setup
            lspconfig[server].setup(vim.tbl_deep_extend("force", {
                capabilities = capabilities,
                on_attach = on_attach
            }, config))
        end
        
        -- Simple diagnostics config
        vim.diagnostic.config({
            virtual_text = true,
            signs = true,
            underline = true,
            update_in_insert = false,
            severity_sort = true,
            float = { border = "rounded" }
        })
    end
}}

-- End of file
