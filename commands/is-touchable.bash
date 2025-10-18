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
	# discern if inaccessible, broken, missing
	is-accessible.bash -- "$path" || exit
	if [[ ! -e $path && -L $path ]]; then
		# broken symlink
		printf '%s\n' "$path" >>"$TMPDIR/is-fs-failed-paths"
		exit 9 # EBADF 9 Bad file descriptor
	fi
	# is accessible, now determine if writable
	i_path="$path"
	while [[ $i_path != '/' ]]; do
		if is-present.bash -- "$i_path"; then
			is-writable.bash -- "$i_path"
			exit
		else
			i_path="$(dirname -- "$i_path")"
		fi
	done
	# not writable
	printf '%s\n' "$path" >>"$TMPDIR/is-fs-failed-paths"
	exit 93 # ENOATTR 93 Attribute not found
done
exit 0
