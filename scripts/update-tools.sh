#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BREWFILE="$DOTFILES_DIR/homebrew/Brewfile"

MODE="upgrade"
if [[ "${1:-}" == "--check" ]]; then
  MODE="check"
elif [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  cat <<'EOF'
Usage: update-tools.sh [--check]

Check or upgrade Homebrew + mise managed tooling.

Options:
  --check    Check only; do not upgrade
  -h, --help Show help
EOF
  exit 0
fi

log() {
  printf "\n==> %s\n" "$*"
}

warn() {
  printf "WARN: %s\n" "$*" >&2
}

if command -v brew >/dev/null 2>&1; then
  log "Homebrew: updating metadata"
  brew update

  log "Homebrew: outdated packages"
  brew outdated --greedy || true

  if [[ "$MODE" == "upgrade" ]]; then
    if [[ -f "$BREWFILE" ]]; then
      log "Homebrew: upgrading from Brewfile"
      brew bundle upgrade --file="$BREWFILE"

      log "Homebrew: syncing Brewfile"
      brew bundle dump --force --file="$BREWFILE"
    else
      warn "Brewfile not found at $BREWFILE; running brew upgrade instead"
      brew upgrade --greedy
    fi

    log "Homebrew: cleaning old versions"
    brew cleanup -s
  fi
else
  warn "brew not found; skipping Homebrew"
fi

if command -v mise >/dev/null 2>&1; then
  log "mise: outdated tools"
  mise outdated || true

  if [[ "$MODE" == "upgrade" ]]; then
    log "mise: upgrading tools"
    mise upgrade --yes

    log "mise: pruning unused versions"
    mise prune -y
  fi
else
  warn "mise not found; skipping mise"
fi

log "Done"
