#!/usr/bin/env bash

function __is_fs__operation {
	# checks
	if [[ -L $path ]]; then
		# is a symlink (broken or otherwise, accessible or otherwise)
		:
	elif [[ -e $path ]]; then
		# does exist: but not a symlink
		return 79 # EFTYPE 79 Inappropriate file type or format
	else
		# discern if inaccessible, missing
		is-accessible.bash -- "$path" || return $?
		return 2 # ENOENT 2 No such file or directory
	fi
}

source "$DOROTHY/sources/is-fs-operation.bash"
