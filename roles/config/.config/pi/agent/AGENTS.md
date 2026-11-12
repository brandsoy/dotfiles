# Pi agent notes

## Git — important
- **Never push to GitHub or any remote.** The owner reviews and pushes changes.
- Commit only when asked. Use descriptive commit messages, not "wip".

## Dotfiles (~/dotfiles)
- Before committing, run `./scripts/maintenance/check.sh` (shfmt, shellcheck,
  gitleaks, and offline tests). Fix reported problems before the commit.
- `IMPROVEMENTS.md` is the backlog and convention ledger. Move completed items
  to Done with a date. Give a reason for deviations from the style rules.
- The Brewfile is hand-maintained. Use only `./install.sh packages-sync` to
  reconcile it. `packages-macos/untracked.txt` holds deliberate exclusions.
- macOS-only tooling: bash 3.2 compatible (no mapfile, no associative
  arrays) until Homebrew's bash exists on fresh installs.

This directory contains versioned Pi notes and themes. Credentials
(`auth.json`, `models.json`) and runtime state stay machine-local.
