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
	if [[ -x $path ]]; then
		# does exist: is executable
		continue
	elif [[ -e $path ]]; then
		# does exist: is not executable
		# discern if unable to detect executable status because it was inaccessible
		is-accessible.bash -- "$path" || exit $?
		exit 93 # ENOATTR 93 Attribute not found
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
