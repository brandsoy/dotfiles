#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROLES_DIR="$DOTFILES_DIR/roles"
OS=""
SHARED_ROLES=(agents bin blocklists config git tmux zshenv)
# Role names live here only; validation and default linking derive from them.
MACOS_ROLE=macos-config
LINUX_ROLE=linux-config

usage() {
    cat <<'EOF'
Usage: ./install.sh <command>

  links [role ...]  Link configs only (requires Stow); default: shared + platform
  packages         Install macOS or Fedora packages
  packages-sync    Reconcile the Brewfile with installed Homebrew packages
  plugins          Initialize pinned submodules and install tmux's TPM
  all              Install packages, initialize plugins, then link configs
  -h, --help       Show this help without making changes

No command shows help. No command changes your login shell.
After linking, run `mise install` to install configured runtimes and tools.
EOF
}

has_cmd() { command -v "$1" >/dev/null 2>&1; }

# Print each already-sorted name on its own line; empty input prints nothing.
sorted_lines() {
    [[ -n "$1" ]] && printf '%s\n' "$1"
    return 0
}

# Short (last path segment) of each name, sorted; empty input prints nothing.
short_sorted_lines() {
    [[ -n "$1" ]] && sed -E 's|.*/||' <<<"$1" | sort -u
    return 0
}

# Print the full-name lines from $2 whose short name is listed in $ADDED.
map_full_names() {
    ADDED="$ADDED" awk '
        BEGIN {
            n = split(ENVIRON["ADDED"], a, "\n")
            for (i = 1; i <= n; i++) added[a[i]] = 1
        }
        {
            short = $0
            sub(/^.*\//, "", short)
            if (short in added) print
        }
    ' <<<"$1"
    return 0
}

is_valid_role() {
    local candidate="$1" role
    for role in "${SHARED_ROLES[@]}" "$MACOS_ROLE" "$LINUX_ROLE"; do
        [[ "$candidate" == "$role" ]] && return 0
    done
    return 1
}

detect_os() {
    if [[ "$OSTYPE" == darwin* ]]; then
        OS=macos
    elif [[ -f /etc/fedora-release ]]; then
        OS=fedora
    else
        echo "Unsupported OS: only macOS and Fedora are supported." >&2
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
    fedora)
        local packages=() filtered=() pkg
        while IFS= read -r pkg; do packages+=("$pkg"); done < <(
            awk '!/^#/ && NF { for (i=1;i<=NF;i++) print $i }' "$ROLES_DIR/packages-redhat/Redhatfile"
        )
        for pkg in "${packages[@]}"; do
            case "$pkg" in
            docker | docker-compose)
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

