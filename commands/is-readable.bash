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
	if [[ -r $path ]]; then
		# does exist: is readable
		continue
	elif [[ -e $path ]]; then
		# does exist: is not readable
		printf '%s\n' "$path" >>"$TMPDIR/is-fs-failed-paths"
		exit 93 # ENOATTR 93 Attribute not found
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
