#!/usr/bin/env bash

function __is_fs__operation {
	# Check for accessible symlink
	if [[ -L $path ]]; then
		# Check for accessible target
		if [[ -e $path ]]; then
			# Accessible symlink and target, not a broken symlink
			return 79 # EFTYPE 79 Inappropriate file type or format
		else
			# Discern accessibility of symlink target
			is-accessible.bash -- "$path" || return $?
			# Target was accessible but did not exist, thus it is a broken symlink, which is what we want
		fi
	elif [[ -e $path ]]; then
		# Accessible existing non-symlink file or directory
		return 17 # EEXIST 17 File exists
	else
		# Discern accessibility or non-existence
		is-accessible.bash -- "$path" || return $?
		return 2 # ENOENT 2 No such file or directory
	fi
}

source "$DOROTHY/sources/is-fs-operation.bash"
