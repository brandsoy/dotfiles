return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
        local configs = require("nvim-treesitter.configs")

        configs.setup({
            -- Supported languages : https://github.com/nvim-treesitter/nvim-treesitter?tab=readme-ov-file#supported-languages
            ensure_installed = {
                "bash",
                "c_sharp",
                "csv",
                "dockerfile",
                "go",
                "gomod",
                "gosum",
                "gowork",
                "json",
                "lua",
                "python",
                "sql",
                "toml",
                "typescript",
                "vim",
                "vimdoc",
                "query",
                "javascript",
                "html",
            },
            sync_install = false,
            highlight = { enable = true },
            indent = { enable = true },

            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "<Enter>", -- set to `false` to disable one of the mappings
                    node_incremental = "<Enter>",
                    scope_incremental = false,
                    node_decremental = "<Backspace>",
                },
            },
        })
    end,
}
