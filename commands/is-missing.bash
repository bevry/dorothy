#!/usr/bin/env bash

function __is_fs__operation {
	# checks
	if [[ -e $path || -L $path ]]; then
		# exists: is a symlink (broken or otherwise, accessible or otherwise), file, or directory
		return 17 # EEXIST 17 File exists
	else
		# discern if inaccessible, missing
		is-accessible.bash -- "$path" || return $?
		# missing, which is what we want
	fi
}

source "$DOROTHY/sources/is-fs-operation.bash"
