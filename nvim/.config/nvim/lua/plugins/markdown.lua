return {
  {
    'MeanderingProgrammer/render-markdown.nvim',
    config = function()
      require('render-markdown').setup({
        completions = { blink = { enabled = true } },
      })
    end,
  },
}
