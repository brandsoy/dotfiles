return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    notify_on_error = false,
    format_on_save = function(bufnr)
      if vim.bo[bufnr].buftype ~= "" or vim.api.nvim_buf_line_count(bufnr) > 10000 then
        return
      end
      return { lsp_fallback = true, timeout_ms = 1500 }
    end,
    formatters_by_ft = {
      lua = { "stylua" },
      python = { "ruff_format" }, -- or { "black" }
      javascript = { "biome", "prettierd", "prettier" },
      typescript = { "biome", "prettierd", "prettier" },
      javascriptreact = { "biome", "prettierd", "prettier" },
      typescriptreact = { "biome", "prettierd", "prettier" },
      json = { "biome", "jq" },
      yaml = { "prettierd", "prettier" },
      markdown = { "prettierd", "prettier" },
      sh = { "shfmt" },
      go = {},   -- let gopls format
      rust = {}, -- let rust-analyzer/rustfmt format
    },
  },
}
