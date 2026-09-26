# Improvements

Living backlog for keeping this repo clean and maintainable, plus the style
rules we hold ourselves to. Last reviewed: 2026-09-26.

**Scope:** changes to this repo's own structure, scripts, tests, and docs.
Feature and tool ideas live in `notes/future-improvements.md`; this file is
about maintainability, not new capabilities.

## How to use this doc

- Add items under a priority section as `- [ ] title — one-line why`.
  Keep the why short; details go in the linked file or commit.
- Reassess priorities when picking up work. Move stale items to **Dropped**
  with a reason instead of deleting them.
- When an item is done, tick it and move it to **Done** with the date.
- If the doc grows past ~120 lines, archive older Done entries or move whole
  sections to `notes/`.

## Style rules (accepted conventions)

New and edited code follows these; deviations need a reason.

- Bash: `set -euo pipefail`, `#!/usr/bin/env bash`, `usage()` heredoc,
  help-first (no args → help), and zero shellcheck warnings.
- **Bash 3.2 compatible**: `install.sh` must run on a fresh Mac before
  Homebrew's bash exists. No `mapfile`, no associative arrays, no `${var,,}`.
- Functions over inline blocks; a function does one thing. Prefer `return`
  over `exit` in helpers called by other functions.
- Never shadow builtins with variable names (e.g. use `cmd`, not `command`).
- Comments explain *why*, never *what*. Keep the good ones ("Avoid Arch
  partial upgrades", "Do not inherit optional mappings…").
- One source of truth per list — if a name appears in two places, derive the
  second from the first (arrays over duplicated `case` patterns).
- Scripts are idempotent and safe by default: validate the whole request
  before acting, keep packages/plugins/linking orthogonal, never touch the
  login shell.
- Offline tests only: disposable homes, mocked package managers, no network.
- Git history: real commit messages, no `wip`. The point of dotfiles history
  is bisecting config regressions.
- Formatting: 4-space indent everywhere (see backlog — currently mixed).
- Decisions to keep even if they look removable:
  - `--sync-brewfile|--maintenance` tombstones in `update-tools.sh` (add a
    removal date if adding new ones).
  - `run_mise` GITHUB_TOKEN scoping in `update-tools.sh`.
  - `prepare_output`'s dangling-link detach in `theme-sync.sh`.

## Backlog

### Medium

- [ ] `theme-sync.sh` error handling — add a `die()` helper and standardize
  the `exit`/`return` mix.
- [ ] `theme-sync.sh`: split `apply_theme` (~60 lines, 10 apps) into
  `apply_terminal_themes` / `apply_cli_overlays`; extract a `pause()` helper
  for `tui_menu`'s repeated `read -r -p` lines; make `load_theme` the single
  theme validator (drop the duplicated check in `set_mode_theme`).
- [ ] Formatting consistency — run `shfmt -i 4 -w` once (`install.sh` is
  4-space, `scripts/` is 2-space), add `shfmt` next to `shellcheck` in the
  Brewfile, and add `scripts/check.sh` running shfmt --check + shellcheck +
  tests as the single entry point (README and CI both call it).
- [ ] Split `tests/test_dotfiles.py`'s ~150-line `main()` into named test
  functions with per-test temp dirs (pattern already proven in
  `test_plugin_migration`); pytest optional but welcome.

### Minor

- [ ] `generate-supatheme.sh` — build the alacritty theme (base + indexed
  colors) as one string and write once, like the other themes.
- [ ] `install.sh` — extract a `read_manifest_words` helper to DRY the four
  awk parse loops in the arch/fedora sections. Keep while-read loops (3.2).
- [ ] README split (judgment call) — slim README keeps overview/install/
  structure and links to `docs/theme-sync.md`, `docs/ai-models.md`,
  `docs/neovim-lsp.md`. Only if scrolling past sections annoys you.

## Done

- 2026-09-26 — Removed stale `IDEA.md` and `TODO.md` (old junk; superseded by
  this doc and `notes/future-improvements.md`).
- 2026-09-26 — Enabled `rerere` and `merge.conflictStyle = zdiff3` in
  `roles/git/.gitconfig`; picked up from `notes/future-improvements.md`.
- 2026-09-26 — DRYed the role lists in `install.sh`: `is_valid_role()` loops
  against `SHARED_ROLES`/`MACOS_ROLE`/`LINUX_ROLE`, and `link_roles` derives
  its default platform role from the same variables; renamed `command` → `cmd`.
- 2026-09-26 — Pending work committed: the removals and deletions landed as
  `Cleanup` (d61735f5, already pushed); the stale README `.pi/` reference and
  the `install.sh` DRY fix followed in their own described commits.
- 2026-09-26 — Credential rotation complete: GitHub tokens revoked (all
  five verified `401`), Google key blocked by Google's leak detection,
  Linear/Raycast dead (services unused), Asana value an identifier only,
  Zed key identified as a Context7 API key and revoked. History scrubbed
  the same day: main squashed to one fresh commit, seven old remote
  branches deleted (all contained leaky commits), local refs/reflog
  purged. `security-scan.sh` green: 1 commit, no leaks, 0.4s.
  Runbook: `notes/credential-rotation.md`.

## Dropped

- 2026-09-26 — CI workflow in `.github/` (GitHub Actions): no need for CI in
  a personal dotfiles repo; `scripts/check.sh` (backlog) covers the same
  checks locally, and the empty `.github/` directory was removed.
