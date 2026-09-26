# Pi agent notes

## Git — important
- **Never push to GitHub or any remote.** Commit with described messages
  when asked; the owner reviews and pushes deliberately.
- Real commit messages only; never "wip".

## Dotfiles (~/dotfiles)
- Run `./scripts/check.sh` before committing (shfmt, shellcheck, gitleaks,
  offline tests); fix what it reports.
- `IMPROVEMENTS.md` is the backlog and convention ledger: move finished
  items to Done with a date; deviations from the style rules need a reason.
- The Brewfile is hand-maintained; `./install.sh packages-sync` is the only
  sanctioned reconciliation, and `packages-macos/untracked.txt` holds
  deliberate exclusions.
- macOS-only tooling: bash 3.2 compatible (no mapfile, no associative
  arrays) until Homebrew's bash exists on fresh installs.

This file is the only Pi state kept in the repository. Credentials
(`auth.json`, `models.json`) and runtime state stay machine-local.
