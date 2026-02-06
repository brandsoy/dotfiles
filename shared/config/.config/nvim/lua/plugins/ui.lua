return {
  -- Colorschemes: Uncomment the vim.cmd.colorscheme line in ONE theme to activate it
  {
    "oskarnurm/koda.nvim",
    lazy = true,
    cmd = "Colorscheme",
    priority = 1000,
    config = function()
      -- require("koda").setup({ transparent = true })
      -- vim.cmd("colorscheme koda")
    end,
  },
  {
    "folke/tokyonight.nvim",
    lazy = true,
    cmd = "Colorscheme",
    priority = 1000,
    config = function()
      -- vim.cmd.colorscheme("tokyonight-night")
      -- Other variants: tokyonight-storm, tokyonight-moon, tokyonight-day
    end,
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = true,
    cmd = "Colorscheme",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "auto",
        background = { light = "latte", dark = "mocha" },
        transparent_background = true,
        integrations = {
          blink_cmp = true,
          fzf = true,
          mason = true,
          markdown = true,
          mini = { enabled = true },
          native_lsp = { enabled = true },
          treesitter = true,
          which_key = true,
        },
      })
      -- vim.cmd.colorscheme("catppuccin")
    end,
  },
  {
    "projekt0n/github-nvim-theme",
    name = "github-theme",
    lazy = true, -- Active theme loads immediately
    priority = 1000,
    config = function()
      require("github-theme").setup({})
      -- vim.cmd.colorscheme("github_dark_tritanopia")
      -- Other variants: github_dark_default,github_dark_tritanopia, github_light, github_dark_high_contrast
    end,
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = true,
    cmd = "Colorscheme",
    priority = 1000,
    config = function()
      -- vim.cmd.colorscheme("rose-pine")
      -- Other variants: rose-pine-main, rose-pine-moon, rose-pine-dawn
    end,
  },

  {
    "p00f/alabaster.nvim",
    name = "alabaster",
    lazy = true,
    cmd = "Colorscheme",
    priority = 1000,
    config = function()
      -- vim.cmd.colorscheme("alabaster")
    end,
  },

  {
    "nvim-mini/mini.statusline",
    event = "VeryLazy",
    config = function()
      require("mini.statusline").setup()
    end,
  },

  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    opts = {
      notification = {
        window = { winblend = 0 },
      },
    },
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "helix",
      delay = 200,               -- Match updatetime
      icons = { mappings = false }, -- Less visual clutter
    },
  },
}
