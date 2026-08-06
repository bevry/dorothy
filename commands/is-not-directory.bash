#!/usr/bin/env bash

function __is_fs__operation {
	# checks
	if [[ -d $path ]]; then
		# does exist: is a symlink to a directory, or a directory
		return 21 # EISDIR 21 Is a directory
	elif [[ -e $path ]]; then
		# does exist and is not a symlink to a directory, nor a directory
		:
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
