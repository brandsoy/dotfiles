return {
  'mfussenegger/nvim-lint',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    local lint = require 'lint'

    lint.linters_by_ft = {
      markdown = { 'markdownlint' },
      -- go = { 'gofumpt', 'goimports' },
      javascript = { 'eslint_d' },
      typescript = { 'eslint_d' },
      javascriptreact = { 'eslint_d' },
      typescriptreact = { 'eslint_d' },
      json = { 'jsonlint' },
      yaml = { 'yamllint' },
      dockerfile = { 'hadolint' },
      python = { 'pylint' },
      sql = { 'sqlfluff' },
      toml = { 'taplo' },
    }

    -- Create autocommand to run linting on relevant events
    local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
      group = lint_augroup,
      callback = function()
        -- Check if the buffer is modifiable before linting
        if vim.opt_local.modifiable:get() then
          lint.try_lint()
        end
      end,
    })
  end,
}
