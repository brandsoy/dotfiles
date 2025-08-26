# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
# source ~/.local/share/omarchy/default/bash/rc

## SHELL
# History control
shopt -s histappend
HISTCONTROL=ignoreboth
HISTSIZE=32768
HISTFILESIZE="${HISTSIZE}"

# Autocompletion
if [[ ! -v BASH_COMPLETION_VERSINFO && -f /usr/share/bash-completion/bash_completion ]]; then
	source /usr/share/bash-completion/bash_completion
fi

# Set complete path
export PATH="./bin:$HOME/.local/bin:$PATH"
set +h

## ALIASES
# File system
alias ls='eza -lh --group-directories-first --icons=auto'
alias lsa='ls -a'
alias lt='eza --tree --level=2 --long --icons --git'
alias lta='lt -a'
alias ff="fzf --preview 'bat --style=numbers --color=always {}'"
alias cd="zd"
zd() {
	if [ $# -eq 0 ]; then
		builtin cd ~ && return
	elif [ -d "$1" ]; then
		builtin cd "$1"
	else
		z "$@" && printf " \U000F17A9 " && pwd || echo "Error: Directory not found"
	fi
}
open() {
	xdg-open "$@" >/dev/null 2>&1 &
}

# Directories
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Tools
alias g='git'
alias d='docker'
alias r='rails'
n() { if [ "$#" -eq 0 ]; then nvim .; else nvim "$@"; fi; }

# Git
alias gcm='git commit -m'
alias gcam='git commit -a -m'
alias gcad='git commit -a --amend'

## FUNCTIONS
# Compression
compress() { tar -czf "${1%/}.tar.gz" "${1%/}"; }
alias decompress="tar -xzf"

# Write iso file to sd card
iso2sd() {
	if [ $# -ne 2 ]; then
		echo "Usage: iso2sd <input_file> <output_device>"
		echo "Example: iso2sd ~/Downloads/ubuntu-25.04-desktop-amd64.iso /dev/sda"
		echo -e "\nAvailable SD cards:"
		lsblk -d -o NAME | grep -E '^sd[a-z]' | awk '{print "/dev/"$1}'
	else
		sudo dd bs=4M status=progress oflag=sync if="$1" of="$2"
		sudo eject $2
	fi
}

# Format an entire drive for a single partition using ext4
format-drive() {
	if [ $# -ne 2 ]; then
		echo "Usage: format-drive <device> <name>"
		echo "Example: format-drive /dev/sda 'My Stuff'"
		echo -e "\nAvailable drives:"
		lsblk -d -o NAME -n | awk '{print "/dev/"$1}'
	else
		echo "WARNING: This will completely erase all data on $1 and label it '$2'."
		read -rp "Are you sure you want to continue? (y/N): " confirm
		if [[ "$confirm" =~ ^[Yy]$ ]]; then
			sudo wipefs -a "$1"
			sudo dd if=/dev/zero of="$1" bs=1M count=100 status=progress
			sudo parted -s "$1" mklabel gpt
			sudo parted -s "$1" mkpart primary ext4 1MiB 100%
			sudo mkfs.ext4 -L "$2" "$([[ $1 == *"nvme"* ]] && echo "${1}p1" || echo "${1}1")"
			echo "Drive $1 formatted and labeled '$2'."
		fi
	fi
}

# Transcode a video to a good-balance 1080p that's great for sharing online
transcode-video-1080p() {
	ffmpeg -i $1 -vf scale=1920:1080 -c:v libx264 -preset fast -crf 23 -c:a copy ${1%.*}-1080p.mp4
}

# Transcode a video to a good-balance 4K that's great for sharing online
transcode-video-4K() {
	ffmpeg -i $1 -c:v libx265 -preset slow -crf 24 -c:a aac -b:a 192k ${1%.*}-optimized.mp4
}

# Transcode PNG to JPG image that's great for shrinking wallpapers
transcode-png2jpg() {
	magick $1 -quality 95 -strip ${1%.*}.jpg
}

## PROMPT
# Technicolor dreams
force_color_prompt=yes
color_prompt=yes

# Simple prompt with path in the window/pane title and caret for typing line
PS1=$'\uf0a9 '
PS1="\[\e]0;\w\a\]$PS1"

## INIT
if command -v mise &>/dev/null; then
	eval "$(mise activate bash)"
fi

if command -v zoxide &>/dev/null; then
	eval "$(zoxide init bash)"
fi

if command -v fzf &>/dev/null; then
	if [[ -f /usr/share/fzf/completion.bash ]]; then
		source /usr/share/fzf/completion.bash
	fi
	if [[ -f /usr/share/fzf/key-bindings.bash ]]; then
		source /usr/share/fzf/key-bindings.bash
	fi
fi

## ENVS
# Editor used by CLI
export EDITOR="nvim"
export SUDO_EDITOR="$EDITOR"
export BAT_THEME=ansi

## INPUTRC
set meta-flag on
set input-meta on
set output-meta on
set convert-meta off
set completion-ignore-case on
set completion-prefix-display-length 2
set show-all-if-ambiguous on
set show-all-if-unmodified on

# Arrow keys match what you've typed so far against your command history
"\e[A": history-search-backward
"\e[B": history-search-forward
"\e[C": forward-char
"\e[D": backward-char

# Immediately add a trailing slash when autocompleting symlinks to directories
set mark-symlinked-directories on

# Do not autocomplete hidden files unless the pattern explicitly begins with a dot
set match-hidden-files off

# Show all autocomplete results at once
set page-completions off

# If there are more than 200 possible completions for a word, ask to show them all
set completion-query-items 200

# Show extra file information when completing, like `ls -F` does
set visible-stats on

# Be more intelligent when autocompleting by also looking at the text after
# the cursor. For example, when the current line is "cd ~/src/mozil", and
# the cursor is on the "z", pressing Tab will not autocomplete it to "cd
# ~/src/mozillail", but to "cd ~/src/mozilla". (This is supported by the
# Readline used by Bash 4.)
set skip-completed-text on

# Coloring for Bash 4 tab completions.
set colored-stats on

# Add your own exports, aliases, and functions here.
#
# Make an alias for invoking commands you use constantly
# alias p='python'
#
# Use VSCode instead of neovim as your default editor
# export EDITOR="code"
#
# Set a custom prompt with the directory revealed (alternatively use https://starship.rs)
# PS1="\W \[\e]0;\w\a\]$PS1"

alias ld='lazydocker'
alias lg='lazygit'


# pnpm
export PNPM_HOME="/home/mattis/.local/share/pnpm"
case ":$PATH:" in
*":$PNPM_HOME:"*) ;;
*) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

. "$HOME/.local/share/../bin/env"

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
