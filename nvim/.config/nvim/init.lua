-- Base settings
require("settings")

-- Plugins (install/enable with vim.pack.add)
require("plugins")()

-- Plugin configs
require("plugins.which-key")()
require("plugins.mini")()
require("plugins.treesitter")()
require("plugins.go")()
require("plugins.dap")()

-- LSP setup
require("lsp.mason")()
require("lsp.servers")()
require("lsp.keymaps")()

-- Appearance
require("colors")()
