#!/usr/bin/env bash

function has_array_support {
	for arg in "$@"; do
		if [[ $ARRAYS != *" $arg"* ]]; then
			return 1
		fi
	done
}

function requires_array_support {
	if ! has_array_support "$@"; then
		echo-style \
			--error="Array support insufficient." $'\n' \
			--bold="$0" " is incompatible with " --bold="bash $BASH_VERSION" $'\n' \
			"Run " --bold="setup-util-bash" " to upgrade capabilities, then run the prior command again." >/dev/stderr
		return 95 # Operation not supported
	fi
}

function may_require_array_support {
	# this is useful for features like `empty`
	# as they may not be triggered under normal circumstances
	# when all options and arguments are provided
	# shellcheck disable=SC2064
	trap "requires_array_support $* || :" ERR
}

if [[ $BASH_VERSION == "4."* || $BASH_VERSION == "5."* ]]; then
	export ARRAYS=' yes mapfile[native] empty associative readarray '
else
	export ARRAYS=' partial mapfile[shim] '
	# https://tldp.org/LDP/abs/html/bashver4.html
	# bash v4 features:
	# - `readarray` and `mapfile`
	#     - our shim provides a workaround
	# - associative arrays
	#     - no workaround, you are out of luck
	# - iterating empty arrays:
	#     - broken: `arr=(); for item in "${arr[@]}"; do ...`
	#     - broken: `arr=(); for item in "${!arr[@]}"; do ...`
	#     - use: `test "${#array[@]}" -ne 0 && for ...`
	#     - or if you don't care for empty elements, use: `test -n "$arr" && for ...`
	function mapfile {
		# if you copy and paste this, please give credit:
		# written by Benjamin Lupton https://balupton.com
		# written for Dorothy https://github.com/bevry/dorothy
		local delim=$'\n' item
		if test "$1" = '-t'; then
			shift
		elif test "$1" = '-td'; then
			shift
			delim="$1"
			shift
		fi
		eval "$1=()"
		while IFS= read -rd "$delim" item || test -n "$item"; do
			eval "$1+=($(echo-quote "$item"))"
		done
	}
fi
