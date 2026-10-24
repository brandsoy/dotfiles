# Automatically run ls when changing directories
autoload -Uz add-zsh-hook
auto_ls_on_cd() {
	emulate -L zsh
	la
}
add-zsh-hook chpwd auto_ls_on_cd
safe-opencode() {
	"$HOME/.config/sandbox-exec/run-sandboxed.sh" -- opencode --standalone "$@"
}

safe-pi() {
	"$HOME/.config/sandbox-exec/run-sandboxed.sh" -- pi "$@"
}

safe-pig() {
	"$HOME/.config/sandbox-exec/run-sandboxed.sh" -- pig "$@"
}

safe-pi-bolt() {
	"$HOME/.config/sandbox-exec/run-sandboxed.sh" -- pi-bolt "$@"
}

safe-vibe() {
	"$HOME/.config/sandbox-exec/run-sandboxed.sh" -- vibe "$@"
}

safe-cagent() {
	"$HOME/.config/sandbox-exec/run-sandboxed.sh" -- cagent "$@"
}

safe-tiny-agents() {
	"$HOME/.config/sandbox-exec/run-sandboxed.sh" -- tiny-agents "$@"
}

safe-herdr-agent-picker() {
	"$HOME/.config/sandbox-exec/run-sandboxed.sh" -- herdr-agent-picker "$@"
}
