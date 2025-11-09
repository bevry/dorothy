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
			printf '%s\n' "$path" >>"$TMPDIR/is-fs-failed-paths"
			exit 13 # EACCES 13 Permission denied
		fi
		if [[ -z "$(ls -A "$path")" ]]; then
			# does exist: is a symlink to an empty directory, or an empty directory
			printf '%s\n' "$path" >>"$TMPDIR/is-fs-failed-paths"
			exit 79 # EFTYPE 79 Inappropriate file type or format
		else
			# does exist: is a symlink to a non-empty directory, or a non-empty directory
			continue
		fi
	elif [[ -e $path ]]; then
		# does exist: not a symlink to a directory, nor a directory
		printf '%s\n' "$path" >>"$TMPDIR/is-fs-failed-paths"
		exit 20 # ENOTDIR 20 Not a directory
	else
		# discern if inaccessible, broken, missing
		is-accessible.bash -- "$path" || exit $?
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
