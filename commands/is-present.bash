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
	if [[ -e $path || -L $path ]]; then
		# exists: is a symlink (broken or otherwise, accessible or otherwise), file, or directory
		continue
	else
		# discern if inaccessible, missing
		is-accessible.bash -- "$path" || exit
		printf '%s\n' "$path" >>"$XDG_CACHE_HOME/is-fs-failed-paths"
		exit 2 # ENOENT 2 No such file or directory
	fi
done
exit 0
