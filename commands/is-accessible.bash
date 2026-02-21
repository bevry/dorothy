#!/usr/bin/env bash

function __is_fs__operation {
	# check accessibility, regardless of existence, by checking the stderr and discarding stdout of stat -L which -L checks the source and target of symlinks
	# LINUX
	# stat: cannot statx '<path>': Permission denied
	# MACOS
	# stat: <path>: stat: Permission denied
	if stat -L -- "$path" 2>&1 | grep --quiet --extended-regexp --regexp=': Permission denied$'; then
		return 13 # EACCES 13 Permission denied
	fi
}

source "$DOROTHY/sources/is-fs-operation.bash"
