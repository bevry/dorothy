#!/usr/bin/env bash

if [[ $1 == '--' ]]; then
	shift
fi
if [[ $# -eq 0 ]]; then
	exit 22 # EINVAL 22 Invalid argument
fi
remove=()
while [[ $# -ne 0 ]]; do
	if [[ -z $1 ]]; then
		exit 22 # EINVAL 22 Invalid argument
	fi
	if [[ -L $1 && ! -e $1 ]]; then
		remove+=("$1")
	fi
	shift
done
if [[ ${#remove[@]} -ne 0 ]]; then
	rm -fv -- "${remove[@]}"
fi
exit 0
