-- Central plugin spec using vim.pack.add (modern simple syntax)
return function()
  vim.pack.add({
    { src = "https://github.com/neovim/nvim-lspconfig" },
    { src = "https://github.com/mason-org/mason.nvim" },
    { src = "https://github.com/mason-org/mason-lspconfig.nvim" },
    { src = "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim" },
    { src = "https://github.com/rose-pine/neovim" },
    { src = "https://github.com/folke/which-key.nvim" },
    { src = "https://github.com/nvim-mini/mini.pick" },
    { src = "https://github.com/nvim-mini/mini.extra" },
    { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
    { src = "https://github.com/ray-x/go.nvim" },
    { src = "https://github.com/ray-x/guihua.lua" },
    { src = "https://github.com/mfussenegger/nvim-dap" },
    { src = "https://github.com/rcarriga/nvim-dap-ui" },
    { src = "https://github.com/nvim-neotest/nvim-nio" },
    { src = "https://github.com/theHamsta/nvim-dap-virtual-text" },
    { src = "https://github.com/leoluz/nvim-dap-go" },
  })
end
