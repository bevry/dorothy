#!/usr/bin/env bash

function __is_fs__operation {
	if [[ -e $path || -L $path ]]; then
		# exists: is a symlink (broken or otherwise, accessible or otherwise), file, or directory
		:
	else
		# discern if inaccessible, missing
		is-accessible.bash -- "$path" || return $? # inaccessibility crashes
		return 2                                   # ENOENT 2 No such file or directory
	fi
}

source "$DOROTHY/sources/is-fs-operation.bash"
