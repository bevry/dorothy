#!/usr/bin/env bash
source "$DOROTHY/sources/bash.bash"

function has_array_support {
	for arg in "$@"; do
		if [[ $ARRAYS != *" $arg"* ]]; then
			return 1
		fi
	done
}

function requires_array_support {
	if ! has_array_support "$@"; then
		echo-style --error="Array support insufficient, required: " --code="$*"
		require_latest_bash
	fi
}

# Bash version compatibility: https://github.com/bevry/dorothy/discussions/151
ARRAYS=''
if test "$BASH_VERSION_MAJOR" -ge '5'; then
	ARRAYS+=' mapfile[native] readarray[native] empty[native]'
	if test "$BASH_VERSION_MINOR" -ge '1'; then
		ARRAYS+=' associative'
	fi
elif test "$BASH_VERSION_MAJOR" -ge '4'; then
	ARRAYS+=' mapfile[native] readarray[native]'
	if test "$BASH_VERSION_MINOR" -ge '4'; then
		ARRAYS+=' empty[native]'
	else
		ARRAYS+=' empty[shim]'
		set +u # disable nounset to prevent crashes on empty arrays
	fi
elif test "$BASH_VERSION_MAJOR" -ge '3'; then
	ARRAYS+=' mapfile[shim] empty[shim]'
	set +u # disable nounset to prevent crashes on empty arrays
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
ARRAYS+=' '
