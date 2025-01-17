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
	# stat: cannot statx '/home/runner/.cache/dorothy/5350/dir/subfile': Permission denied
	# MACOS
	# stat: /Users/balupton/.cache/dorothy/12776/dir/subfile: stat: Permission denied
	if stat -L "$path" 2>&1 | grep --quiet --regexp=': Permission denied$'; then
		exit 13 # EACCES 13 Permission denied
	fi
done
