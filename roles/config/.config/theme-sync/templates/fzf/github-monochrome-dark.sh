# shellcheck shell=bash
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:-} \
  --highlight-line \
  --info=inline-right \
  --ansi \
  --layout=reverse \
  --border=none \
  --color=bg+:{{fzf_bg_plus}} \
  --color=bg:{{fzf_bg}} \
  --color=border:{{fzf_border}} \
  --color=fg:{{fzf_fg}} \
  --color=gutter:{{fzf_gutter}} \
  --color=hl+:{{fzf_hl_plus}} \
  --color=hl:{{fzf_hl}} \
  --color=info:{{fzf_info}} \
  --color=marker:{{fzf_marker}} \
  --color=pointer:{{fzf_pointer}} \
  --color=prompt:{{fzf_prompt}} \
  --color=query:{{fzf_query}}:regular \
  --color=scrollbar:{{fzf_scrollbar}} \
  --color=separator:{{fzf_separator}} \
  --color=spinner:{{fzf_spinner}} \
"
