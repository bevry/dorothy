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
	if [[ -d $path ]]; then
		if [[ ! -r $path || ! -x $path ]]; then
			# does exist: not readable/executable however, so no ability to check contents, as would get:
			# ls: $path: Permission denied
			exit 13 # EACCES 13 Permission denied
		fi
		if [[ -n "$(ls -A "$path")" ]]; then
			# does exist: is a symlink to a non-empty directory, or a non-empty directory
			exit 66 # ENOTEMPTY 66 Directory not empty
		else
			# does exist: is a symlink to an empty directory, or an empty directory
			continue
		fi
	elif [[ -e $path ]]; then
		# does exist: not a symlink to a directory, nor a directory
		exit 20 # ENOTDIR 20 Not a directory
	else
		# discern if inaccessible, broken, missing
		is-accessible.bash -- "$path" || exit $?
		if [[ -L $path ]]; then
			# broken symlink
			exit 9 # EBADF 9 Bad file descriptor
		fi
		exit 2 # ENOENT 2 No such file or directory
	fi
done
exit 0
