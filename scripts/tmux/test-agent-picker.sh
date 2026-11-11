#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
dir=$(mktemp -d)
trap 'rm -rf "$dir"' EXIT
export TEST_LOG="$dir/log"
cat > "$dir/ps" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' 's001 /usr/bin/pi' 's002 node /opt/claude.js' 's003 zsh'
EOF
cat > "$dir/tmux" <<'EOF'
#!/usr/bin/env bash
if [[ $1 == list-panes ]]; then
  printf '%%1\t/dev/ttys001\twork:1.1\teditor\t/tmp\n%%2\t/dev/ttys002\twork:2.1\tagent\t/tmp\n%%3\t/dev/ttys003\twork:3.1\tshell\t/tmp\n'
else
  printf '%s\n' "$*" >> "$TEST_LOG"
fi
EOF
cat > "$dir/fzf-tmux" <<'EOF'
#!/usr/bin/env bash
tee "$TEST_LOG.rows" | head -n 1
EOF
chmod +x "$dir/ps" "$dir/tmux" "$dir/fzf-tmux"
PATH="$dir:$PATH" XDG_STATE_HOME="$dir" bash ./agent-picker.sh /dev/client
[[ $(wc -l < "$TEST_LOG.rows" | tr -d ' ') == 2 ]]
grep -q $'%1\tpi\twork:1.1' "$TEST_LOG.rows"
grep -q $'%2\tclaude\twork:2.1' "$TEST_LOG.rows"
grep -q 'switch-client -c /dev/client -t %1' "$TEST_LOG"
printf 'agent picker test passed\n'
