#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROLES_DIR="$DOTFILES_DIR/roles"
OS=""
SHARED_ROLES=(agents bin blocklists config git tmux zshenv)

usage() {
    cat <<'EOF'
Usage: ./install.sh <command>

  links [role ...]  Link configs only (requires Stow); default: shared + platform
  packages         Install macOS, Arch, or Fedora packages
  plugins          Initialize pinned submodules and install tmux's TPM
  all              Install packages, initialize plugins, then link configs
  -h, --help       Show this help without making changes

No command shows help. No command changes your login shell.
After linking, run `mise install` to install configured runtimes and tools.
EOF
}

has_cmd() { command -v "$1" >/dev/null 2>&1; }

detect_os() {
    if [[ "$OSTYPE" == darwin* ]]; then
        OS=macos
    elif [[ -f /etc/arch-release ]]; then
        OS=arch
    elif [[ -f /etc/fedora-release ]]; then
        OS=fedora
    else
        echo "Unsupported OS: only macOS, Arch, and Fedora are supported." >&2
        return 1
    fi
}

load_homebrew() {
    if [[ -x /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -x /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
}

install_packages() {
    case "$OS" in
        macos)
            load_homebrew
            if ! has_cmd brew; then
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                load_homebrew
            fi
            brew bundle --file="$ROLES_DIR/packages-macos/Brewfile"
            ;;
        arch)
            local packages=() aur_packages=() pkg
            while IFS= read -r pkg; do packages+=("$pkg"); done < <(
                awk '!/^#/ && !/^AUR:/ && NF { for (i=1;i<=NF;i++) print $i }' "$ROLES_DIR/packages-arch/Archfile"
            )
            # Avoid Arch partial upgrades; this only runs for packages/all.
            sudo pacman -Syu --needed --noconfirm "${packages[@]}"
            while IFS= read -r pkg; do aur_packages+=("$pkg"); done < <(
                awk '/^AUR:/ { sub(/^AUR:[[:space:]]*/, ""); for (i=1;i<=NF;i++) print $i }' "$ROLES_DIR/packages-arch/Archfile"
            )
            if ((${#aur_packages[@]})); then
                if has_cmd paru; then
                    paru -S --needed --noconfirm "${aur_packages[@]}"
                elif has_cmd yay; then
                    yay -S --needed --noconfirm "${aur_packages[@]}"
                else
                    printf 'AUR packages not installed (install paru or yay, then rerun): %s\n' "${aur_packages[*]}" >&2
                    return 1
                fi
            fi
            ;;
        fedora)
            local packages=() filtered=() pkg
            while IFS= read -r pkg; do packages+=("$pkg"); done < <(
                awk '!/^#/ && NF { for (i=1;i<=NF;i++) print $i }' "$ROLES_DIR/packages-redhat/Redhatfile"
            )
            for pkg in "${packages[@]}"; do
                case "$pkg" in
                    docker|docker-compose)
                        if rpm -q podman-docker >/dev/null 2>&1 || has_cmd docker; then
                            continue
                        fi
                        ;;
                esac
                filtered+=("$pkg")
            done
            # Availability depends on Fedora version and enabled repositories.
            sudo dnf install -y --skip-unavailable "${filtered[@]}"
            if ! has_cmd starship; then
                curl -fsSL https://starship.rs/install.sh | sh -s -- -y
            fi
            if ! has_cmd mise && [[ ! -x "$HOME/.local/bin/mise" ]]; then
                curl -fsSL https://mise.run | sh
            fi
            ;;
    esac
}

link_roles() {
    if [[ "$OS" == macos ]]; then load_homebrew; fi
    if ! has_cmd stow; then
        echo "Stow is required. Install it with brew, pacman, or dnf, then rerun links." >&2
        return 1
    fi

    local roles=("$@")
    if ((${#roles[@]} == 0)); then
        roles=("${SHARED_ROLES[@]}")
        if [[ "$OS" == macos ]]; then
            roles+=(macos-config)
        else
            roles+=(linux-config)
        fi
    fi
    printf 'Linking %s\n' "${roles[@]}"
    # One Stow operation checks all conflicts before changing any links.
    # Use repository ignore rules regardless of the caller's cwd.
    (cd "$DOTFILES_DIR" && stow --dir="$ROLES_DIR" --restow --no-folding --target="$HOME" "${roles[@]}")
}

install_plugins() {
    local _key path backup="" state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles"
    # Older installs contain plain plugin copies, which Git cannot initialize
    # in place. Preserve them outside the Stow tree before cloning submodules.
    while read -r _key path; do
        if [[ -d "$DOTFILES_DIR/$path" && ! -e "$DOTFILES_DIR/$path/.git" && ! -L "$DOTFILES_DIR/$path/.git" ]]; then
            if [[ -z "$backup" ]]; then
                mkdir -p "$state_dir"
                backup="$(mktemp -d "$state_dir/plugin-backup.XXXXXX")"
            fi
            mkdir -p "$backup/$(dirname "$path")"
            mv "$DOTFILES_DIR/$path" "$backup/$path"
            echo "Backed up legacy plugin: $backup/$path"
        fi
    done < <(git config -f "$DOTFILES_DIR/.gitmodules" --get-regexp '^submodule\..*\.path$')

    git -C "$DOTFILES_DIR" submodule sync --recursive
    git -C "$DOTFILES_DIR" submodule update --init --recursive
    if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
        git clone --depth=1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    fi
    echo "TPM ready. In tmux, press Ctrl+s I to install tmux plugins."
}

main() {
    local command="${1:---help}" role
    case "$command" in
        -h|--help) usage; return 0 ;;
        links)
            shift
            # Validate the entire request before doing anything.
            for role in "$@"; do
                case "$role" in
                    agents|bin|blocklists|config|git|tmux|zshenv|macos-config|linux-config) ;;
                    *) echo "Unknown role: $role" >&2; return 2 ;;
                esac
            done
            ;;
        packages|plugins|all)
            shift
            if (($#)); then usage >&2; return 2; fi
            ;;
        *) echo "Unknown command: $command" >&2; usage >&2; return 2 ;;
    esac

    detect_os
    case "$command" in
        links) link_roles "$@" ;;
        packages) install_packages ;;
        plugins) install_plugins ;;
        all) install_packages; install_plugins; link_roles ;;
    esac
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
