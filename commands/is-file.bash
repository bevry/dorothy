#!/usr/bin/env bash

function __is_fs__operation {
	# checks
	if [[ -f $path ]]; then
		# does exist: is a symlink to a file, or a file
		:
	elif [[ -e $path ]]; then
		# does exist: not a symlink to a file, nor a file
		return 79 # EFTYPE 79 Inappropriate file type or format
	else
		# discern if inaccessible, broken, missing
		is-accessible.bash -- "$path" || return $?
		if [[ -L $path ]]; then
			# broken symlink
			return 9 # EBADF 9 Bad file descriptor
		fi
		return 2 # ENOENT 2 No such file or directory
	fi
}

source "$DOROTHY/sources/is-fs-operation.bash"
