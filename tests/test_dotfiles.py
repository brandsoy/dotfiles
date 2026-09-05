#!/usr/bin/env python3
"""Offline smoke/regression checks. Only temporary homes/repos are modified.

Run: python3 tests/test_dotfiles.py
Requires: bash, zsh, git, and GNU Stow.
"""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile

REPO = Path(__file__).resolve().parents[1]


def put(path, text):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text)


def copy(relative, root):
    dest = root / relative
    dest.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(REPO / relative, dest)


def run(args, env, cwd, ok=True):
    result = subprocess.run(args, env=env, cwd=cwd, text=True, capture_output=True, timeout=30)
    if ok:
        assert result.returncode == 0, (args, result.stdout, result.stderr)
    else:
        assert result.returncode != 0, args
    return result


def test_plugin_migration(binaries):
    with tempfile.TemporaryDirectory(prefix="dotfiles plugins-") as temporary:
        root = Path(temporary)
        home, repo, upstream = root / "home", root / "repo", root / "upstream"
        (home / ".tmux/plugins/tpm").mkdir(parents=True)  # No TPM download.
        env = {
            "HOME": str(home), "PATH": f"{Path(binaries['git']).parent}:/usr/bin:/bin",
            "GIT_CONFIG_NOSYSTEM": "1", "GIT_ALLOW_PROTOCOL": "file",
            "GIT_AUTHOR_NAME": "Test", "GIT_AUTHOR_EMAIL": "test@example.com",
            "GIT_COMMITTER_NAME": "Test", "GIT_COMMITTER_EMAIL": "test@example.com",
        }
        def git(*args, cwd=repo, ok=True):
            return run([binaries["git"], *args], env, cwd, ok=ok)

        root.mkdir(exist_ok=True)
        git("init", "-q", str(upstream), cwd=root)
        put(upstream / "plugin.zsh", "# pinned version\n")
        git("add", ".", cwd=upstream)
        git("commit", "-qm", "pin", cwd=upstream)
        pin = git("rev-parse", "HEAD", cwd=upstream).stdout.strip()
        put(upstream / "plugin.zsh", "# newer upstream version\n")
        git("commit", "-qam", "newer", cwd=upstream)
        git("init", "-q", str(repo), cwd=root)
        copy("install.sh", repo)
        legacy = "roles/config/.config/zsh/plugins/zsh-autosuggestions"
        existing = "roles/config/.config/zsh/plugins/zsh-vi-mode"
        put(repo / legacy / "plugin.zsh", "# preserve local changes\n")
        git("config", "-f", ".gitmodules", "submodule.legacy.path", legacy)
        git("config", "-f", ".gitmodules", "submodule.legacy.url", str(upstream))
        git("add", ".gitmodules")
        git("update-index", "--add", "--cacheinfo", f"160000,{pin},{legacy}")
        git("submodule", "add", "-q", str(upstream), existing)
        put(repo / existing / "local.txt", "keep initialized plugin\n")
        # Reproduce the reported error: files exist, but there is no Git metadata.
        result = git("submodule", "update", "--init", "--recursive", ok=False)
        assert "not an empty directory" in result.stderr
        command = [binaries["bash"], "-c", 'source "$1"; install_plugins', "test", str(repo / "install.sh")]
        run(command, env, root)
        backups = list((home / ".local/state/dotfiles").glob("plugin-backup.*"))
        assert len(backups) == 1
        assert (backups[0] / legacy / "plugin.zsh").read_text() == "# preserve local changes\n"
        assert git("rev-parse", "HEAD", cwd=repo / legacy).stdout.strip() == pin
        assert (repo / legacy / "plugin.zsh").read_text() == "# pinned version\n"
        assert (repo / existing / "local.txt").read_text() == "keep initialized plugin\n"
        run(command, env, root)  # Initialized repos are left alone on subsequent runs.
        assert list((home / ".local/state/dotfiles").glob("plugin-backup.*")) == backups
    print("OK: legacy plugin backup, pinned initialization, repeat installation (local Git only)")


