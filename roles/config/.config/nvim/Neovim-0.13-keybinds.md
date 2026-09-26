# Neovim 0.13: useful new keybinds

These apply to the installed `nvim-nightly` build (`v0.13.0-dev`).

## Multicursor editing

| Key | Action |
|---|---|
| `Q` | Toggle a multicursor at the cursor |
| `[count]Q` | Add a cursor at every match of the last search |
| Visual `Q` | Add a cursor on every selected line |
| `<C-LeftMouse>` | Toggle a multicursor at the clicked position |
| `q=` | Toggle follow mode: replay motions independently at each cursor |
| `1q=` / `2q=` | Force follow mode on / off |
| `<C-L>` | Clear multicursors in the current buffer |
| `gQ` | Restore the previous multicursors |
| `[C` / `]C` | Jump to the previous / next multicursor |
| `g<C-A>` | Insert ascending numbers at multicursors; a count sets the start |

## Tree-sitter selection

Use these in Visual mode:

| Key | Action |
|---|---|
| `]N` / `[N` | Expand the selection to the next / previous Tree-sitter node |
| `al` | Select the whole buffer |
| `il` | Select the current line without surrounding whitespace |

## Restart and command-line changes

| Key | Action |
|---|---|
| `ZR` | Restart Neovim and restore the current session |
| `[count]ZR` | Restart without restoring the session (`1`–`8`); `9ZR` also skips change checks |
| `[count]q:` | Open Ex mode when a count is supplied; otherwise open the command-line window |

> **Compatibility note:** `Q` is now multicursor instead of Ex mode, and `gQ` now restores multicursors. Use `q:` (with a count) for Ex mode.
