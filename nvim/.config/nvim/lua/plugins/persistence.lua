return {
  'folke/persistence.nvim',
  event = 'BufReadPre',
  opts = {
    options = { 'buffers', 'curdir', 'tabpages', 'winsize', 'localoptions' },
  },
  keys = {
    { "<leader>qs", function() require("persistence").load() end, desc = "[Q]uit: Restore [S]ession" },
    { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "[Q]uit: Restore [L]ast Session" },
    { "<leader>qd", function() require("persistence").stop() end, desc = "[Q]uit: [D]on't Save Current Session" },
  },
}
