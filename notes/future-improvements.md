# Dotfiles: future improvements

Captured for later implementation. Current setup is already strong; prioritize practical additions over more apps.

## Highest-value candidates

1. **Git worktrees for coding agents**
   - Use one worktree, branch, and tmux/sesh session per concurrent task.
   - Avoid multiple agents and editors modifying the same checkout.
   - No extra worktree manager needed initially.

2. **Restic**
   - Syncthing is synchronization, not an independent backup.
   - Use Time Machine for Mac recovery and Restic for encrypted, versioned backups.
   - Prioritize Obsidian, projects, local configuration, and secrets.
   - Exclude reproducible caches, container images, and model weights where appropriate.
   - Test restoring files.

## Infrastructure matches

3. **SOPS**
   - Complements existing `age`, Ansible, Terraform/OpenTofu, Pulumi, Azure CLI, and Kubernetes tooling.
   - Encrypt YAML/JSON configuration for safe Git storage.
   - Keep decryption keys outside the repository and limit agent access to decrypted secrets.

4. **Difftastic**
   - Syntax-aware diffs for reviewing large or AI-generated changes.
   - Use on demand before replacing Git/lazygit defaults.

## Existing setup improvements

- Use project-local mise files to pin important runtimes and build tools instead of relying on `latest` globally.
- Make Kubernetes context/namespace visible in Starship only where useful, especially infrastructure directories.
- Make production Kubernetes contexts unmistakable and use least-privilege credentials.

## macOS display option

Choose one only if there is a real need:

- **MonitorControl:** keyboard brightness/volume control for supported displays.
- **BetterDisplay:** display scaling, HiDPI, or display-management problems.

## Suggested starting shortlist

Atuin is done (installed, wired to `Ctrl-R`, configured local-only in
`roles/config/.config/atuin/config.toml`); enable sync deliberately only
after configuring exclusions.

Git worktrees and a tested independent backup.
Avoid adding more launchers, terminals, window managers, or database tools for now; coverage is already extensive.
