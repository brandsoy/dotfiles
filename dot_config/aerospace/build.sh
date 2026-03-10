#!/usr/bin/env bash
# Concatenates config fragments into aerospace.toml
# Run after editing any file in config/

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/config"
OUTPUT="$SCRIPT_DIR/aerospace.toml"

{
    echo "# AUTO-GENERATED — edit files in config/ then run ./build.sh"
    echo ""
    for f in "$CONFIG_DIR"/*.toml; do
        cat "$f"
        echo ""
    done
} > "$OUTPUT"

echo "Generated $OUTPUT"
