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
      printf '\n# <<< Local hosts overrides <<<\n'
    } >>"$target"
    log "Appended local overrides"
  fi
}

flush_macos_dns() {
  sudo dscacheutil -flushcache || true
  sudo killall -HUP mDNSResponder || true
  log "macOS DNS cache flushed"
}

flush_linux_dns() {
  if command -v resolvectl >/dev/null 2>&1 && systemctl is-active --quiet systemd-resolved; then
    sudo resolvectl flush-caches || true
    log "Flushed systemd-resolved"
  elif command -v systemd-resolve >/dev/null 2>&1; then
    sudo systemd-resolve --flush-caches || true
    log "Flushed systemd-resolve"
  fi

  if systemctl is-active --quiet NetworkManager; then
    sudo systemctl reload NetworkManager || sudo systemctl restart NetworkManager || true
    log "Reloaded NetworkManager"
  fi

  if systemctl is-active --quiet dnsmasq; then
    sudo systemctl restart dnsmasq || true
    log "Restarted dnsmasq"
  fi

  if systemctl is-active --quiet nscd; then
    sudo nscd -i hosts || sudo systemctl restart nscd || true
    log "Invalidated nscd hosts cache"
  fi

  if systemctl is-active --quiet unbound; then
    sudo systemctl restart unbound || true
    log "Restarted unbound"
  fi

  if systemctl is-active --quiet sssd; then
    if command -v sss_cache >/dev/null 2>&1; then
      sudo sss_cache -E || true
      log "Cleared SSSD cache"
    fi
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

  case "$(uname -s)" in
    Darwin)
      log "macOS detected"
      flush_macos_dns
      ;;
    Linux)
      log "Linux detected"
      flush_linux_dns
      ;;
    *)
      err "Unsupported OS: $(uname -s)"
      exit 1
      ;;
  esac

  log "Done"
}

main "$@"
