#!/usr/bin/env zsh
function __print_string {
	if test "$#" -ne 0; then
		printf '%s' "$*"
	fi
}
function __print_line {
	if test "$#" -ne 0; then
		printf '%s' "$*"
	fi
	printf '\n'
}
function __print_lines {
	if test "$#" -ne 0; then
		printf '%s\n' "$@"
	fi
}
