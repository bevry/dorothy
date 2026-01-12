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
	if [[ -L $path ]]; then
		# is a symlink (broken or otherwise, accessible or otherwise)
		continue
	elif [[ -e $path ]]; then
		# does exist: but not a symlink
		printf '%s\n' "$path" >>"$TMPDIR/is-fs-failed-paths"
		exit 79 # EFTYPE 79 Inappropriate file type or format
	else
		# discern if inaccessible, missing
		is-accessible.bash -- "$path" || exit $?
		printf '%s\n' "$path" >>"$TMPDIR/is-fs-failed-paths"
		exit 2 # ENOENT 2 No such file or directory
	fi
done
exit 0
