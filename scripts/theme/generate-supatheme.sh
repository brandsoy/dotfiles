#!/usr/bin/env bash
set -euo pipefail

# Compatibility shortcut. SupaTheme now uses the same renderer as every theme.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$SCRIPT_DIR/theme-sync.sh" set SupaTheme
