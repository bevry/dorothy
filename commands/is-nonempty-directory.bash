#!/usr/bin/env bash

function __is_fs__operation {
	# checks
	if [[ -d $path ]]; then
		if [[ ! -r $path || ! -x $path ]]; then
			# does exist: not readable/executable however, so no ability to check contents, as would get:
			# ls: $path: Permission denied
			return 13 # EACCES 13 Permission denied
		fi
		if [[ -z "$(ls -A "$path")" ]]; then
			# does exist: is a symlink to an empty directory, or an empty directory
			return 79 # EFTYPE 79 Inappropriate file type or format
		else
			# does exist: is a symlink to a non-empty directory, or a non-empty directory
			:
		fi
	elif [[ -e $path ]]; then
		# does exist: not a symlink to a directory, nor a directory
		return 20 # ENOTDIR 20 Not a directory
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
