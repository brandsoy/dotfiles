#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BREWFILE="$DOTFILES_DIR/roles/packages-macos/Brewfile"

MODE="upgrade"
DO_CLEANUP=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --check)
      MODE="check"
      ;;
    --cleanup)
      DO_CLEANUP=1
      ;;
    --sync-brewfile|--maintenance)
      printf 'WARN: %s was removed: keep the Brewfile hand-maintained; do not use brew bundle dump as an automatic sync\n' "$1" >&2
      exit 2
      ;;
    -h|--help)
      cat <<'EOF'
Usage: update-tools.sh [--check] [--cleanup]

Check or upgrade the tools declared in Homebrew and mise manifests.

Options:
  --check          Report available updates; does not run brew update or upgrade tools
  --cleanup        Run brew cleanup and mise prune after upgrading
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

# GitHub-backed mise backends otherwise share the unauthenticated API rate
# limit. Keep the token scoped to each mise command rather than exporting it
# for the entire updater process.
run_mise() {
  local github_token
  if [[ -n "${GITHUB_TOKEN:-}" ]]; then
    mise "$@"
  elif command -v gh >/dev/null 2>&1 && github_token="$(gh auth token 2>/dev/null)"; then
    GITHUB_TOKEN="$github_token" mise "$@"
  else
    mise "$@"
  fi
}

if command -v brew >/dev/null 2>&1; then
  if [[ "$MODE" == "check" ]]; then
    log "Homebrew: outdated packages"
    brew outdated --greedy || true
  else
    log "Homebrew: updating metadata"
    brew update

    if [[ -f "$BREWFILE" ]]; then
      log "Homebrew: upgrading from Brewfile"
      brew bundle upgrade --file="$BREWFILE"
    else
      warn "Brewfile not found at $BREWFILE; refusing to upgrade unrelated packages"
      exit 1
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
  run_mise outdated || true

  if [[ "$MODE" == "upgrade" ]]; then
    log "mise: upgrading tools"
    run_mise upgrade --yes

    if [[ "$DO_CLEANUP" -eq 1 ]]; then
      log "mise: pruning unused versions"
      run_mise prune -y
    fi
  fi
else
  warn "mise not found; skipping mise"
fi

log "Done"
