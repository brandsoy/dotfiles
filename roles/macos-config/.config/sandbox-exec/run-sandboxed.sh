#!/bin/bash
set -euo pipefail

profile="$HOME/.config/sandbox-exec/agent.sb"
workdir=""
if [[ "${1:-}" == --workdir=* ]]; then
  workdir="${1#--workdir=}"
  [[ -n "$workdir" ]] || {
    echo "Empty workdir" >&2
    exit 2
  }
  shift
fi
[[ "${1:-}" != -- ]] || shift
[[ $# -gt 0 ]] || {
  echo "Usage: $0 [--workdir=DIR] [--] command [args...]" >&2
  exit 2
}
[[ -r "$profile" ]] || {
  echo "Cannot read policy: $profile" >&2
  exit 1
}
workdir="$(cd "${workdir:-.}" && pwd -P)" || exit 1
home="$(cd "$HOME" && pwd -P)"
[[ "$workdir" != / ]] || {
  echo "Refusing to grant / as workdir" >&2
  exit 1
}
case "$home/" in
"$workdir/"*)
  echo "Refusing to grant HOME or its ancestors" >&2
  exit 1
  ;;
esac

umask 077
policy="$(mktemp "${TMPDIR:-/tmp}/agent-policy.XXXXXXXX")"
list=""
cleanup() {
  rm -f "$policy"
  [[ -z "$list" ]] || rm -f "$list"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
cat "$profile" >"$policy"

escape() {
  local value="$1" LC_ALL=C
  if [[ "$value" =~ [[:cntrl:]] ]]; then
    echo "Control characters in a path are unsupported" >&2
    return 1
  fi
  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  printf '%s' "$value"
}
grant() {
  local path="$1" mode="$2" parent="/" component escaped
  local -a parts
  IFS=/ read -r -a parts <<<"${path#/}"
  printf '\n;; %s: ancestor listings and path grant.\n(allow file-read* (literal "/")' "$mode"
  for component in "${parts[@]}"; do
    [[ -n "$component" ]] || continue
    if [[ "$parent" == / ]]; then parent="/$component"; else parent="$parent/$component"; fi
    escaped="$(escape "$parent")" || return 1
    printf ' (literal "%s")' "$escaped"
  done
  printf ')\n'
  escaped="$(escape "$path")" || return 1
  if [[ "$mode" == rw ]]; then
    printf '(allow file-read* file-write* (subpath "%s"))\n' "$escaped"
  else
    printf '(allow file-read* (subpath "%s"))\n' "$escaped"
    printf '(deny file-write* (subpath "%s"))\n' "$escaped"
  fi
}

common=""
if git_root="$(git -C "$workdir" rev-parse --show-toplevel 2>/dev/null)"; then
  git_root="$(cd "$git_root" && pwd -P)"
  if [[ "$git_root" == "$workdir" ]]; then
    list="$(mktemp "${TMPDIR:-/tmp}/agent-worktrees.XXXXXXXX")"
    git -C "$workdir" worktree list --porcelain -z >"$list"
    while IFS= read -r -d '' entry; do
      case "$entry" in
      'worktree '*)
        sibling="${entry#worktree }"
        [[ -d "$sibling" ]] || continue
        sibling="$(cd "$sibling" && pwd -P)"
        [[ "$sibling" != / ]] || {
          echo "Refusing root sibling worktree" >&2
          exit 1
        }
        case "$home/" in
        "$sibling/"*)
          echo "Refusing broad sibling worktree: $sibling" >&2
          exit 1
          ;;
        esac
        [[ "$sibling" == "$workdir" ]] || grant "$sibling" ro >>"$policy"
        ;;
      esac
    done <"$list"
    if [[ -f "$workdir/.git" ]]; then
      common="$(git -C "$workdir" rev-parse --path-format=absolute --git-common-dir)"
      common="$(cd "$common" && pwd -P)"
      [[ "$common" != / ]] || {
        echo "Refusing root Git common dir" >&2
        exit 1
      }
      case "$home/" in
      "$common/"*)
        echo "Refusing broad Git common dir: $common" >&2
        exit 1
        ;;
      esac
    fi
  fi
fi
grant "$workdir" rw >>"$policy"
if [[ -n "$common" ]]; then
  case "$common/" in "$workdir/"*) ;; *) grant "$common" rw >>"$policy" ;; esac
fi

# Apply sensitive-path denies after the workdir and worktree grants.
cat >>"$policy" <<'SB'
(deny file-read* file-write* file-read-metadata
  (home-subpath "/.ssh") (home-subpath "/Library/Keychains")
  (home-subpath "/Library/Application Support/Google/Chrome")
  (home-subpath "/Library/Application Support/Firefox")
  (home-subpath "/Library/Safari")
  (home-literal "/.zshenv") (home-literal "/.zprofile")
  (home-literal "/.zshrc") (home-literal "/.bashrc")
  (home-literal "/.bash_profile") (home-subpath "/.config/zsh")
  (home-subpath "/.config/sandbox-exec")
  (subpath "/Users/mattis/dotfiles/roles/config/.config/zsh")
  (literal "/Users/mattis/dotfiles/roles/zshenv/.zshenv")
  (literal "/var/run/docker.sock") (literal "/private/var/run/docker.sock")
  (home-literal "/.docker/run/docker.sock")
  (home-literal "/.rd/docker.sock")
  (home-literal "/.orbstack/run/docker.sock")
  (regex #"^/private/tmp/com\.apple\.launchd\.[^/]+/Listeners$")
  (regex #"^/private/var/run/com\.apple\.launchd\.[^/]+/Listeners$"))
(deny network-outbound
  (remote unix-socket (path-literal "/var/run/docker.sock"))
  (remote unix-socket (path-literal "/private/var/run/docker.sock"))
  (remote unix-socket (path-regex #"^/private/tmp/com\.apple\.launchd\.[^/]+/Listeners$"))
  (remote unix-socket (path-regex #"^/private/var/run/com\.apple\.launchd\.[^/]+/Listeners$")))
SB
cd "$workdir"
sandbox-exec -f "$policy" "$@"
