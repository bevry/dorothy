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
		# does exist: is a symlink (accessible or otherwise, broken or otherwise)
		printf '%s\n' "$path" >>"$TMPDIR/is-fs-failed-paths"
		exit 79 # EFTYPE 79 Inappropriate file type or format
	elif [[ -e $path ]]; then
		# does exist and is not a symlink (accessible or otherwise, broken or otherwise)
		continue
	else
		# discern if inaccessible, missing
		is-accessible.bash -- "$path" || exit
		printf '%s\n' "$path" >>"$TMPDIR/is-fs-failed-paths"
		exit 2 # ENOENT 2 No such file or directory
	fi
done
exit 0
