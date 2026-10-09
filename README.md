# Dotfiles

Personal configuration for macOS first, plus a Fedora desktop.
Arch, Debian, RHEL, and the Linux server profile are no longer supported.

## Structure

- `roles/config/`: shared `~/.config`, including Zsh, Neovim, and terminals
- `roles/config/.pi/agent/`: versioned Pi notes and themes; credentials and runtime state stay machine-local
- `roles/zshenv/`, `roles/git/`, `roles/tmux/`, `roles/bin/`: shared home files and commands
- `roles/agents/.agents/`: shared agent skills; installed as one `~/.agents` symlink
- `roles/macos-config/`, `roles/linux-config/`: platform configs and Git credential helpers
- `roles/packages-macos/Brewfile` and `roles/packages-redhat/Redhatfile`: package manifests (the Redhatfile is Fedora-only)
- `scripts/`: helpers grouped by purpose — `maintenance/` (checks, security scan,
  tool updates), `theme/` (theme-sync pipeline), `ai/` (AI tooling inventory
  TUI; run with `go run ./scripts/ai`), `macos/`, `tmux/`, `herdr/`

## Installation

Clone into `~/dotfiles`, then choose an explicit action:

```bash
./install.sh                    # help only; no changes
./install.sh links              # shared + detected platform
./install.sh links config tmux  # selected roles only
./install.sh packages           # package installation only
./install.sh packages-sync     # reconcile the Brewfile with installed Homebrew packages
./install.sh plugins            # pinned submodules, TPM, and Herdr plugins; network access
./install.sh all                # packages, plugins, then links
```

After installation, `dotfiles-install` exposes the same commands. Set
`DOTFILES_DIR` if the repository is somewhere other than `~/dotfiles`.

- Linking never installs packages, downloads plugins, or changes your login shell.
- `plugins` installs Herdr plugins from `roles/config/.config/herdr/plugins.txt`, applies maintained patches, preserves legacy plugin directories without Git metadata under `${XDG_STATE_HOME:-~/.local/state}/dotfiles/plugin-backup.*`, and initializes submodules. It prints each backup location; existing Git checkouts are left in place.
- Stow uses file-level links for config roles, with explicit ignores for runtime files and credentials. Agent skills are a single `~/.agents` symlink.
- macOS bootstraps Homebrew if needed, then installs the Brewfile.
- `packages-sync` reconciles the Brewfile with the machine: entries for uninstalled packages are removed, and untracked top-level formulae (`brew leaves`) and casks are appended for review. Packages listed in `roles/packages-macos/untracked.txt` are skipped, so deliberate exclusions stick. It never runs automatically.
- Fedora keeps your existing desktop/session. Package availability depends on Fedora version and enabled repositories; inspect DNF's skipped-package warnings. Hyprland configs remain available, but Fedora does not install a complete Hyprland desktop automatically.
- No installer command runs `chsh`. If desired, choose a Zsh path listed in `/etc/shells` and change it yourself.
- Existing conflicting files are not adopted or overwritten by Stow; back them up before resolving conflicts.

Then open a new login shell and install mise tools:

```bash
mise install
```

Homebrew owns macOS applications and native CLI utilities. Native Linux package
managers own desktop/system utilities; mise owns runtimes and, on Linux, lazygit
and lazydocker to avoid distro-specific binary-download scripts. Mason owns
Neovim-local tooling. Zsh plugins are pinned submodules, loaded without network
access during shell startup. Use `git submodule update --remote <path>` only when
you deliberately want to update a pin, then commit the changed gitlink.

Git identity roots are `~/Developer/git/work/` and `~/Developer/git/personal/`.
GitHub credentials use `gh auth login`; other hosts use macOS Keychain or Linux's
in-memory credential cache.

## Theme management (theme-sync)

Themes are centralized in:

- `roles/config/.config/theme-sync/`
- `roles/config/.config/theme-sync/themes/<theme>.json`: one palette, native app mappings, and template bindings per theme
- `roles/config/.config/theme-sync/templates/<app>/`: shared app syntax and layout variants

