#!/bin/sh
B=/etc/ssl/cert.pem.bak-emudhra-2026-10-22
[ -f "$B" ] || sudo cp -p /etc/ssl/cert.pem "$B"
t=$(mktemp)
awk '/^(###|===) /{skip=0}
     /^=== .*\/CN=(AAA Certificate Services|emSign ECC Root CA - G3)$/{skip=1}
     !skip' "$B" >"$t"
old=$(grep -c 'BEGIN CERTIFICATE' "$B")
new=$(grep -c 'BEGIN CERTIFICATE' "$t")
[ "$new" -eq $((old - 2)) ] && sudo install -m 644 -o root -g wheel "$t" /etc/ssl/cert.pem && echo "ok: $old -> $new"
rm -f "$t"
