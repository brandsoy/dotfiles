return function()
  -- Load LSP server configurations
  require("lsp.lua")()
  require("lsp.go")()
  require("lsp.typespec")()
end