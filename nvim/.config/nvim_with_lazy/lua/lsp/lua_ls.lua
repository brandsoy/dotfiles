local M = {}

M.settings = {
    Lua = {
        runtime = {
            version = "LuaJIT",
        },
        diagnostics = {
            globals = {"vim"},
        },
        workspace = {
            -- Make the server aware of Neovim runtime files
            library = vim.api.nvim_get_runtime_file("", true),
            checkThirdParty = false, -- Disable third-party check to prevent "press Enter" prompts
        },
        telemetry = {
            enable = false,
        },
        hint = {
            enable = true,
            setType = true,
        },
    },
}

-- Prevent workspace-diagnostics from running twice
M.on_attach = function(client, _)
    -- Only populate workspace diagnostics for TypeScript
    if client.name == "lua_ls" then
        -- Don't run workspace-diagnostics for Lua files
        client.server_capabilities.workspace = vim.tbl_deep_extend(
            "force",
            client.server_capabilities.workspace or {},
            { didChangeWatchedFiles = { dynamicRegistration = false } }
        )
    end
end

return M
