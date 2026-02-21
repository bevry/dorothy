#!/usr/bin/env bash

function __is_fs__operation {
	if [[ -d $path ]]; then
		# accessible and exists, is an unbroken symlink to a directory, or a directory
		:
	elif [[ -e $path ]]; then
		# accessible and exists, but not an unbroken symlink to a directory, nor a directory
		return 20 # NOTDIR 20 Not a directory
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
