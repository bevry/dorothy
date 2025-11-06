#!/usr/bin/env bash

if [[ $1 == '--' ]]; then
	shift
fi
if [[ $# -eq 0 ]]; then
	exit 22 # EINVAL 22 Invalid argument
fi
while [[ $# -ne 0 ]]; do
	if [[ -z $1 ]]; then
		exit 22 # EINVAL 22 Invalid argument
	fi
	path="$1"
	shift

	# check accessibility, regardless of existence, by checking the stderr and discarding stdout of stat -L which -L checks the source and target of symlinks
	# LINUX
	# stat: cannot statx '<path>': Permission denied
	# MACOS
	# stat: <path>: stat: Permission denied
	if stat -L -- "$path" 2>&1 | grep --quiet --extended-regexp --regexp=': Permission denied$'; then
		printf '%s\n' "$path" >>"$TMPDIR/is-fs-failed-paths"
		exit 13 # EACCES 13 Permission denied
	fi
done
