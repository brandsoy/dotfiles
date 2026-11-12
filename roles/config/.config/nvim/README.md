# Neovim config

Personal Neovim setup focused on fast startup, practical defaults, and a modular Lua layout.

## Entry points
- `init.lua` loads `core` first, then `plugins`.
- `lua/core/` holds editor behavior, defaults, keymaps, theme, statusline, and autocmds.
- `lua/plugins/` holds plugin installation and per-plugin setup modules.
- `lua/config/` holds shared config helpers, mainly LSP-related logic.

## Highlights
- Native package setup via `vim.pack.add(...)`.
- Theme switching with persisted selection.
- LSP, formatting, linting, Treesitter, finder, git, AI, and markdown tooling.
- Obsidian-friendly markdown workflows, including clipboard image paste helpers.

## Notes
- Theme state is stored under Neovim state files, not in the repo.
- Some behavior is project-aware, such as formatter selection for Biome vs Prettier.
- This config prefers small focused modules over one large `init.lua`.
