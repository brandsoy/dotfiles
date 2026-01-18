#!/usr/bin/env bash
set -euo pipefail

HOSTS_REPO="${HOSTS_REPO:-https://github.com/StevenBlack/hosts.git}"
REPO_DIR="${HOSTS_REPO_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/stevenblack-hosts}"
HOSTS_SOURCE_FILE="${HOSTS_SOURCE_FILE:-hosts}"
LOCAL_OVERRIDES="${HOSTS_LOCAL_OVERRIDES:-$HOME/.config/hosts.local}"

log() { printf '[*] %s\n' "$*" ; }
err() { printf '[!] %s\n' "$*" >&2; }

require_bin() {
  command -v "$1" >/dev/null 2>&1 || { err "Missing required command: $1"; exit 1; }
}

ensure_repo() {
  if [[ -d "$REPO_DIR/.git" ]]; then
    log "Updating hosts repo in $REPO_DIR"
    git -C "$REPO_DIR" fetch --depth=1 origin
    current_branch="$(git -C "$REPO_DIR" rev-parse --abbrev-ref HEAD)"
    git -C "$REPO_DIR" reset --hard "origin/${current_branch}"
  else
    log "Cloning hosts repo into $REPO_DIR"
    rm -rf "$REPO_DIR"
    git clone --depth=1 "$HOSTS_REPO" "$REPO_DIR"
  fi
}

append_local_overrides() {
  local target="$1"
  if [[ -s "$LOCAL_OVERRIDES" ]]; then
    {
      printf '\n# >>> Local hosts overrides (%s) >>>\n' "$LOCAL_OVERRIDES"
      cat "$LOCAL_OVERRIDES"
      printf '\n# <<< Local hosts overrides <<<
'
    } >>"$target"
    log "Appended local overrides"
  fi
}

flush_dns() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sudo dscacheutil -flushcache || true
    sudo killall -HUP mDNSResponder || true
    log "DNS cache flushed (macOS)"
  elif command -v systemd-resolve >/dev/null 2>&1; then
    sudo systemd-resolve --flush-caches
    log "DNS cache flushed (systemd-resolve)"
  elif command -v resolvectl >/dev/null 2>&1; then
    sudo resolvectl flush-caches
    log "DNS cache flushed (resolvectl)"
  else
    log "Warning: Unable to detect DNS flush command."
  fi
}

cleanup() {
  [[ -n "${TMP_FILE:-}" ]] && rm -f "$TMP_FILE"
}

main() {
  require_bin git
  require_bin mktemp

  ensure_repo

  local source_file="$REPO_DIR/$HOSTS_SOURCE_FILE"
  [[ -f "$source_file" ]] || { err "Hosts file not found in repo: $source_file"; exit 1; }

  TMP_FILE="$(mktemp)"
  trap cleanup EXIT

  cp "$source_file" "$TMP_FILE"
  append_local_overrides "$TMP_FILE"

  log "Updating /etc/hosts"
  sudo cp "$TMP_FILE" /etc/hosts

  flush_dns

  log "Done"
}

main "$@"