# Dotfiles agent guide

## Working rules

- Inspect the relevant configuration and its callers before editing.
- Preserve unrelated changes, including untracked files and submodule state.
- Make the smallest change that solves the request. Follow nearby conventions.
- Do not commit unless asked. Never push to a remote.
- Run `./scripts/maintenance/check.sh` before a requested commit. Report any failures.
- Do not read, print, copy, or commit credentials or private runtime data unless the task requires it.
- Do not run package installation, updates, `sudo`, service changes, or destructive cleanup without the user's approval.
- Treat live configuration changes as side effects. Ask before running installers, relinking files, or applying a theme to the user's home.

## Repository map

- `roles/config/.config/`: shared application configuration, including Neovim, terminals, Zsh, and theme-switcher.
- `roles/zshenv/`, `roles/git/`, `roles/tmux/`, `roles/bin/`: shared home files and commands.
- `roles/macos-config/` and `roles/linux-config/`: platform-specific configuration.
- `roles/agents/.agents/`: shared agent skills. The installer links this directory as one `~/.agents` symlink.
- `roles/packages-macos/Brewfile` and `roles/packages-redhat/Redhatfile`: macOS and Fedora package manifests.
- `scripts/`: implementation scripts. `tests/`: offline regression tests.
- `IMPROVEMENTS.md`: backlog and convention ledger. Move completed backlog items to Done with a date.

macOS is the primary platform. Fedora is supported. Do not assume other Linux distributions are supported.

## Configuration and deployment

- Edit repository source files, not generated files or files in the user's home directory.
- Stow creates file-level links under `~/.config`. New files may require `./install.sh links <role>` to become available.
- `./install.sh links` changes live symlinks. It does not install packages or plugins.
- `./install.sh packages`, `plugins`, `binaries`, and `all` change the host. Some require network access.
- Keep credentials and runtime state out of the repository. See `.gitignore` and `README.md`.
- Do not edit vendored submodule contents as part of unrelated work. Update a submodule pin only when requested.
- Keep the Brewfile hand-maintained. Do not run `brew bundle dump --force`. Run `./install.sh packages-sync` only when requested.
- Homebrew owns macOS apps and native tools. mise owns runtimes. Mason owns Neovim-local tools.
- Keep bootstrap and macOS shell scripts compatible with the system Bash 3.2. Avoid associative arrays and `mapfile` there.

## Subsystems

- **Neovim:** `roles/config/.config/nvim/` uses native `vim.pack` and modular Lua. See its `README.md` before changing plugins or theme behavior.
- **Themes:** Edit `roles/config/.config/theme-switcher/themes/*.json` and shared templates. Do not edit generated theme assets. Read `roles/config/.config/theme-switcher/README.md` for mappings and deployment.
- **tmux:** Configuration is in `roles/tmux/.tmux.conf`. Picker scripts are in `scripts/tmux/`.
- **Go tools:** `scripts/ai/` and `scripts/theme/tui/` are separate Go modules. The theme switcher prefers an installed binary and otherwise uses `go run`.
- **Shell:** Preserve startup behavior on both macOS and Fedora. Do not add network operations to shell startup.

## Verification

Run the smallest relevant checks during development. Run the full check before a requested commit:

```sh
./scripts/maintenance/check.sh
```

The full check runs shell formatting and linting, available Go checks, a secret scan, and regression tests. Some tools are optional. Go may download modules if they are not cached. For focused checks:

```sh
python3 tests/test_dotfiles.py
python3 tests/test_monitor_workspace_setup.py
python3 scripts/bookmarks/test_sync.py
(cd scripts/theme/tui && go test ./...)
(cd scripts/ai && go test ./...)
```

Tests use temporary homes and mock integrations. Report checks that fail or cannot run. Do not claim that an unrun check passed.
