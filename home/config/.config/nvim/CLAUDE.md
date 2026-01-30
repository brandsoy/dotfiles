# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Plugin Management
```bash
# Open Neovim (lazy.nvim will auto-install on first run)
nvim

# Inside Neovim:
:Lazy          # Open lazy.nvim UI to manage plugins
:Lazy sync     # Update all plugins
:Lazy clean    # Remove unused plugins
```

### LSP and Language Tools
```bash
# Inside Neovim:
:Mason         # Open Mason UI to manage LSP servers, formatters, linters
:LspInfo       # Show active LSP servers and their status
:LspRestart    # Restart LSP servers for current buffer
```

### Testing Configuration
```bash
# Test Neovim config without affecting main installation
nvim --clean -u init.lua

# Check for errors in config
nvim --headless -c "lua print('Config loaded')" -c "qa"
```

### Blink.cmp Fuzzy Matcher (Rust Component)
If the Rust fuzzy matcher fails to build, manually compile it:
```bash
cd ~/.local/share/nvim/site/pack/core/opt/blink.cmp
cargo build --release
```

Required Rust setup:
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
rustup default nightly
rustup component add rust-src
```

## Architecture Overview

### Entry Point and Bootstrap
- **init.lua**: Entry point that enables bytecode cache, loads core config, and bootstraps lazy.nvim (auto-installs if missing)
- **lazy.nvim**: Plugin manager using lazy loading strategy - plugins load on events/commands/keymaps rather than at startup

### Directory Structure
```
lua/
├── core/                   # Core Neovim settings (no plugins)
│   ├── options.lua         # Editor options (indentation, search, UI)
│   ├── keymaps.lua         # Global keymaps (window nav, buffers, toggles)
│   └── autocmds.lua        # Autocommands (cursor position, yank highlight, large file detection)
├── config/
│   └── lsp/                # LSP configuration modules
│       ├── servers.lua     # LSP server definitions and setup (17+ servers)
│       ├── keymaps.lua     # LSP-specific keymaps (attached on LspAttach event)
│       ├── formatting.lua  # Conform.nvim (formatters) and nvim-lint setup
│       └── completion.lua  # Blink.cmp configuration
└── plugins/                # Plugin specifications (lazy.nvim format)
    ├── init.lua            # Plugin manifest (imports all specs)
    ├── ui.lua              # Theme, statusline, icons, notifications, which-key
    ├── editor.lua          # Oil.nvim, mini.nvim suite (pairs, move, ai, diff)
    ├── finder.lua          # fzf-lua for fuzzy finding
    ├── treesitter.lua      # Syntax highlighting and code intelligence
    ├── markdown.lua        # Markdown rendering
    ├── ai.lua              # Sidekick.nvim (AI assistance)
    ├── roslyn.lua          # C# language support
    └── lsp/init.lua        # LSP plugin specifications
```

### LSP System Architecture

**Deferred Activation Pattern**: LSP servers don't start immediately. They enable via FileType autocommands when you open relevant files, improving startup time.

**Configuration Flow**:
1. `config/lsp/servers.lua` defines server configurations with custom settings
2. Mason installs servers automatically if missing
3. FileType autocommand enables servers for matching filetypes
4. `config/lsp/keymaps.lua` attaches keymaps on LspAttach event
5. `config/lsp/formatting.lua` configures format-on-save with formatter chains

**Formatter Chain Strategy**: Uses condition-based formatters that check for config files (biome.json, .prettierrc, etc.) and fall back through chains (e.g., biome → prettierd → prettier for JS/TS).

**Key LSP Servers**:
- **JavaScript/TypeScript**: vtsls with inlay hints for parameters and types
- **Go**: gopls with comprehensive static analysis (nilness, shadow, unused detection)
- **Lua**: lua_ls with Neovim API support
- **JSON/YAML**: Schema store integration for validation
- **C#**: Roslyn via roslyn.nvim
- **Tailwind/Svelte/Vue/Prisma**: Specialized servers with custom configs

### Large File Handling
Autocommand in `core/autocmds.lua` detects files >500KB and disables:
- Syntax highlighting
- LSP
- Diagnostics
- Treesitter
This prevents performance issues with large files.

## Common Development Patterns

### Adding a New Language Server
1. Add server entry to `servers` table in `lua/config/lsp/servers.lua`:
```lua
lua_ls = {
  settings = {
    Lua = {
      diagnostics = { globals = { "vim" } },
      workspace = { library = vim.api.nvim_get_runtime_file("", true) },
    },
  },
},
```
2. Mason will auto-install on next Neovim start
3. FileType autocommand will activate it for relevant files
4. If custom keymaps needed, add to `lua/config/lsp/keymaps.lua` in LspAttach callback

### Adding a Formatter or Linter
In `lua/config/lsp/formatting.lua`:
```lua
formatters_by_ft = {
  javascript = { "biome", "prettierd", "prettier", stop_after_first = true },
  -- Add your filetype
}
```
Optionally add condition function to detect project setup:
```lua
formatters = {
  biome = {
    condition = function(self, ctx)
      return vim.fs.find({ "biome.json" }, { path = ctx.filename, upward = true })[1]
    end,
  },
}
```

### Adding a Plugin
1. Create new file in `lua/plugins/` (e.g., `myplugin.lua`):
```lua
return {
  {
    "author/plugin-name",
    lazy = true,
    event = "VeryLazy",  -- or cmd/keys/ft
    opts = {},
    config = function(_, opts)
      require("plugin-name").setup(opts)
    end,
  },
}
```
2. Add import to `lua/plugins/init.lua`:
```lua
{ import = "plugins.myplugin" }
```

### Module Pattern for Configuration
Configuration modules use consistent pattern:
```lua
local M = {}

