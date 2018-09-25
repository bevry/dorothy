#!/usr/bin/env bash

# https://stackoverflow.com/a/8574392/130638
function element_in {
	local e match="$1"
	shift
	for e; do [[ "$e" == "$match" ]] && return 0; done
	return 1
}
