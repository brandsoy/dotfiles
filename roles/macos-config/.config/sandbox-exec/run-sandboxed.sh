#!/bin/bash
set -euo pipefail

PROFILE="${HOME}/.config/sandbox-exec/agent.sb"
WORKDIR=""
ARGS=()

while (($#)); do
  case "$1" in
  --workdir=*)
    WORKDIR="${1#--workdir=}"
    shift
    ;;
  --workdir)
    (($# >= 2)) || {
      echo "Missing path after --workdir" >&2
      exit 2
    }
    WORKDIR="$2"
    shift 2
    ;;
  --)
    shift
    ARGS=("$@")
    break
    ;;
  *)
    ARGS=("$@")
    break
    ;;
  esac
done

[[ -r "$PROFILE" ]] || {
  echo "Cannot read profile: $PROFILE" >&2
  exit 1
}

WORKDIR="${WORKDIR:-$(pwd -P)}"
WORKDIR="$(cd "$WORKDIR" && pwd -P)" || {
  echo "Invalid workdir: $WORKDIR" >&2
  exit 1
}

# BSD mktemp requires its XXXXXX template at the end of the path.
tmp="$(mktemp "${TMPDIR:-/tmp}/agent-sandbox.XXXXXX")"
trap 'rm -f "$tmp"' EXIT HUP INT TERM
cp "$PROFILE" "$tmp"

# Quote an absolute path as a Scheme string.
scheme_string() {
  python3 -c 'import json,sys; print(json.dumps(sys.argv[1]))' "$1"
}

# Emit traversal metadata grants for every ancestor, then the requested rule.
emit_ancestors() {
  local path="$1" current="/"
  local part
  IFS='/' read -r -a parts <<<"${path#/}"
  for part in "${parts[@]}"; do
    [[ -n "$part" ]] || continue
    current="${current%/}/$part"
    printf '(allow file-read-metadata (literal %s))\n' \
      "$(scheme_string "$current")" >>"$tmp"
  done
}

emit_readonly_dir() {
  local path="$1"
  [[ -d "$path" ]] || return 0
  path="$(cd "$path" && pwd -P)"
  emit_ancestors "$path"
  printf '(allow file-read* (subpath %s))\n' \
    "$(scheme_string "$path")" >>"$tmp"
}

emit_readwrite_dir() {
  local path="$1"
  emit_ancestors "$path"
  printf '(allow file-read* file-write* (subpath %s))\n' \
    "$(scheme_string "$path")" >>"$tmp"
}

# The selected project is read/write.
emit_readwrite_dir "$WORKDIR"

# If this is a linked worktree root, snapshot all other existing worktrees
# as read-only paths. Git reports their absolute roots in porcelain output.
if git -C "$WORKDIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  top="$(git -C "$WORKDIR" rev-parse --show-toplevel 2>/dev/null || true)"
  if [[ "$top" == "$WORKDIR" ]]; then
    gitdir="$(git -C "$WORKDIR" rev-parse --absolute-git-dir 2>/dev/null ||
      true)"
    common="$(
      git -C "$WORKDIR" rev-parse --path-format=absolute --git-common-dir
      2>/dev/null || true
    )"

    if [[ -n "$gitdir" && -n "$common" && "$gitdir" != "$common" ]]; then
      # A linked worktree's shared git metadata may be outside its root.
      emit_readwrite_dir "$common"
    fi

    while IFS= read -r line; do
      case "$line" in
      "worktree "*)
        sibling="${line#worktree }"
        [[ "$sibling" == "$WORKDIR" ]] || emit_readonly_dir "$sibling"
        ;;
      esac
    done < <(git -C "$WORKDIR" worktree list --porcelain 2>/dev/null || true)
  fi
fi

if ((${#ARGS[@]})); then
  sandbox-exec -f "$tmp" "${ARGS[@]}"
else
  sandbox-exec -f "$tmp" "${SHELL:-/bin/zsh}"
fi
