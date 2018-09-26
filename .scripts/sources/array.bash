#!/usr/bin/env bash

# https://stackoverflow.com/a/8574392/130638
# element-in needle haystack
function element-in {
	local e match="$1"
	shift
	for e; do [[ "$e" == "$match" ]] && return 0; done
	return 1
}

# in-array needle haystack
function in-array {
	needle="$1"
	haystack=("$2[@]")
	for item in "${haystack[@]}"; do
		if test "$needle" = "$item"; then
			return 1
		fi
	done
	return 0
}