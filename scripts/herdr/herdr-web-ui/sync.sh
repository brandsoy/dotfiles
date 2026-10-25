#!/usr/bin/env bash
# Sync the herdr-web-ui agent adapters into the code that is actually serving.
#
# Layout (kept in this repo, deployed by this script):
#   agents/*.ts        out-of-tree adapter modules -> ~/.config/herdr-web-ui/agents/
#                      (loaded at runtime by the plugin's server/adapters.ts; they
#                      survive plugin updates untouched)
#   hook.patch         the only in-tree change: adapters.ts + routing hooks +
#                      "vibe-transcript" types + the Vibe brand mark
#
# Which tree serves: herdr starts managed.ts from the installation checkout, which
# runs the release's supervisor when current.json matches the checkout's HEAD —
# so the patch goes to the active release, or to the checkout itself when no
# matching release exists. Run this after `herdr plugin install/update` and after
# a web UI self-update; a version whose upstream code drifted will fail loudly
# here instead of the chat lens silently falling back to scrollback. To
# regenerate hook.patch: apply it by hand to a pristine checkout of the serving
# version, then `git diff` the five files it touches.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
AGENTS_SRC="$HERE/agents"
PATCH="$HERE/hook.patch"
AGENTS_DIR="${HERDR_WEB_UI_AGENTS_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/herdr-web-ui/agents}"
STATE_DIR="${HERDR_PLUGIN_STATE_DIR:-$HOME/.local/state/herdr/plugins/devswha.herdr-web-ui}"
PLUGIN="devswha.herdr-web-ui"

json_field() { python3 -c 'import json,sys; print(json.load(open(sys.argv[1])).get(sys.argv[2], ""))' "$1" "$2"; }

# 1. Adapters live outside the plugin: one copy serves every release and checkout.
mkdir -p "$AGENTS_DIR"
for file in "$AGENTS_SRC"/*.ts; do
    [[ "$file" == *.test.ts ]] || cp "$file" "$AGENTS_DIR/"
done

# 2. Patch every tree that can serve: each installation's active release, or the
#    installation checkout itself when it has no matching release.
patched=0
found=0
for checkout in "$HOME"/.config/herdr/plugins/github-installations/"$PLUGIN"-*/*/checkout; do
    [[ -d "$checkout/.git" ]] || continue
    found=1
    head="$(git -C "$checkout" rev-parse HEAD)"
    target="$checkout" # no matching release: managed.ts serves this checkout
    for current in "$HOME"/.config/herdr-web-ui/updates/*/current.json; do
        [[ -f "$current" ]] || continue
        release="$(json_field "$current" directory)"
        [[ "$release" == */release-* && -f "$release/server/supervisor.ts" ]] || continue
        if [[ "$(json_field "$current" source_revision)" == "$head" ]]; then
            target="$release"
            break
        fi
    done
    if git -C "$target" apply --check "$PATCH" >/dev/null 2>&1; then
        git -C "$target" apply "$PATCH"
        [[ -d "$target/node_modules" ]] || (cd "$target" && bun install) # the Vibe mark is frontend: rebuild
        (cd "$target" && bun run build >/dev/null)
        echo "Applied herdr-web-ui hook patch: $target"
        patched=1
    elif git -C "$target" apply --reverse --check "$PATCH" >/dev/null 2>&1; then
        echo "herdr-web-ui hook patch already applied: $target"
    else
        echo "herdr-web-ui hook patch does not apply to $target — upstream code changed." >&2
        echo "Regenerate hook.patch against this version (see this script's header), then re-run." >&2
        exit 1
    fi
done
[[ "$found" == 1 ]] || echo "No herdr-web-ui installation found; adapters deployed to $AGENTS_DIR only."

# 3. Restart the plugin so a running server picks the patched code up.
if [[ -f "$STATE_DIR/server.pid" ]] && kill -0 "$(cat "$STATE_DIR/server.pid")" 2>/dev/null; then
    herdr plugin action invoke stop --plugin "$PLUGIN" >/dev/null 2>&1 || true
    sleep 2 # the supervisor needs a moment to release its lock after the stop
    herdr plugin action invoke start --plugin "$PLUGIN" >/dev/null 2>&1 || true
    echo "Restarted herdr-web-ui."
fi
