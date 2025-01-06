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

	if [[ -d $path ]]; then
		# accessible and exists, is an unbroken symlink to a directory, or a directory
		continue
	elif [[ -e $path ]]; then
		# accessible and exists, but not an unbroken symlink to a directory, nor a directory
		return 20 # NOTDIR 20 Not a directory
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
