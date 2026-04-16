#!/usr/bin/env bash

function __is_fs__operation {
	# checks
	if [[ -f $path ]]; then
		if [[ ! -r $path ]]; then
			# does exist: not readable however, so no ability to check contents
			return 13 # EACCES 13 Permission denied
		fi
		if [[ -s $path ]]; then
			# does exist: is a symlink to a non-empty file, or a non-empty file
			return 27 # EFBIG 27 File too large
		else
			# does exist: is a symlink to an empty file, or an empty file
			:
		fi
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
