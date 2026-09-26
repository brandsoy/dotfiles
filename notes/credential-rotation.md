# Credential rotation runbook

Why: gitleaks (`./scripts/security-scan.sh`) found real credentials in git
history, and the repo is **public** (github.com/brandsoy/dotfiles). Sixteen
commits between 2024-11 and 2026-03 contain them, under the old pre-`roles/`
layout. The current tree is clean — the secrets exist only in history — but
history is public, so **rotation is required**; scrubbing history later is
optional and does not replace rotation.

Work top to bottom. Do not skip step 2.

## 1. Re-generate the findings (optional, for reference)

```bash
gitleaks detect --source . --report-format json \
  --report-path /tmp/gitleaks-report.json --no-banner
```

To view a specific secret in history, e.g. the Google key:

```bash
git show 65be5671:zshrc/.zshrc        # or bash/.bashrc in the older commit
```

## 2. Rotate the credentials (the only complete fix)

Order by blast radius. For each: revoke the old value, issue a new one if
still needed, then update any current config that uses it (none of these
paths exist in the current tree, so most likely nothing to update locally).

### 2.1 GitHub OAuth tokens — `gho_N8OB…`, `gho_mDiY…` (gh CLI)

Old `gh/hosts.yml` and `.config/gh/hosts.yml` contain two gh CLI tokens.

- https://github.com/settings/applications → *Authorized OAuth Apps* →
  **GitHub CLI** → Revoke. (Revoke twice if both tokens are listed.)
- Then re-authenticate where you still use it: `gh auth login`.
- GitHub secret scanning auto-revokes many public `gho_` tokens — check
  https://github.com/brandsoy/dotfiles/security/alerts and resolve any
  open alerts so the queue stays useful.

### 2.2 GitHub user tokens — `ghu_jhBb…`, `ghu_VHUX…`, `ghu_evmg…` (Copilot CLI)

Old `apps.json`/`hosts.json` from github-copilot contain three tokens.

- https://github.com/settings/applications → *Installed GitHub Apps* /
  authorized apps: revoke anything github-copilot related.
- Re-auth: `github-copilot auth login` (or equivalent) if still used.

### 2.3 Google API key — `AIzaSyAK…`

In old `zshrc/.zshrc` and `bash/.bashrc` (likely an exported API key).

- https://console.cloud.google.com → *APIs & Services* → *Credentials*:
  match the key prefix, delete it. Issue a restricted replacement only if
  something still uses that API, and keep it out of the repo (use the
  shell's secrets file, `roles/config/.config/zsh/secrets.zsh`, which is
  Stow- and Git-ignored).

### 2.4 Linear client secret — `c8ff37b9…`

Bundled into the old Linear Raycast extension sources (49 files).

- https://linear.app → *Settings* → *Workspace* → *API* (or *Security &
  access*): revoke the old key/secret, reissue if still used.

### 2.5 Raycast extension key — `43q2-X4l…`

In old `raycast/config.json` (`dot_config/raycast/config.json` too).

- Reissue from the extension's account/settings; if the extension is no
  longer installed, just revoke it.

### 2.6 Zed API key — `ctx7sk-9…`

In old `zed/settings.json` and `zed/settings_backup.json`.

- Identify which service issued it (Zed extension setting), reissue there.

### 2.7 Asana client ID — `11912017…`

Client IDs are identifiers, not secrets, but it appears alongside the
Linear secret in the same old extension. If a paired client secret was
ever committed anywhere, rotate it; otherwise no action.

### 2.8 Likely noise — review once, then ignore

The remaining ~110 generic hits are fragments of minified extension JS
(`Xa.compi…`, `ISO8601_…`, …) and a `eyJhbGci…` JWT inside a Zed
conversation file named *"Decode JWT testability key injection"* (a demo
value, not a credential). Skim the report; treat as noise unless something
recognizable shows up.

## 3. Verify each rotation

- GitHub tokens: `curl -H "Authorization: token <old-token>"
  https://api.github.com` → expect `401 Bad credentials`.
- Google: try the key against its API → expect 403/400.
- Resolve/close the GitHub secret-scanning alerts for the repo.

## 4. Optionally scrub history (after rotation)

Pick one. Both rewrite history: anyone with a clone must re-clone.

### Option A — surgical, keeps history: `git filter-repo --replace-text`

```bash
git clone --mirror https://github.com/brandsoy/dotfiles.git
cd dotfiles.git

python3 - <<'PY'
import json
secrets = {f["Secret"] for f in json.load(open("/tmp/gitleaks-report.json"))}
with open("replacements.txt", "w") as out:
    for s in secrets:
        out.write(f"literal:{s}==>REMOVED-SECRET\n")
PY

git filter-repo --replace-text replacements.txt
git push --force
```

### Option B — simplest: squash to a single fresh commit

```bash
git checkout --orphan fresh
git add -A && git commit -m "Fresh start: current tree only (see IMPROVEMENTS.md)"
git branch -M fresh main
git push --force origin main
```

Loses bisect history; acceptable for a personal dotfiles repo, but Option
A preserves it.

Caveats (both options): GitHub may serve unreachable commits by SHA for a
while (support can purge), and clones/forks made before the rewrite still
contain the secrets — which is why step 2 comes first and is not optional.

## 5. Final verification

```bash
./scripts/security-scan.sh        # expect: no leaks found
```

Then tick the High item in `IMPROVEMENTS.md`, move it to Done with the
date, and commit.

## Reference: commits containing findings

`186a35d2` `2ba85a9e` `65be5671` `8c1889ff` `8c2f577e` `9067ce55`
`968105da` `a3009a6e` `a4c81b2e` `adf80333` `c8672d61` `cb7977d6`
`d099af71` `dbb37bce` `dc91cb16` (2024-11-13 → 2026-03-10; full list in
the gitleaks JSON report).
