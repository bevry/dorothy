#!/usr/bin/env bash

function __is_fs__operation {
	# checks
	if [[ -e $path ]]; then
		# exists: is an unbroken symlink, a file, or a directory
		:
	else
		# discern if inaccessible, missing
		is-accessible.bash -- "$path" || return $?
		if [[ -L $path ]]; then
			# broken symlink
			return 9 # EBADF 9 Bad file descriptor
		fi
		return 2 # ENOENT 2 No such file or directory
	fi
}

source "$DOROTHY/sources/is-fs-operation.bash"
