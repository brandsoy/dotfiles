# Dotfiles

Personal configuration files for macOS and Linux (Arch/Debian).

## Structure

```
dotfiles/
├── roles/                      # Role-based stow packages
│   ├── config/                 # Shared ~/.config (nvim, terminals, theme-sync, etc.)
│   ├── tmux/                   # Tmux configuration
│   ├── zshrc/                  # Zsh configuration
│   ├── macos-config/           # macOS-specific configs
│   ├── linux-config/           # Linux-specific configs
│   ├── packages-macos/         # Brewfile
│   └── packages-arch/          # Archfile
├── hosts/                      # Per-host stow overrides (optional)
├── scripts/                    # Utility scripts (theme-sync, tmux helpers, etc.)
└── install.sh                  # Auto-detecting installation script
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

    Or from anywhere after your first install:

    ```bash
    dotfiles-install
    ```

This script will:
-   **Detect OS** (macOS, Arch, Debian, or generic Linux)
-   **Install dependencies** (stow, git, curl, zsh, etc.)
-   **Symlink role-based configs** using GNU Stow
-   **Symlink host overrides** from `hosts/<hostname>` when present
-   **Install packages**:
    -   macOS: Installs from `roles/packages-macos/Brewfile`
    -   Arch: Installs common tools via pacman (+ optional AUR tooling)
    -   Debian: Installs common tools via apt

## Selective Installation

```bash
# Install only role-based configs
./install.sh roles

# Install only host overrides
./install.sh hosts

# Install only OS-specific role
./install.sh mac
./install.sh linux

# Install a specific package
./install.sh config
./install.sh nvim

# Only install packages (no stow)
./install.sh packages

# Simple machine profiles (recommended)
dotfiles-install menu
# or directly:
dotfiles-install profile linux-server
dotfiles-install profile linux-desktop
dotfiles-install profile macbook

# Global command (same behavior)
dotfiles-install packages
```

## Theme management (theme-sync)

Themes are centralized in:

- `roles/config/.config/theme-sync/`
- `roles/config/.config/theme-sync/themes/<theme>/`

Each theme folder contains a `theme.env` mapping plus app-specific theme files (for example `alacritty.toml`, `kitty.conf`, `fzf.sh`, and optional overlays like `tmux.theme.conf`, `opencode.theme.json`, etc.).

The active theme is tracked in:

- `roles/config/.config/theme-sync/current`
- `roles/config/.config/theme-sync/current.env`
- `roles/config/.config/theme-sync/mode.env`

Apply and switch themes with:

```bash
theme-sync           # interactive TUI
theme-sync list
theme-sync current
theme-sync set <theme>
theme-sync apply

# Optional automatic light/dark switching
theme-sync mode-set light <theme>
theme-sync mode-set dark <theme>
theme-sync auto
theme-sync auto --watch 5
```

## AI model storage (Hugging Face, MLX, Ollama, Unsloth)

The model source of truth is `~/Models` (override with `AI_MODELS_HOME`). The
shell environment configures Hugging Face/Transformers and Ollama to use their
native subdirectories there:

```text
~/Models/
├── huggingface/   # HF hub cache; MLX loads HF models from here
├── ollama/        # Ollama's content-addressed GGUF blobs
├── mlx/           # optional local MLX exports
├── unsloth/       # optional training/import workspace
├── exports/       # intentional format conversions
└── inbox/         # downloads awaiting verification/import
```

After stowing the `bin` and `zshenv` roles, initialize it with:

```bash
ai-models init
ai-models status
ai-models link   # compatibility links for apps that ignore environment vars
```

Recommended workflow: download from Hugging Face with `huggingface-cli` or
Unsloth, then load the same HF snapshot directly with `mlx_lm.generate --model
<repo-or-local-path>`. Use Ollama for GGUF models and its own runtime. Do not
symlink Ollama blobs into the HF/MLX cache: Ollama stores GGUF layers with a
different manifest/content-addressing scheme, while MLX uses safetensors and
HF metadata. The framework directories share one disk location, not file
blobs. Unsloth Desktop may not inherit shell variables; configure its model
folder in the app or use the `~/Models/inbox`/`exports` folders explicitly.

For maximum performance on Apple Silicon, prefer MLX-native models (or a
verified MLX conversion), keep the model store on a local APFS SSD, and avoid
running inference from an iCloud/network-synced directory. Pin model revisions
and keep quantization/conversion metadata alongside exports.

## Tool Updates (Homebrew + mise)

Use the updater script to check/upgrade Homebrew and mise-managed tools:

```bash
# Check for available updates only
dotfiles-update --check

# Upgrade the tools declared in the Brewfile and mise config
dotfiles-update
```

Notes:

- `dotfiles-update --check` reports Homebrew and mise updates without running `brew update` or upgrading anything.
- `dotfiles-update` runs `brew update`, upgrades packages declared in `roles/packages-macos/Brewfile`, then runs `mise upgrade --yes`.
- Use `dotfiles-update --cleanup` to also run `brew cleanup -s` and `mise prune -y`.
- The Brewfile is a hand-maintained macOS manifest. Do **not** run `brew bundle dump --force` over it or auto-sync it after package commands.
- Homebrew owns macOS apps, fonts, and shared native utilities; mise owns runtimes and project tools; Mason owns Neovim-local servers and tools. Run `mise install` after changing `roles/config/.config/mise/config.toml`.
- If your repo is not at `~/dotfiles`, set `DOTFILES_DIR` before running, for example: `DOTFILES_DIR=~/src/dotfiles dotfiles-update`.

## Security checks

Run a quick secret scan before pushing:

```bash
./scripts/security-scan.sh
```

This uses `gitleaks` if installed.

## Uninstalling

To remove symlinks:

```bash
# Role packages
cd ~/dotfiles/roles && stow -D -t ~ <package>

# Host overrides (example)
cd ~/dotfiles/hosts/$(hostname -s) && stow -D -t ~ <package>
```

## Hosts blocklist (macOS + Linux)

This repo includes a cross-platform hosts blocklist workflow:

- Script: `roles/bin/.local/bin/update-hosts-blocklist`
- Config: `roles/blocklists/.config/blocklists/`

Stow the role packages, then run:

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

This Neovim config uses native LSP (`vim.lsp.config()` / `vim.lsp.enable()`) with Mason for editor-local language servers and tools. Runtimes and project-independent tools are managed with `mise` and exposed through the mise shims on your PATH.

### Install tooling with mise

From this dotfiles repo:

```bash
mise install
```

Optional checks:

```bash
mise ls
for bin in biome terraform templ tsc jinja-lsp; do mise which "$bin"; done
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

- Mason installs the configured language servers, formatters, and linters on startup.
- `biome`, `terraform`, `templ`, `tsc`, and `jinja-lsp` are managed by `mise` because they are also used outside Neovim.
- Run `:Mason` inside Neovim to inspect editor-local servers and tools.

### Notes

- The TypeScript server uses the native `tsc --lsp` implementation and requires TypeScript 7+.
- `jsonls` comes from `vscode-langservers-extracted`.
- `yamlls` comes from `yaml-language-server`.

### Quick checks

Inside Neovim:

- `:LspInfo` (open a `.ts` file and confirm `tsc` is attached)
- `:checkhealth vim.lsp`
