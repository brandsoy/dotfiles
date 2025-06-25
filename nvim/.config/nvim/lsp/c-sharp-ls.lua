local blink = require("blink.cmp")

return {
  cmd = { "csharp-ls" }, -- Ensure this points to the correct executable
  filetypes = { "cs" },
  root_markers = { "*.sln", "*.csproj", ".git" },
  settings = {
    csharp = {
      enableAnalyzers = true,
      enableEditorConfigSupport = true,
      enableFormatting = true,
      formattingOptions = {
        tabSize = 4,
        insertSpaces = true,
      },
      suppressDotnetRestoreNotification = true,
      roslynExtensionsPath = "",
    },
  },
  capabilities = vim.tbl_deep_extend(
    "force",
    {},
    vim.lsp.protocol.make_client_capabilities(),
    blink.get_lsp_capabilities(),
    {
      textDocument = {
        completion = {
          completionItem = {
            snippetSupport = true,
          },
        },
      },
    }
  ),
}
