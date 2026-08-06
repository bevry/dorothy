#!/usr/bin/env bash

function __is_fs__operation {
	# discern if inaccessible, broken, missing
	is-accessible.bash -- "$path" || return $?
	if [[ ! -e $path && -L $path ]]; then
		# broken symlink
		return 9 # EBADF 9 Bad file descriptor
	fi
	# is accessible, now determine if writable
	local ancestor="$path"
	while [[ $ancestor != '/' ]]; do
		if is-present.bash -- "$ancestor"; then
			is-writable.bash -- "$ancestor" || return $?
			return 0
		else
			ancestor="$(dirname -- "$ancestor")"
		fi
	done
	# not writable
	return 93 # ENOATTR 93 Attribute not found
}

source "$DOROTHY/sources/is-fs-operation.bash"
