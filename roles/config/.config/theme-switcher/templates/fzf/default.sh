# shellcheck shell=bash
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:-} \
  --multi \
  --color=bg+:{{fzf_bg_plus}} \
  --color=bg:{{fzf_bg}} \
  --color=spinner:{{fzf_spinner}} \
  --color=hl:{{fzf_hl}} \
  --color=fg:{{fzf_fg}} \
  --color=header:{{fzf_header}} \
  --color=info:{{fzf_info}} \
  --color=pointer:{{fzf_pointer}} \
  --color=marker:{{fzf_marker}} \
  --color=fg+:{{fzf_fg_plus}} \
  --color=prompt:{{fzf_prompt}} \
  --color=hl+:{{fzf_hl_plus}} \
  --color=border:{{fzf_border}} \
"
