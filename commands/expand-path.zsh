#!/usr/bin/env zsh
# zsh has **/* support, but needs an option to disable errors if missing
source "$DOROTHY/sources/zsh.zsh"

# cd ~/Library/Fonts; expand-path.zsh -- '*.{otf,ttf}'; # should output:
# Anonymice Nerd Font Complete Mono Windows Compatible.ttf
# Anonymice Nerd Font Complete Mono.ttf
# Anonymice Nerd Font Complete Windows Compatible.ttf
# Anonymice Nerd Font Complete.ttf

# adjust options to prevent issues on edge cases:
setopt nullglob    # prevents: cd ~; expand-path.zsh -- '*.{otf,ttf}'; #  *.otf \n *.ttf
unsetopt nomatch   # prevents: cd ~; expand-path.zsh -- '*.{otf,ttf}'; # (eval):1: no matches found: *.otf

# trim -- prefix
if [[ "${1-}" = '--' ]]; then
	shift
fi

# proceed
# zsh is case-insensitive, so cannot use path as it becomes PATH
for _path in "$@"; do
	eval __print_lines "$(echo-escape-spaces -- "$_path")"
done
