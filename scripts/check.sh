#!/usr/bin/env bash
set -euo pipefail

# One command for all offline checks: formatting, linting, and tests.
# Requires: shfmt, shellcheck, python3, plus the test suite's own tools.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Our own scripts only; vendored skills and compiled binaries are excluded.
SHELL_SCRIPTS=(
    "$REPO_DIR/install.sh"
    "$REPO_DIR"/scripts/*.sh
    "$REPO_DIR"/scripts/tmux/*.sh
    "$REPO_DIR"/scripts/tmux/minimal-theme/*.tmux
    "$REPO_DIR"/scripts/tmux/minimal-theme/scripts/*.sh
    "$REPO_DIR"/roles/bin/.local/bin/ai-models
    "$REPO_DIR"/roles/bin/.local/bin/dotfiles-install
    "$REPO_DIR"/roles/bin/.local/bin/dotfiles-update
    "$REPO_DIR"/roles/bin/.local/bin/keybinds
    "$REPO_DIR"/roles/bin/.local/bin/theme-sync
)

log() {
    printf '\n==> %s\n' "$*"
}

for tool in shfmt shellcheck python3; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        printf 'check.sh: %s is required\n' "$tool" >&2
        exit 1
    fi
done

log 'shfmt: formatting check (shfmt -i 4)'
nonconforming="$(shfmt -i 4 -l "${SHELL_SCRIPTS[@]}")"
if [[ -n "$nonconforming" ]]; then
    printf 'These files need formatting; run: shfmt -i 4 -w <file>\n%s\n' "$nonconforming" >&2
    exit 1
fi

log 'shellcheck: lint (warnings are errors)'
shellcheck --severity=warning "${SHELL_SCRIPTS[@]}"

log 'tests: offline regression checks'
python3 "$REPO_DIR/tests/test_dotfiles.py"

log 'All checks passed'
