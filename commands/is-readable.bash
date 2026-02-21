#!/usr/bin/env bash

function __is_fs__operation {
	# checks
	if [[ -r $path ]]; then
		# does exist: is readable
		:
	elif [[ -e $path ]]; then
		# does exist: is not readable
		return 93 # ENOATTR 93 Attribute not found
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
