return function()
  require("which-key").setup()
  local wk = require("which-key")
  wk.add({
    { "<leader>s", group = "Symbols" },
    { "<leader>l", group = "LSP" },
    { "<leader>lq", desc = "Diagnostics to Location List" },
    { "<leader>d", group = "Debug" },
    { "<F5>", desc = "DAP: Continue" },
    { "<F9>", desc = "DAP: Toggle Breakpoint" },
    { "<F10>", desc = "DAP: Step Over" },
    { "<F11>", desc = "DAP: Step Into" },
    { "<F12>", desc = "DAP: Step Out" },
    { "<leader>db", desc = "DAP: Toggle Breakpoint" },
    { "<leader>dc", desc = "DAP: Continue" },
    { "<leader>do", desc = "DAP: Step Over" },
    { "<leader>di", desc = "DAP: Step Into" },
    { "<leader>dO", desc = "DAP: Step Out" },
    { "<leader>dr", desc = "DAP: Toggle REPL" },
    { "<leader>du", desc = "DAP: Toggle UI" },
    { "<leader>dt", desc = "DAP: Debug Go Test" },
    { "<leader>dT", desc = "DAP: Debug Last Go Test" },
  })
end