`theme-sync set` and `apply` render app files on demand using Python 3.9+ (standard
library only). Edit colors in the JSON definition, not in generated app files.
All 16 bundled themes are migrated; native Neovim/Bat themes stay native.
See [theme-sync documentation](roles/config/.config/theme-sync/README.md) for the
schema, app overrides, and legacy personal-theme compatibility.

Active theme state is local, under `${XDG_STATE_HOME:-~/.local/state}/theme-sync/`:
`current`, `current.env`, `mode.env`, and rendered assets in `generated/<theme>/`.
Legacy state under `~/.config/theme-sync/`
is imported once, without overwriting newer choices. Hostname-specific theme overrides
are no longer applied. Generated theme files are ignored by both Git and Stow.

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

On a fresh install, choose a theme with `theme-sync set <theme>`. On an existing
install, run `./install.sh links config` to link the new JSON definitions and
templates, then `theme-sync apply` to regenerate the includes. Open a new shell
to load the updated Bat, FZF, Starship, and lazygit environment.

VS Code settings are **never rewritten**. Set these in VS Code's Settings UI:

- `window.autoDetectColorScheme`: enabled
- `workbench.preferredLightColorTheme`: your light theme
- `workbench.preferredDarkColorTheme`: your dark theme

Before pulling this cleanup onto another machine, preserve its old `current` and
`mode.env` files in `~/.local/state/theme-sync/` if you want to retain its choices.
The generated `current.env` will be rebuilt; do not copy machine-specific exports.

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
- Native Linux packages are updated separately with DNF; `dotfiles-update` handles Homebrew and mise only.
- The Brewfile is a hand-maintained macOS manifest. Do **not** run `brew bundle dump --force` over it or auto-sync it after package commands. Use `./install.sh packages-sync` when you want to reconcile it with installed packages.
- Homebrew owns macOS apps, fonts, and shared native utilities; mise owns runtimes and project tools; Mason owns Neovim-local servers and tools. Run `mise install` after changing `roles/config/.config/mise/config.toml`.
- If your repo is not at `~/dotfiles`, set `DOTFILES_DIR` before running, for example: `DOTFILES_DIR=~/src/dotfiles dotfiles-update`.

## Security checks

Run a quick secret scan before pushing:

```bash
./scripts/maintenance/security-scan.sh
```

This uses `gitleaks` if installed.

Run all offline checks in one command — formatting (shfmt), lint (shellcheck),
the gitleaks secret scan (when installed), and tests (Bash, Zsh, Git, Stow,
and Python 3 required):

```bash
./scripts/maintenance/check.sh
```

Tests use disposable homes/repositories and mock package managers and desktop integrations.

## Uninstalling

To remove Stow-managed symlinks:

```bash
cd ~/dotfiles
stow --dir=roles --delete --target="$HOME" <role>
```

`~/.agents` is intentionally a single direct link, not a Stow package. Remove
it separately only after checking that it points to `roles/agents/.agents`.

## Blocklists

`roles/blocklists/` retains source, allowlist, and denylist data only. This repository
does not currently include a hosts-file updater or scheduler.

## Neovim LSP Setup (0.12+)

This Neovim config uses native LSP (`vim.lsp.config()` / `vim.lsp.enable()`) with Mason for editor-local language servers and tools. Shared shell tools are managed with `mise` and exposed through the mise shims on your PATH; project runtimes and build tools should be declared by each project.

### Install tooling with mise

From this dotfiles repo:

```bash
mise install
```

Check the globally configured tools:

```bash
mise ls
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
- Project tools such as `biome`, `terraform`, `templ`, `tsc`, and `jinja-lsp` should be managed by the project (using mise or the ecosystem's native manifest).
- Run `:Mason` inside Neovim to inspect editor-local servers and tools.

### Notes

- The TypeScript server uses the native `tsc --lsp` implementation and requires TypeScript 7+.
- `jsonls` comes from `vscode-langservers-extracted`.
- `yamlls` comes from `yaml-language-server`.

### Quick checks

Inside Neovim:

- `:LspInfo` (open a `.ts` file and confirm `tsc` is attached)
- `:checkhealth vim.lsp`
