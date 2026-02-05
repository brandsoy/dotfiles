# New & Improved Keybindings Quick Reference

## 🆕 New LSP Keybindings

| Key | Action | Description |
|-----|--------|-------------|
| `<leader>lr` | Rename (inc-rename) | Interactive rename with live preview |
| `<leader>la` | Code actions (preview) | Code actions with fzf picker |
| `<leader>lR` | Restart LSP | Restart LSP servers for current buffer |
| `gl` | Line diagnostics | Quick one-handed diagnostic view |
| `<leader>lq` | Diagnostics → loclist | Send diagnostics to location list |
| `<leader>lQ` | Diagnostics → quickfix | Send diagnostics to quickfix list |
| `<leader>ldv` | Go to def (vsplit) | Open definition in vertical split |
| `<leader>ldh` | Go to def (split) | Open definition in horizontal split |

## 🔍 New Finder Keybindings

| Key | Action | Description |
|-----|--------|-------------|
| `<leader>/` | Buffer search | Fuzzy search within current buffer |

## ⌨️ New Completion Keybindings

| Key | Action | Description |
|-----|--------|-------------|
| `<C-space>` | Toggle docs | Show/hide completion documentation |
| `<C-e>` | Hide completion | Close completion menu |
| `<Tab>` | Confirm | Accept completion (existing) |
| `<C-n>/<C-p>` | Navigate | Next/previous item (existing) |

## 💡 Enhanced Features

### Interactive Rename (`<leader>lr`)
- Type new name and see live preview across all files
- Press `<Enter>` to confirm, `<Esc>` to cancel
- Shows count of occurrences

### Code Actions with Preview (`<leader>la`)
- Uses fzf-lua for better visual selection
- Shows preview of action result
- Fuzzy search through available actions

### Buffer Search (`<leader>/`)
- Fuzzy search lines in current buffer
- Much faster than regex search for finding text
- Jump directly to matching line

### Completion Docs
- Documentation now shows automatically after 200ms
- Toggle visibility with `<C-space>`
- Buffer words suggested (4+ characters only)

## 🎨 Visual Enhancements

### Which-key
- Automatically shows after 200ms when you start a keymap sequence
- Example: Press `<leader>` and wait to see all leader commands
- Press `<leader>l` and wait to see all LSP commands

### Fidget (LSP Progress)
- Shows LSP initialization progress in bottom-right
- Displays ongoing operations (indexing, formatting, etc.)
- Non-intrusive notifications

## 📊 Existing Keybindings (Unchanged)

### LSP Navigation
- `gd` - Go to definition
- `gD` - Go to declaration  
- `gi` - Go to implementation
- `gr` - Go to references
- `K` - Hover documentation

### LSP Actions (still work, but enhanced versions exist)
- `<leader>lf` - Format buffer
- `<leader>le` - Show diagnostics float
- `<leader>lt` - Toggle virtual text
- `<leader>lh` - Toggle inlay hints

### Diagnostics Navigation
- `[d` - Previous diagnostic
- `]d` - Next diagnostic

### File Explorer
- `<leader>e` - Toggle neo-tree
- `<leader>fe` - Focus neo-tree

### Finder (fzf-lua)
- `<leader>ff` - Find files
- `<leader>fg` - Live grep
- `<leader>fb` - Switch buffers
- `<leader>fr` - Recent files
- `<leader>fs` - Document symbols
- `<leader>fS` - Workspace symbols

### Buffer Management
- `<leader>bd` - Delete buffer
- `<leader>bo` - Delete other buffers
- `<leader>bn` - Next buffer
- `<leader>bp` - Previous buffer

### Window Management
- `<C-h/j/k/l>` - Navigate windows
- `<C-arrows>` - Resize windows
- `<leader>sv` - Vertical split
- `<leader>sh` - Horizontal split

### Git
- `<leader>gg` - LazyGit
- `<leader>gb` - Toggle blame
- `<leader>gd` - Git diff
- `]h` / `[h` - Next/prev hunk

## 🎯 Workflow Tips

### Renaming Workflow
1. Place cursor on symbol
2. Press `<leader>lr`
3. Type new name (see live preview)
4. Press `<Enter>` to apply

### Code Actions Workflow
1. Place cursor on code with actions
2. Press `<leader>la`
3. Use fuzzy search to find action
4. Press `<Enter>` to apply

### Quick Navigation
1. `gd` to go to definition
2. `<C-o>` to jump back
3. Or use `<leader>ldv` to open in split

### Diagnostics Workflow
1. `]d` to jump to next error
2. `gl` to see error details
3. `<leader>la` to see fix suggestions
4. Or `<leader>lq` to see all errors in loclist

### Buffer Search Workflow
1. Press `<leader>/`
2. Type fuzzy pattern
3. Navigate with `<C-j/k>`
4. Press `<Enter>` to jump

## 🔥 Pro Tips

1. **Which-key as learning tool**: Just press `<leader>` and wait - you'll see all available commands
2. **Fast error fixing**: `]d` → `gl` → `<leader>la` → select fix
3. **Quick refactoring**: `<leader>lr` for rename, `<leader>la` for extract/inline
4. **Buffer exploration**: `<leader>/` is faster than `/` for known text
5. **Split workflow**: Use `<leader>ldv` to compare definition with usage side-by-side