function M.setup()
  -- Configuration logic
  local ok, plugin = pcall(require, "plugin-name")
  if not ok then
    vim.notify("plugin-name not available", vim.log.levels.WARN)
    return
  end
  -- Setup code
end

return M
```

### Keymap Helper Pattern
Use local helper function for consistent keymap options:
```lua
local function map(mode, lhs, rhs, desc, opts)
  local options = { silent = true, desc = desc }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end
```

## Keymap Organization

Leader key is `<Space>`.

### Keymap Prefixes
- `<leader><leader>` - Toggle last buffer
- `<leader>b` - Buffer management (next/prev/delete/close others)
- `<leader>f` - Finder/search (files, grep, buffers, symbols, diagnostics via fzf-lua)
- `<leader>l` - LSP commands (definition, rename, code actions, format, diagnostics)
- `<leader>m` - Markdown operations (todo, checkbox, link, wrap)
- `<leader>q` - Quit commands
- `<leader>s` - Split/window management
- `<leader>t` - Toggle UI elements (relative numbers, cursorline, wrap, spell)
- `<leader>w` - Write/save commands
- `<leader>a` - AI/Sidekick commands

### Important Global Keymaps
- `<C-h/j/k/l>` - Navigate between windows (works in normal and terminal mode)
- `<C-Up/Down/Left/Right>` - Resize windows
- `<A-j/k>` - Move lines/blocks up/down (in normal and visual mode)
- `jk` - Exit insert mode (faster than ESC)
- `n/N` - Search navigation (centered with zzzv)
- `<C-d/u>` - Page scroll (centered)

### LSP Keymaps (attached on LspAttach)
- `gd` - Go to definition
- `gD` - Go to declaration
- `gi` - Go to implementation
- `gr` - Go to references
- `K` - Hover documentation
- `<leader>lr` - Rename symbol
- `<leader>la` - Code actions
- `<leader>lf` - Format buffer
- `[d` / `]d` - Previous/next diagnostic
- `<leader>le` - Show line diagnostics
- `<leader>lt` - Toggle virtual text diagnostics
- `<leader>ll` - Enable all LSP servers (manual trigger)

## Special Configuration Notes

### Deprecation Handling
`core/init.lua` re-implements `vim.tbl_flatten` to silence deprecation warnings in Neovim 0.11+.

### Clipboard Integration
Configuration uses system clipboard (`vim.opt.clipboard = "unnamedplus"`).

### Persistent Undo
Undo history persists across sessions (`vim.opt.undofile = true`).

### Grep Integration
Uses ripgrep with custom format for better quickfix integration:
```lua
vim.opt.grepprg = "rg --vimgrep --no-heading --smart-case"
```

### Cursor Behavior
- Block cursor in all modes
- Blinking enabled in insert mode
- Cursorline only shows in active window (via autocommand)

### Folding Strategy
Uses Treesitter-based folding with level 99 (keeps everything unfolded by default):
```lua
vim.opt.foldlevel = 99
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
```
