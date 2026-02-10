return {
  {
    "obsidian-nvim/obsidian.nvim",
    version = "*",
    ft = "markdown",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      workspaces = {
        {
          name = "Work",
          path = "~/Documents/Work",
        },
      },

      -- Completion using blink.cmp
      completion = {
        nvim_cmp = false,
      },

      -- Use fzf-lua for picker
      picker = {
        name = "fzf-lua",
      },

      -- Daily notes configuration
      daily_notes = {
        folder = "daily",
        date_format = "%Y-%m-%d",
        alias_format = "%B %-d, %Y",
      },

      -- Templates configuration
      templates = {
        folder = "templates",
        date_format = "%Y-%m-%d",
        time_format = "%H:%M",
      },

      -- Note ID generation
      note_id_func = function(title)
        -- Use title if provided, otherwise use timestamp
        if title ~= nil then
          return title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
        else
          return tostring(os.time())
        end
      end,

      -- Disable legacy commands
      legacy_commands = false,

      -- Checkbox cycling order
      checkbox = {
        order = { " ", "x", ">", "~", "!" },
      },

      -- UI options
      ui = {
        enable = true,
        update_debounce = 200,
        max_file_length = 5000,
        bullets = { char = "•", hl_group = "ObsidianBullet" },
        external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" },
        reference_text = { hl_group = "ObsidianRefText" },
        highlight_text = { hl_group = "ObsidianHighlightText" },
        tags = { hl_group = "ObsidianTag" },
        block_ids = { hl_group = "ObsidianBlockID" },
        hl_groups = {
          ObsidianTodo = { bold = true, fg = "#f78c6c" },
          ObsidianDone = { bold = true, fg = "#89ddff" },
          ObsidianRightArrow = { bold = true, fg = "#f78c6c" },
          ObsidianTilde = { bold = true, fg = "#ff5370" },
          ObsidianImportant = { bold = true, fg = "#d73128" },
          ObsidianBullet = { bold = true, fg = "#89ddff" },
          ObsidianRefText = { underline = true, fg = "#c792ea" },
          ObsidianExtLinkIcon = { fg = "#c792ea" },
          ObsidianTag = { italic = true, fg = "#89ddff" },
          ObsidianBlockID = { italic = true, fg = "#89ddff" },
          ObsidianHighlightText = { bg = "#75662e" },
        },
      },

      -- Attachments (images, etc.)
      attachments = {
        folder = "attachments",
      },
    },
    config = function(_, opts)
      require("obsidian").setup(opts)

      -- Keymaps
      local function map(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc, buffer = true })
      end

      -- Only set keymaps in markdown files
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function()
          -- Note creation and navigation
          map("n", "<leader>on", "<cmd>Obsidian new<cr>", "New note")
          map("n", "<leader>oo", "<cmd>Obsidian quick_switch<cr>", "Quick switch")
          map("n", "<leader>os", "<cmd>Obsidian search<cr>", "Search notes")
          map("n", "<leader>of", "<cmd>Obsidian follow_link<cr>", "Follow link")
          map("n", "<leader>oO", "<cmd>Obsidian open<cr>", "Open in Obsidian app")

          -- Daily notes
          map("n", "<leader>od", "<cmd>Obsidian today<cr>", "Today's note")
          map("n", "<leader>oD", "<cmd>Obsidian dailies<cr>", "Browse dailies")
          map("n", "<leader>oy", "<cmd>Obsidian yesterday<cr>", "Yesterday's note")
          map("n", "<leader>om", "<cmd>Obsidian tomorrow<cr>", "Tomorrow's note")

          -- Templates and structure
          map("n", "<leader>ot", "<cmd>Obsidian template<cr>", "Insert template")
          map("n", "<leader>oT", "<cmd>Obsidian toc<cr>", "Table of contents")

          -- Links and references
          map("n", "<leader>ob", "<cmd>Obsidian backlinks<cr>", "Show backlinks")
          map("n", "<leader>ol", "<cmd>Obsidian links<cr>", "Show links")
          map("n", "<leader>og", "<cmd>Obsidian tags<cr>", "Search tags")

          -- Utilities
          map("n", "<leader>op", "<cmd>Obsidian paste_img<cr>", "Paste image")
          map("n", "<leader>or", "<cmd>Obsidian rename<cr>", "Rename note")
          map("n", "<leader>oc", "<cmd>Obsidian toggle_checkbox<cr>", "Toggle checkbox")
          map("n", "<leader>ow", "<cmd>Obsidian workspace<cr>", "Switch workspace")

          -- Visual mode mappings
          map("v", "<leader>ol", "<cmd>Obsidian link<cr>", "Link to note")
          map("v", "<leader>on", "<cmd>Obsidian link_new<cr>", "Link to new note")
          map("v", "<leader>oe", "<cmd>Obsidian extract_note<cr>", "Extract to new note")

          -- Smart action on Enter
          map("n", "<cr>", function()
            return require("obsidian").util.smart_action()
          end, "Obsidian smart action")

          -- Link navigation
          map("n", "[o", function()
            return require("obsidian").util.nav_link("prev")
          end, "Previous link")
          map("n", "]o", function()
            return require("obsidian").util.nav_link("next")
          end, "Next link")
        end,
      })
    end,
  },
}
