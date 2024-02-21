#!/usr/bin/env zsh
function print_string {
	if test "$#" -ne 0; then
		printf '%s' "$*"
	fi
}
function print_line {
	if test "$#" -ne 0; then
		printf '%s' "$*"
	fi
	printf '\n'
}
function print_lines {
	if test "$#" -ne 0; then
		printf '%s\n' "$@"
	fi
}
