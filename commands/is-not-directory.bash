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
		# does exist: is a symlink to a directory, or a directory
		printf '%s\n' "$path" >>"$TMPDIR/is-fs-failed-paths"
		exit 21 # EISDIR 21 Is a directory
	elif [[ -e $path ]]; then
		# does exist and is not a symlink to a directory, nor a directory
		continue
	else
		# discern if inaccessible, broken, missing
		is-accessible.bash -- "$path" || exit
		if [[ -L $path ]]; then
			# broken symlink
			printf '%s\n' "$path" >>"$TMPDIR/is-fs-failed-paths"
			exit 9 # EBADF 9 Bad file descriptor
		fi
		printf '%s\n' "$path" >>"$TMPDIR/is-fs-failed-paths"
		exit 2 # ENOENT 2 No such file or directory
	fi
done
exit 0