def main():
    binaries = {name: shutil.which(name) for name in ("bash", "zsh", "git", "stow")}
    assert all(binaries.values()), "Install bash, zsh, git, and stow first"
    test_plugin_migration(binaries)
    with tempfile.TemporaryDirectory(prefix="dotfiles test-") as temporary:
        root = Path(temporary)
        repo, home, mockbin = root / "repo", root / "home", root / "bin"
        home.mkdir()
        mockbin.mkdir()
        # Do not inherit credentials, XDG paths, or tmux sockets from the caller.
        env = {
            "HOME": str(home), "PATH": f"{mockbin}:/usr/bin:/bin",
            "XDG_CONFIG_HOME": str(home / ".config"),
            "XDG_CACHE_HOME": str(home / ".cache"),
            "XDG_DATA_HOME": str(home / ".local/share"),
            "XDG_STATE_HOME": str(home / ".local/state"),
            "GIT_CONFIG_NOSYSTEM": "1", "TERM": "xterm-256color",
            "LOG": str(root / "commands"), "TEST_OS": "arch",
        }
        # All potentially mutating/integrating tools are inert and recorded.
        for name in ("sudo", "curl", "brew", "chsh", "paru", "starship", "mise", "zoxide", "fzf", "kitty", "tmux", "bat", "rpm"):
            body = 'printf "%s\\n" "${0##*/} $*" >> "$LOG"\n'
            if name == "tmux":
                body += "exit 1\n"  # No live tmux server to refresh.
            elif name == "rpm":
                body += 'exit "${RPM_STATUS:-1}"\n'
            elif name == "bat":
                body += 'printf "Theme a\\nTheme b\\n"\n'
            put(mockbin / name, "#!/bin/sh\n" + body)
            (mockbin / name).chmod(0o755)
        for name in ("git", "stow"):
            (mockbin / name).symlink_to(binaries[name])

        copy("install.sh", repo)
        copy(".stowrc", repo)
        copy("scripts/theme-sync.sh", repo)
        copy("roles/config/.stow-local-ignore", repo)
        copy("roles/macos-config/.stow-local-ignore", repo)
        for role in ("agents", "bin", "blocklists", "git", "tmux", "zshenv", "linux-config", "macos-config"):
            put(repo / "roles" / role / f".{role}-example", "example\n")
        for relative in ("kitty/kitty.conf", "alacritty/alacritty.toml", "bat/config", "btop/btop.conf", "lazygit/config.yml", "starship.toml"):
            copy("roles/config/.config/" + relative, repo)
        for relative in (".zshrc", "fzf.zsh", "aliases.zsh", "bindings.zsh", "plugins.zsh", "prompt.zsh", "hooks.zsh"):
            copy("roles/config/.config/zsh/" + relative, repo)
        copy("roles/zshenv/.zshenv", repo)
        for relative in (".gitconfig", ".gitconfig-work", ".gitconfig-personal"):
            copy("roles/git/" + relative, repo)
        copy("roles/linux-config/.gitconfig-platform", repo)
        copy("roles/macos-config/.gitconfig-platform", repo)
        for relative in ("Brewfile",):
            copy("roles/packages-macos/" + relative, repo)
        copy("roles/packages-arch/Archfile", repo)
        copy("roles/packages-redhat/Redhatfile", repo)

        # Ignored files exist locally but must not be deployed.
        config = repo / "roles/config/.config"
        for relative in ("zsh/.zcompcache/cache", "zsh/.zsh_sessions/session", "zsh/secrets.zsh", "zsh/.zshrc_old", "ghostty/auto/theme.ghostty", "theme-sync/current", "yazi/theme.toml", "eza/theme.yml", "tmux/theme.conf"):
            put(config / relative, "local-only\n")
        put(repo / "roles/macos-config/.config/karabiner/automatic_backups/local.json", "{}\n")
        put(repo / "roles/macos-config/.config/karabiner/karabiner.json", "{}\n")

        # No arguments/help/errors must not install anything or link any role.
        for args, ok in (([], True), (["--help"], True), (["profile", "linux-server"], False), (["links", "config", "invalid"], False), (["packages", "extra"], False)):
            run([binaries["bash"], str(repo / "install.sh"), *args], env, root, ok=ok)
        assert not (root / "commands").exists()
        assert not list(home.iterdir())

        # Source allows deterministic OS tests without faking host /etc files.
        driver = 'source "$1"; detect_os() { OS="$TEST_OS"; }; load_homebrew() { :; }; main "${@:2}"'
        def install(*args):
            return run([binaries["bash"], "-c", driver, "test", str(repo / "install.sh"), *args], env, root)

        install("links")
        assert (home / ".gitconfig").is_symlink()
        assert (home / ".gitconfig-platform").is_symlink()
        assert (home / ".config/kitty/kitty.conf").is_symlink()
        assert not (home / ".config").is_symlink()
        assert not (home / ".config/zsh").is_symlink()
        assert (home / ".linux-config-example").is_symlink()
        assert not (home / ".macos-config-example").exists()
        for relative in ("zsh/.zcompcache", "zsh/.zsh_sessions", "zsh/secrets.zsh", "zsh/.zshrc_old", "ghostty/auto", "theme-sync/current", "yazi/theme.toml", "eza/theme.yml", "tmux/theme.conf"):
            assert not (home / ".config" / relative).exists(), relative
        install("links")  # Restowing is idempotent.
        # A conflicting personal file must survive; no role may be partially linked.
        target = home / ".config/kitty/kitty.conf"
        target.unlink()
        target.write_text("personal config\n")
        (home / ".agents-example").unlink()
        run([binaries["bash"], "-c", driver, "test", str(repo / "install.sh"), "links"], env, root, ok=False)
        assert target.read_text() == "personal config\n"
        assert not (home / ".agents-example").exists()
        target.unlink()
        install("links")
        assert not (root / "commands").exists()
        env["TEST_OS"] = "macos"
        # A host only deploys one platform; remove the Linux include for this check.
        (home / ".gitconfig-platform").unlink()
        install("links", "macos-config")
        assert not (home / ".config/karabiner/automatic_backups").exists()

        # Package operations are mocked, including sudo; no installs/downloads.
        for os_name in ("macos", "arch", "fedora"):
            env["TEST_OS"] = os_name
            install("packages")
        commands = (root / "commands").read_text()
        assert "brew bundle --file=" in commands
        assert "sudo pacman -Syu --needed" in commands
        assert "paru -S" in commands
        assert "sudo dnf install" in commands
        assert not any(line.startswith(("chsh ", "curl ")) for line in commands.splitlines())

        # Both platform credential files and recursive identity includes work.
        (home / ".gitconfig-platform").unlink()
        shutil.copy2(REPO / "roles/linux-config/.gitconfig-platform", home / ".gitconfig-platform")
        for directory, expected in (("work/nested/repo", "mattis.brandsoy@fjordbase.no"), ("personal/repo", "mattis.dev@icloud.com")):
            project = home / "Developer/git" / directory
            run([binaries["git"], "init", "-q", str(project)], env, root)
            email = run([binaries["git"], "config", "user.email"], env, project).stdout.strip()
            assert email == expected, (directory, email)
        assert run([binaries["git"], "config", "--global", "--includes", "credential.helper"], env, root).stdout.strip() == "cache"
        shutil.copy2(REPO / "roles/macos-config/.gitconfig-platform", home / ".gitconfig-platform")
        assert run([binaries["git"], "config", "--global", "--includes", "credential.helper"], env, root).stdout.strip() == "osxkeychain"

        # Native theme includes: config sources stay byte-identical after switching.
        themes = home / ".config/theme-sync/themes"
        for name in ("a", "b"):
            directory = themes / name
            put(directory / "theme.env", f'''GHOSTTY_THEME="{name}"
ALACRITTY_IMPORT="$XDG_CONFIG_HOME/theme-sync/themes/{name}/alacritty.toml"
KITTY_INCLUDE="$XDG_CONFIG_HOME/theme-sync/themes/{name}/kitty.conf"
NVIM_THEME="{name}"
BAT_THEME="Theme {name}"
FZF_THEME_FILE="$XDG_CONFIG_HOME/theme-sync/themes/{name}/fzf.sh"
VSCODE_THEME="Theme {name}"
''')
            put(directory / "kitty.conf", f"# theme {name}\n")
            put(directory / "alacritty.toml", f"# theme {name}\n")
        put(themes / "a/starship.toml", "# theme a\n")
        with (themes / "a/theme.env").open("a") as f:
            f.write('BAT_THEME_FILE="$XDG_CONFIG_HOME/theme-sync/themes/a/SupaTheme.tmTheme"\n')
        put(themes / "a/SupaTheme.tmTheme", "new Bat theme\n")
        old_bat = config / "bat/themes/SupaTheme.tmTheme"
        put(old_bat, "old preserved Bat theme\n")
        (home / ".config/bat/themes").mkdir(parents=True, exist_ok=True)
        (home / ".config/bat/themes/SupaTheme.tmTheme").symlink_to(old_bat)
        (home / ".config/ghostty/auto").mkdir(parents=True, exist_ok=True)
        dangling_target = repo / "removed-generated-file"
        (home / ".config/ghostty/auto/theme.ghostty").symlink_to(dangling_target)
        put(themes / "a/lazygit.yml", "gui:\n  theme: {}\n")
        put(themes / "a/yazi.theme.toml", "# theme a\n")
        put(themes / "a/eza.theme.yml", "# theme a\n")
        put(themes / "a/tmux.theme.conf", "# theme a\n")
        # Existing legacy state is migrated without copying stale absolute exports.
        put(home / ".config/theme-sync/current", "a\n")
        put(home / ".config/theme-sync/current.env", 'export STARSHIP_CONFIG="/old/machine/config"\n')
        put(home / ".config/theme-sync/mode.env", 'THEME_LIGHT="b"\nTHEME_DARK="a"\n')
        before = {p: p.read_bytes() for p in (repo / "roles").rglob("*") if p.is_file()}
        vscode = [home / "Library/Application Support/Code/User/settings.json", home / ".config/Code/User/settings.json"]
        jsonc = '{\n // Valid VS Code JSONC\n "editor.fontSize": 14,\n}\n'
        for path in vscode:
            put(path, jsonc)
        theme_cmd = [binaries["bash"], str(repo / "scripts/theme-sync.sh")]
        run(theme_cmd + ["current"], env, root)
        state = home / ".local/state/theme-sync"
        assert (state / "current").read_text() == "a\n"
        assert "/old/machine" not in (state / "current.env").read_text()
        assert (state / "mode.env").read_text() == 'THEME_LIGHT="b"\nTHEME_DARK="a"\n'
        run(theme_cmd + ["set", "a"], env, root)
        assert (state / "lazygit.yml").exists()
        assert not (home / ".config/ghostty/auto/theme.ghostty").is_symlink()
        assert not dangling_target.exists()
        assert (home / ".config/bat/themes/SupaTheme.tmTheme").read_text() == "new Bat theme\n"
        assert not (home / ".config/bat/themes/SupaTheme.tmTheme").is_symlink()
        assert "," in (state / "current.env").read_text()
        env["STARSHIP_CONFIG"] = str(themes / "a/starship.toml")
        run(theme_cmd + ["set", "b"], env, root)
        assert not (state / "lazygit.yml").exists()
        assert str(themes / "a/starship.toml") not in (state / "current.env").read_text()
        assert (home / ".config/kitty/auto/theme.conf").read_text() == "# theme b\n"
        assert (home / ".config/alacritty/auto/theme.toml").read_text() == "# theme b\n"
        for relative in ("yazi/theme.toml", "eza/theme.yml", "tmux/theme.conf"):
            assert not (home / ".config" / relative).exists()
        run(theme_cmd + ["mode-set", "light", "a"], env, root)
        run(theme_cmd + ["set", "missing"], env, root, ok=False)
        (themes / "a/kitty.conf").unlink()
        run(theme_cmd + ["set", "a"], env, root, ok=False)
        assert (state / "current").read_text() == "b\n"
        assert all(p.read_bytes() == content for p, content in before.items())
        assert all(p.read_text() == jsonc for p in vscode)

        # A partial/offline shell creates its directories and loads no plugins online.
        shell = 'source "$HOME/.zshenv"; source "$ZDOTDIR/.zshrc"; [[ -d "$XDG_CACHE_HOME/zsh" && -d "$XDG_STATE_HOME/zsh" ]]; alias ld; print -r -- "$STARSHIP_CONFIG"'
        result = run([binaries["zsh"], "-dfi", "-c", shell], env, root)
        assert "ld=lazydocker" in result.stdout
        assert "command not found" not in result.stderr, result.stderr
        assert str(home / ".config/starship.toml") in result.stdout
        assert not any(line.startswith("curl ") for line in (root / "commands").read_text().splitlines())
    print("OK: installer safety, Stow isolation, platform packages, Git identity, theme state/JSONC safety, offline Zsh")


if __name__ == "__main__":
    main()
