return function()
  local ok_dap, dap = pcall(require, "dap")
  if not ok_dap then return end
  local ok_ui, dapui = pcall(require, "dapui")
  local ok_vt, vt = pcall(require, "nvim-dap-virtual-text")
  if ok_vt then vt.setup({}) end
  if ok_ui then dapui.setup({}) end

  -- Auto open/close UI
  if ok_ui then
    dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
    dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
    dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end
  end

  -- Go specific helper
  pcall(function() require("dap-go").setup() end)

  -- Basic debug keymaps
  local keymap = vim.keymap.set
  local opts = { noremap = true, silent = true }
  keymap("n", "<F5>", dap.continue, vim.tbl_extend("force", opts, { desc = "DAP: Continue" }))
  keymap("n", "<F9>", dap.toggle_breakpoint, vim.tbl_extend("force", opts, { desc = "DAP: Toggle Breakpoint" }))
  keymap("n", "<F10>", dap.step_over, vim.tbl_extend("force", opts, { desc = "DAP: Step Over" }))
  keymap("n", "<F11>", dap.step_into, vim.tbl_extend("force", opts, { desc = "DAP: Step Into" }))
  keymap("n", "<F12>", dap.step_out, vim.tbl_extend("force", opts, { desc = "DAP: Step Out" }))
  keymap("n", "<leader>db", dap.toggle_breakpoint, vim.tbl_extend("force", opts, { desc = "DAP: Toggle Breakpoint" }))
  keymap("n", "<leader>dc", dap.continue, vim.tbl_extend("force", opts, { desc = "DAP: Continue" }))
  keymap("n", "<leader>do", dap.step_over, vim.tbl_extend("force", opts, { desc = "DAP: Step Over" }))
  keymap("n", "<leader>di", dap.step_into, vim.tbl_extend("force", opts, { desc = "DAP: Step Into" }))
  keymap("n", "<leader>dO", dap.step_out, vim.tbl_extend("force", opts, { desc = "DAP: Step Out" }))
  keymap("n", "<leader>dr", dap.repl.toggle, vim.tbl_extend("force", opts, { desc = "DAP: Toggle REPL" }))
  keymap("n", "<leader>du", function() if ok_ui then dapui.toggle() end end, vim.tbl_extend("force", opts, { desc = "DAP: Toggle UI" }))
  keymap("n", "<leader>dt", function() require("dap-go").debug_test() end, vim.tbl_extend("force", opts, { desc = "DAP: Debug Go Test" }))
  keymap("n", "<leader>dT", function() require("dap-go").debug_last_test() end, vim.tbl_extend("force", opts, { desc = "DAP: Debug Last Go Test" }))
end
