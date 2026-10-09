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

# Helium's native profile switch reuses an existing window when available.
if result=$(
    /usr/bin/osascript - "$1" <<'APPLESCRIPT'
on run argv
    tell application "System Events"
        if not (exists process "Helium") then return "not-running"
        tell process "Helium"
            set frontmost to true
            click menu item (item 1 of argv) of menu 1 of menu bar item "Profiles" of menu bar 1
        end tell
    end tell
    return "switched"
end run
APPLESCRIPT
); then
    if [[ "$result" == not-running ]]; then
        /usr/bin/open -na Helium --args "--profile-directory=$profile"
    fi
else
    printf 'Profile switching requires Accessibility access for Tinycast in System Settings.\n' >&2
    exit 1
fi
