# Neovim Configuration

A modern and minimal Neovim setup focused on productivity and clean design, using the lazy.nvim plugin manager.

## Overview

This Neovim configuration provides a full-featured development environment with:

- 🌈 Beautiful Kanagawa colorscheme with transparent background
- 🔍 Powerful fuzzy finding with FZF-Lua
- 🧠 Feature-rich LSP integration with auto-completion
- 📊 Minimal status line with mini.statusline
- 📁 Easy file navigation with Oil
- 🔍 Advanced treesitter syntax highlighting and text objects

## Structure

The configuration is organized as follows:

```
init.lua                # Entry point that loads the lazy configuration
lua/
  config/               # Core configuration files
    keymaps.lua         # Custom keybindings
    lazy.lua            # Plugin manager setup
    options.lua         # Neovim options and settings
  plugins/              # Plugin configurations
    blink-cmp.lua       # Completion engine
    conform.lua         # Formatting engine
    fzf-lua.lua         # Fuzzy finder
    kanagawa.lua        # Colorscheme
    lsp.lua             # Language server configuration
    ...                 # Additional plugin configurations
```

## Key Features

### Plugin Management

Uses [lazy.nvim](https://github.com/folke/lazy.nvim) for efficient plugin management with lazy-loading.

### Editor Configuration

- Modern defaults with relative line numbering and cursor line highlighting
- 4-space indentation with smart tabs and auto-indentation
- Case-insensitive search with smartcase
- Persistant undo history
- Subtle whitespace visualization

### Theme and UI

- [Kanagawa](https://github.com/rebelot/kanagawa.nvim) colorscheme with transparent background
- Custom Markdown syntax highlighting
- [mini.statusline](https://github.com/echasnovski/mini.statusline) for a minimal status bar

### Fuzzy Finding and Navigation

- [FZF-Lua](https://github.com/ibhagwan/fzf-lua) for lightning-fast fuzzy finding with keymaps:
  - `<leader>ff` - Find files in project directory
  - `<leader>fg` - Live grep in project directory
  - `<leader>fc` - Find in Neovim configuration
  - `<leader><leader>` - Find existing buffers
  - `<leader>/` - Live grep current buffer
  - Plus many more file, help and diagnostic search options
- [Oil](https://github.com/stevearc/oil.nvim) for file browsing with `-` to open parent directory

### Code Intelligence

- Full LSP integration through [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)
- Automatic LSP server installation with [Mason](https://github.com/williamboman/mason.nvim)
- Key LSP features:
  - `gd` - Go to definition
  - `gr` - Find references
  - `gI` - Go to implementation
  - `<leader>D` - Type definition
  - `<leader>cr` - Rename symbol
  - `<leader>ca` - Code actions

### Auto-completion

- [blink.cmp](https://github.com/saghen/blink.cmp) for smart, context-aware completion
- Snippet support via friendly-snippets
- Emoji completion for Markdown and Git commits
- Documentation pop-up on demand

### Code Formatting

- [conform.nvim](https://github.com/stevearc/conform.nvim) for code formatting
- Format current file with `<leader>cf`

### Syntax and Text Objects

- Enhanced syntax highlighting with [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
- Advanced text objects with [nvim-treesitter-textobjects](https://github.com/nvim-treesitter/nvim-treesitter-textobjects)

## Leader Keys

- Leader: `,` (comma)
- LocalLeader: `\` (backslash)

## Additional Tools

- Automatic indentation detection with [guess-indent](https://github.com/NMAC427/guess-indent.nvim)
- Enhanced diagnostics display with custom icons and formatting
- Project management with [project.nvim](https://github.com/ahmedkhalf/project.nvim)
- Interactive key binding display with [which-key](https://github.com/folke/which-key.nvim)

## Getting Started

1. Make sure Neovim 0.9.0 or later is installed
2. Place these configuration files in your Neovim config directory (~/.config/nvim/)
3. Start Neovim - lazy.nvim will automatically install all plugins on first run