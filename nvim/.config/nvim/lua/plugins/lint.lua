return {
  "mfussenegger/nvim-lint",
  optional = true,
  opts = {
    linters_by_ft = {
      ["markdownlint-cli2"] = {
        args = { "--config", "/Users/mattis/dotfiles/rules/.markdownlint-cli2.yaml", "--" },
      },
    },
  },
}
