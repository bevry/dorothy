#!/usr/bin/env zsh
# zsh has **/* support, but needs an option to disable errors if missing
source "$DOROTHY/sources/zsh.zsh"

# prevents:
# > expand-path -- '*.{otf,ttf}'
# *.otf
# Anonymice Nerd Font Complete Mono Windows Compatible.ttf
# Anonymice Nerd Font Complete Mono.ttf
# Anonymice Nerd Font Complete Windows Compatible.ttf
# Anonymice Nerd Font Complete.ttf
setopt nullglob

# prevents:
# (eval):1: no matches found: *.otf
unsetopt nomatch

# achieves:
# Anonymice Nerd Font Complete Mono Windows Compatible.ttf
# Anonymice Nerd Font Complete Mono.ttf
# Anonymice Nerd Font Complete Windows Compatible.ttf
# Anonymice Nerd Font Complete.ttf

# zsh is case-insensitive, so cannot use path as it becomes PATH
for _path in "$@"; do
	eval __print_lines "$(echo-escape-spaces -- "$_path")"
done
