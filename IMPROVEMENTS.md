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
- Comments explain *why*, never *what*. Keep the good ones ("Do not inherit
  optional mappings…", "GitHub-backed mise backends otherwise share the
  unauthenticated API rate limit").
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

### Minor

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
- 2026-09-26 — `theme-sync.sh` cleanup: `die()` helper with standardized
  `exit`/`return` mix, `apply_theme` split into `apply_terminal_themes` /
  `apply_cli_themes` / `apply_theme_overlays`, `pause()` helper in the TUI,
  and `require_theme()` as the single theme validator.
- 2026-09-26 — Formatting pass: `shfmt -i 4` across all own shell scripts
  (`shfmt` added to the Brewfile), lint findings fixed (dead icon variables
  in the tmux minimal theme, pattern quoting in `keybinds`), and
  `scripts/check.sh` added as the single entry point for shfmt + shellcheck
  (warnings as errors) + tests; README points at it.
- 2026-09-26 — Split `tests/test_dotfiles.py` into seven named tests with
  per-test temp homes (`make_repo`/`make_env` builders); failures now
  isolate to one test instead of aborting the whole run.
- 2026-09-26 — Removed Alacritty (terminal no longer used): config role,
  15 theme assets and their `ALACRITTY_IMPORT` lines, theme-sync target
  and apply path, SupaTheme extras (submodule pin updated), generator
  output, stow ignore, and doc references; live `~/.config/alacritty`
  cleaned up. The `generate-supatheme.sh` single-write backlog item is
  moot and dropped.
- 2026-09-26 — Removed Arch Linux support (distro no longer used): the
  detect/install paths, the `packages-arch` role, and the paru config;
  README and tests updated (Fedora is the only Linux target). The
  `read_manifest_words` backlog item is moot with a single remaining
  parse loop and was dropped.

## Dropped

- 2026-09-26 — CI workflow in `.github/` (GitHub Actions): no need for CI in
  a personal dotfiles repo; `scripts/check.sh` (backlog) covers the same
  checks locally, and the empty `.github/` directory was removed.
