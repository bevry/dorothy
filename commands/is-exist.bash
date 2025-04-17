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
	if [[ -e $path ]]; then
		# exists: is an unbroken symlink, a file, or a directory
		continue
	else
		# discern if inaccessible, missing
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
