#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BREWFILE="$DOTFILES_DIR/roles/packages-macos/Brewfile"
LEGACY_BREWFILE="$DOTFILES_DIR/homebrew/Brewfile"
if [[ ! -f "$BREWFILE" && -f "$LEGACY_BREWFILE" ]]; then
  BREWFILE="$LEGACY_BREWFILE"
fi

MODE="upgrade"
DO_CLEANUP=0
DO_SYNC_BREWFILE=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --check)
      MODE="check"
      ;;
    --cleanup)
      DO_CLEANUP=1
      ;;
    --sync-brewfile)
      DO_SYNC_BREWFILE=1
      ;;
    --maintenance)
      DO_CLEANUP=1
      DO_SYNC_BREWFILE=1
      ;;
    -h|--help)
      cat <<'EOF'
Usage: update-tools.sh [--check] [--cleanup] [--sync-brewfile] [--maintenance]

Check or upgrade Homebrew + mise managed tooling.

Options:
  --check          Check only; do not upgrade
  --cleanup        Run brew cleanup and mise prune after upgrading
  --sync-brewfile  Dump current Homebrew state back to Brewfile after upgrading
  --maintenance    Run both cleanup and Brewfile sync
  -h, --help       Show help
EOF
      exit 0
      ;;
    *)
      printf 'WARN: unknown argument: %s\n' "$1" >&2
      exit 1
      ;;
  esac
  shift
done

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

      if [[ "$DO_SYNC_BREWFILE" -eq 1 ]]; then
        log "Homebrew: syncing Brewfile"
        brew bundle dump --force --file="$BREWFILE"
      fi
    else
      warn "Brewfile not found at $BREWFILE; running brew upgrade instead"
      brew upgrade --greedy
    fi

    if [[ "$DO_CLEANUP" -eq 1 ]]; then
      log "Homebrew: cleaning old versions"
      brew cleanup -s
    fi
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

    if [[ "$DO_CLEANUP" -eq 1 ]]; then
      log "mise: pruning unused versions"
      mise prune -y
    fi
  fi
else
  warn "mise not found; skipping mise"
fi

log "Done"