sync_packages() {
    if [[ "$OS" != macos ]]; then
        echo "packages-sync applies to Homebrew on macOS only." >&2
        return 1
    fi
    load_homebrew
    if ! has_cmd brew; then
        echo "Homebrew is required for packages-sync." >&2
        return 1
    fi

    local brewfile="$ROLES_DIR/packages-macos/Brewfile"
    if [[ ! -f "$brewfile" ]]; then
        echo "Brewfile not found: $brewfile" >&2
        return 1
    fi

    # Manifest and machine names are compared by short name (last path
    # segment) so that tap-qualified entries ("tap/name") and bare names
    # both match the same installed package.
    local manifest_brew manifest_cask installed_brew installed_cask
    manifest_brew="$(grep -E '^brew "' "$brewfile" | sed -E 's/^brew "([^"]+)".*/\1/; s|.*/||' | sort -u)"
    manifest_cask="$(grep -E '^cask "' "$brewfile" | sed -E 's/^cask "([^"]+)".*/\1/; s|.*/||' | sort -u)"
    installed_brew="$(brew list --formula | sort -u)"
    installed_cask="$(brew list --cask | sort -u)"
    # Additions are deliberate installs only; transitive dependencies stay
    # implicit. Full names keep new entries resolvable on a fresh machine.
    local leaves_brew full_cask
    leaves_brew="$(brew leaves | sort -u)"
    full_cask="$(brew list --cask --full-name | sort -u)"

    local removed_brew removed_cask added_brew added_cask added_shorts
    removed_brew="$(comm -23 <(sorted_lines "$manifest_brew") <(sorted_lines "$installed_brew"))"
    removed_cask="$(comm -23 <(sorted_lines "$manifest_cask") <(sorted_lines "$installed_cask"))"
    added_shorts="$(comm -13 <(sorted_lines "$manifest_brew") <(short_sorted_lines "$leaves_brew"))"
    added_brew="$(ADDED="$added_shorts" map_full_names "$leaves_brew")"
    added_shorts="$(comm -13 <(sorted_lines "$manifest_cask") <(sorted_lines "$installed_cask"))"
    added_cask="$(ADDED="$added_shorts" map_full_names "$full_cask")"

    if [[ -n "$removed_brew" || -n "$removed_cask" ]]; then
        # Drop manifest lines whose package is no longer installed; keep
        # comments, taps, ordering, and any per-entry args untouched.
        REMOVE_BREW="$removed_brew" REMOVE_CASK="$removed_cask" awk '
            BEGIN {
                n = split(ENVIRON["REMOVE_BREW"], b, "\n")
                for (i = 1; i <= n; i++) remove_brew[b[i]] = 1
                n = split(ENVIRON["REMOVE_CASK"], c, "\n")
                for (i = 1; i <= n; i++) remove_cask[c[i]] = 1
            }
            /^brew "/ { line = $0; sub(/^brew "/, "", line); sub(/".*/, "", line); sub(/^.*\//, "", line); if (line in remove_brew) next }
            /^cask "/ { line = $0; sub(/^cask "/, "", line); sub(/".*/, "", line); sub(/^.*\//, "", line); if (line in remove_cask) next }
            { print }
        ' "$brewfile" >"$brewfile.tmp" && mv "$brewfile.tmp" "$brewfile"
    fi

    if [[ -n "$added_brew" || -n "$added_cask" ]]; then
        {
            printf '\n# Added by ./install.sh packages-sync on %s; review and organize by hand.\n' "$(date +%Y-%m-%d)"
            while IFS= read -r pkg; do [[ -n "$pkg" ]] && printf 'brew "%s"\n' "$pkg"; done <<<"$added_brew"
            while IFS= read -r pkg; do [[ -n "$pkg" ]] && printf 'cask "%s"\n' "$pkg"; done <<<"$added_cask"
        } >>"$brewfile"
    fi

    if [[ -z "$removed_brew$removed_cask$added_brew$added_cask" ]]; then
        echo "Brewfile already matches installed packages."
        return 0
    fi
    if [[ -n "$removed_brew$removed_cask" ]]; then
        echo "Removed (no longer installed):"
        [[ -n "$removed_brew" ]] && sed 's/^/    brew /' <<<"$removed_brew"
        [[ -n "$removed_cask" ]] && sed 's/^/    cask /' <<<"$removed_cask"
    fi
    if [[ -n "$added_brew$added_cask" ]]; then
        echo "Added (installed but untracked):"
        [[ -n "$added_brew" ]] && sed 's/^/    brew /' <<<"$added_brew"
        [[ -n "$added_cask" ]] && sed 's/^/    cask /' <<<"$added_cask"
    fi
    echo "Commit the updated Brewfile when the changes look right."
}

link_roles() {
    if [[ "$OS" == macos ]]; then load_homebrew; fi
    if ! has_cmd stow; then
        echo "Stow is required. Install it with brew or dnf, then rerun links." >&2
        return 1
    fi

    local roles=("$@")
    if ((${#roles[@]} == 0)); then
        roles=("${SHARED_ROLES[@]}")
        if [[ "$OS" == macos ]]; then
            roles+=("$MACOS_ROLE")
        else
            roles+=("$LINUX_ROLE")
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
    local cmd="${1:---help}" role
    case "$cmd" in
    -h | --help)
        usage
        return 0
        ;;
    links)
        shift
        # Validate the entire request before doing anything.
        for role in "$@"; do
            is_valid_role "$role" || {
                echo "Unknown role: $role" >&2
                return 2
            }
        done
        ;;
    packages | packages-sync | plugins | all)
        shift
        if (($#)); then
            usage >&2
            return 2
        fi
        ;;
    *)
        echo "Unknown command: $cmd" >&2
        usage >&2
        return 2
        ;;
    esac

    detect_os
    case "$cmd" in
    links) link_roles "$@" ;;
    packages) install_packages ;;
    packages-sync) sync_packages ;;
    plugins) install_plugins ;;
    all)
        install_packages
        install_plugins
        link_roles
        ;;
    esac
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
