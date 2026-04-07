# Dotfiles

Personal configuration files for macOS and Linux (Arch/Debian).

## Structure

```
dotfiles/
├── shared/            # Cross-platform configs (stow packages)
│   ├── bin/           # Personal scripts
│   ├── config/        # Shared .config (nvim, alacritty, bat, etc.)
│   ├── git/           # Git configuration
│   ├── ssh/           # SSH keys
│   ├── tmux/          # Tmux configuration
│   └── zshrc/         # Zsh configuration
├── mac/               # macOS-specific configs
│   ├── config/        # aerospace, karabiner, raycast
│   └── Brewfile       # Homebrew packages
├── linux/             # Linux-specific configs
│   ├── config/        # hypr, waybar, keyd, swaync, gtk, etc.
│   ├── scripts/       # Linux scripts
│   └── Archfile       # Arch Linux packages
└── install.sh         # Auto-detecting installation script
```

## Quick Start

1.  Clone the repository:
    ```bash
    git clone <your-repo-url> ~/dotfiles
    cd ~/dotfiles
    ```

2.  Run the installation script:
    ```bash
    ./install.sh
    ```

This script will:
-   **Detect OS** (macOS, Arch, Debian, or generic Linux)
-   **Install dependencies** (stow, git, curl, zsh, etc.)
-   **Symlink shared configs** using GNU Stow
-   **Symlink OS-specific configs** based on detected OS
-   **Install packages**:
    -   macOS: Installs from `mac/Brewfile`
    -   Arch: Installs from `linux/Archfile` (pacman + AUR)
    -   Debian: Installs common tools via apt

## Selective Installation

```bash
# Install only shared configs
./install.sh shared

# Install only OS-specific configs
./install.sh mac
./install.sh linux

# Install a specific package
./install.sh config
./install.sh nvim

# Only install packages (no stow)
./install.sh packages
```

## Uninstalling

To remove symlinks:

```bash
# Shared packages
cd ~/dotfiles/shared && stow -D -t ~ <package>

# Mac packages
cd ~/dotfiles/mac && stow -D -t ~ config

# Linux packages
cd ~/dotfiles/linux && stow -D -t ~ config
```

## Hosts blocklist (macOS + Linux)

This repo includes a cross-platform hosts blocklist workflow:

- Script: `shared/bin/.local/bin/update-hosts-blocklist`
- Config: `shared/blocklists/.config/blocklists/`

Stow the shared packages, then run:

```bash
update-hosts-blocklist --dry-run
update-hosts-blocklist
```

Default source list includes:

- StevenBlack hosts
- AdAway hosts
- someonewhocares hosts

Tune behavior with:

- `~/.config/blocklists/allowlist.txt` (always allow)
- `~/.config/blocklists/denylist.txt` (always block)
- `~/.config/blocklists/false-positive-patterns.txt` (regex drop rules)

Set up weekly automatic updates:

```bash
# Install weekly scheduler (root-level, works on macOS + Linux)
hosts-blocklist-schedule install

# Check scheduler status
hosts-blocklist-schedule status

# Remove scheduler
hosts-blocklist-schedule uninstall
```

Notes:

- macOS uses a LaunchDaemon (`/Library/LaunchDaemons/com.dotfiles.hosts-blocklist.plist`) every Sunday at 04:17
- Linux uses a systemd timer (`com.dotfiles.hosts-blocklist.timer`) with default `OnCalendar=Sun *-*-* 04:17:00`
- Linux schedule can be overridden at install time, for example: `hosts-blocklist-schedule install --schedule 'Mon *-*-* 03:30:00'`

## Neovim LSP Setup (0.12+)

This Neovim config uses native LSP (`vim.lsp.config()` / `vim.lsp.enable()`) and does not use Mason.
Language servers and formatters are managed with `mise` and exposed through the mise shims on your PATH.

### Install tooling with mise

From this dotfiles repo:

```bash
mise install
```

Optional checks:

```bash
mise ls
for bin in lua-language-server stylua terraform-ls gopls golines gofumpt tsgo vscode-json-language-server yaml-language-server docker-langserver tailwindcss-language-server bash-language-server biome svelteserver prettierd prettier; do mise which "$bin"; done
```

### Svelte / SvelteKit

This config uses `svelte-language-server` for `.svelte` files and Tailwind LSP for class completion in Svelte components.

For best TypeScript/JavaScript support across `.svelte` and `.ts`/`.js` files inside SvelteKit projects, install and enable the TypeScript Svelte plugin per project:

```bash
npm i -D typescript-svelte-plugin svelte-check
```

Then add it to `tsconfig.json`/`jsconfig.json`:

```json
{
  "compilerOptions": {
    "plugins": [{ "name": "typescript-svelte-plugin" }]
  }
}
```

### Optional manual tools

- `postgres-language-server` and `roslyn` are environment-specific; install separately if needed.
- `pg_format` is used for SQL formatting in `conform.nvim` and may need a separate package-manager install.

### Notes

- `tsgo` comes from `@typescript/native-preview`.
- `jsonls` comes from `vscode-langservers-extracted`.
- `yamlls` comes from `yaml-language-server`.

### Quick checks

Inside Neovim:

- `:LspInfo` (open a `.ts` file and confirm `tsgo` is attached)
- `:checkhealth vim.lsp`
