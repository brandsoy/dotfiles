return {
  {
    'MeanderingProgrammer/render-markdown.nvim',
    config = function()
      require('render-markdown').setup({
        completions = { blink = { enabled = true } },
      })
    end,
  },
  {
    --Markdown/preview for previewing markdown files in browser
    "iamcco/markdown-preview.nvim",
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
    ft = { "markdown" },
    cmd = { "MarkdownPreviewToggle", "MarkdownPreviewStop" },
  }
}
