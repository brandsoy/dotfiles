#!/usr/bin/env bash
set -euo pipefail

case "${1:-}" in
    You) profile=Default ;;
    Work) profile='Profile 1' ;;
    Admin) profile='Profile 2' ;;
    *)
        printf 'Usage: %s {You|Work|Admin}\n' "${0##*/}" >&2
        exit 2
        ;;
esac

profile_root="$HOME/Library/Application Support/net.imput.helium"
if ! lsof -c Helium 2>/dev/null | grep -Fq "$profile_root/$profile/"; then
    exit 0
fi

open -na Helium --args "--profile-directory=$profile"
