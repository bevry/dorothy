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

	# Check for accessible symlink
	if [[ -L $path ]]; then
		# Check for accessible target
		if [[ -e $path ]]; then
			# Accessible symlink and target, not a broken symlink
			printf '%s\n' "$path" >>"$TMPDIR/is-fs-failed-paths"
			exit 79 # EFTYPE 79 Inappropriate file type or format
		else
			# Discern accessibility of symlink target
			is-accessible.bash -- "$path" || exit $?
			# Target was accessible but did not exist, thus it is a broken symlink, which is what we want
			continue
		fi
	elif [[ -e $path ]]; then
		# Accessible existing non-symlink file or directory
		printf '%s\n' "$path" >>"$TMPDIR/is-fs-failed-paths"
		exit 17 # EEXIST 17 File exists
	else
		# Discern accessibility or non-existence
		is-accessible.bash -- "$path" || exit $?
		printf '%s\n' "$path" >>"$TMPDIR/is-fs-failed-paths"
		exit 2 # ENOENT 2 No such file or directory
	fi
done
exit 0
