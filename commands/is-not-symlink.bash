#!/usr/bin/env bash

function __is_fs__operation {
	# checks
	if [[ -L $path ]]; then
		# does exist: is a symlink (accessible or otherwise, broken or otherwise)
		return 79 # EFTYPE 79 Inappropriate file type or format
	elif [[ -e $path ]]; then
		# does exist and is not a symlink (accessible or otherwise, broken or otherwise)
		:
	else
		# discern if inaccessible, missing
		is-accessible.bash -- "$path" || return $?
		return 2 # ENOENT 2 No such file or directory
	fi
}

source "$DOROTHY/sources/is-fs-operation.bash"
