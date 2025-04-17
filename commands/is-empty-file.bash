#!/usr/bin/env bash

if [[ $1 == '--' ]]; then
	shift
fi
if [[ $# -eq 0 ]]; then
	exit 22 # EINVAL 22 Invalid argument
fi
while [[ $# -ne 0 ]]; do
	if [[ -z $1 ]]; then
		exit 22 # EINVAL 22 Invalid argument
	fi
	path="$1"
	shift

	# checks
	if [[ -f $path ]]; then
		if [[ ! -r $path ]]; then
			# does exist: not readable however, so no ability to check contents
			printf '%s\n' "$path" >>"$XDG_CACHE_HOME/is-fs-failed-paths"
			exit 13 # EACCES 13 Permission denied
		fi
		if [[ -s $path ]]; then
			# does exist: is a symlink to a non-empty file, or a non-empty file
			printf '%s\n' "$path" >>"$XDG_CACHE_HOME/is-fs-failed-paths"
			exit 27 # EFBIG 27 File too large
		else
			# does exist: is a symlink to an empty file, or an empty file
			continue
		fi
	elif [[ -e $path ]]; then
		# does exist: not a symlink to a file, nor a file
		printf '%s\n' "$path" >>"$XDG_CACHE_HOME/is-fs-failed-paths"
		exit 79 # EFTYPE 79 Inappropriate file type or format
	else
		# discern if inaccessible, broken, missing
		is-accessible.bash -- "$path" || exit
		if [[ -L $path ]]; then
			# broken symlink
			printf '%s\n' "$path" >>"$XDG_CACHE_HOME/is-fs-failed-paths"
			exit 9 # EBADF 9 Bad file descriptor
		fi
		printf '%s\n' "$path" >>"$XDG_CACHE_HOME/is-fs-failed-paths"
		exit 2 # ENOENT 2 No such file or directory
	fi
done
exit 0
