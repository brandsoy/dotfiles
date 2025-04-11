return {
  {
    'MeanderingProgrammer/render-markdown.nvim',
    opts = {},
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' },
  },
  { 'folke/neodev.nvim', opts = {} },
  {
    'chentoast/marks.nvim',
    config = function()
      require('marks').setup {
        default_mappings = true,
      }
    end,
  },
}
