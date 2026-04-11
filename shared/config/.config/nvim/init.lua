if vim.loader then vim.loader.enable() end
require("core")

require("plugins").setup()
-- i use mise to install node so disable the checkhealth for node
vim.g.node_host_prog = "/home/zhang/.local/bin/mise node-host"
