# Dotfiles

Personal configuration files for macOS and Linux (Arch/Debian), managed with [chezmoi](https://www.chezmoi.io/).

## Structure

```
dotfiles/                          # chezmoi source directory
├── dot_config/                    # → ~/.config/
│   ├── nvim/                      # Neovim (shared)
│   ├── ghostty/                   # Ghostty terminal (shared)
│   ├── kitty/                     # Kitty terminal (shared)
│   ├── alacritty/                 # Alacritty terminal (shared)
│   ├── tmux/ (via dot_tmux.conf)  # Tmux (shared)
│   ├── lazygit/                   # lazygit (shared)
│   ├── lazydocker/                # lazydocker (shared)
│   ├── starship.toml              # Starship prompt (shared)
│   ├── aerospace/                 # macOS window manager
│   ├── karabiner/                 # macOS key remapping
│   ├── raycast/                   # macOS launcher
│   ├── hypr/                      # Hyprland compositor (Linux)
│   ├── waybar/                    # Waybar status bar (Linux)
│   ├── keyd/                      # Key remapping (Linux)
│   ├── swaync/                    # Notification daemon (Linux)
│   └── gtk-*/                     # GTK themes (Linux)
├── dot_gitconfig                  # → ~/.gitconfig
├── dot_zshrc                      # → ~/.zshrc
├── dot_zprofile                   # → ~/.zprofile
├── dot_zshenv                     # → ~/.zshenv
├── dot_tmux.conf                  # → ~/.tmux.conf
├── dot_ssh/                       # → ~/.ssh/ (config only, no keys)
├── Brewfile                       # Homebrew packages (macOS)
├── Archfile                       # Arch Linux packages
├── .chezmoiignore                 # OS-conditional file exclusions
├── .chezmoi.toml.tmpl             # chezmoi config template
└── run_once_install-packages.sh.tmpl  # One-time package installation
```

## Quick Start

### Prerequisites

Install chezmoi:

```bash
# macOS
brew install chezmoi

# Linux
sh -c "$(curl -fsLS get.chezmoi.io)"
```

### Apply dotfiles

```bash
chezmoi init --apply https://github.com/mattis/dotfiles
```

Or if you've already cloned the repo:

```bash
chezmoi init --source ~/dotfiles
chezmoi apply
```

### What happens on first apply

- chezmoi reads `.chezmoiignore` to skip OS-inappropriate configs
- `run_once_install-packages.sh.tmpl` runs once to install packages and tools:
  - macOS: `brew bundle` from `Brewfile`
  - Arch: `pacman` + AUR packages from `Archfile`
  - Debian/Ubuntu: `apt` with common tools
  - Installs: lazygit, lazydocker, mise, gh CLI, TPM
  - Sets zsh as default shell

## Day-to-day Usage

```bash
# See what changes chezmoi would make
chezmoi diff

# Apply dotfiles
chezmoi apply

# Edit a file in source directory
chezmoi edit ~/.zshrc

# Add a new file
chezmoi add ~/.config/something/config

# Pull latest and apply
chezmoi update
```

## OS-Specific Configs

OS filtering is handled by `.chezmoiignore`:

- **macOS only**: `dot_config/aerospace`, `dot_config/karabiner`, `dot_config/raycast`, `Brewfile`
- **Linux only**: `dot_config/hypr`, `dot_config/waybar`, `dot_config/keyd`, `dot_config/swaync`, `dot_config/gtk-*`, `Archfile`

## Secrets (Proton Pass)

Secrets are managed via [Proton Pass](https://proton.me/pass) using the [`pass-cli`](https://protonpass.github.io/pass-cli/) tool, which chezmoi supports natively.

### Setup

```bash
# Install (included in Brewfile, or manually)
brew install protonpass/tap/pass-cli

# Authenticate (opens browser)
pass-cli login
```

### Finding secret URIs

```bash
# List vaults to get SHARE_ID
pass-cli vault list

# List items in a vault to get ITEM_ID
pass-cli item list --vault-id <SHARE_ID>

# Inspect an item's fields
pass-cli item view pass://<SHARE_ID>/<ITEM_ID>
```

### Using secrets in templates

Any dotfile can be made a template by adding a `.tmpl` suffix. Reference secrets with:

```
# Simple field
{{ protonPass "pass://<SHARE_ID>/<ITEM_ID>/<FIELD>" }}

# Structured item (login with multiple fields)
{{ (protonPassJSON "pass://<SHARE_ID>/<ITEM_ID>").item.content.content.key.password }}
```

Example — `dot_gitconfig.tmpl`:

```
[user]
    name  = {{ protonPass "pass://abc123/def456/username" }}
    email = {{ protonPass "pass://abc123/def456/email" }}
```
