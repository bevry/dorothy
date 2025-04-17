#!/usr/bin/env bash

option_resolve='no'
if [[ $1 == '--resolve' ]]; then
	option_resolve='yes'
	shift
fi
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

	# if desired, resolve symlinks
	if [[ $option_resolve == 'yes' ]]; then
		if is-directory.bash -- "$path"; then
			(
				cd "$path"
				pwd -P
			)
			continue
		elif is-not-symlink.bash -- "$path"; then
			filename="$(basename -- "$path")"
			(
				cd "$(dirname -- "$path")"
				printf '%s\n' "$(pwd -P)/$filename"
			)
			continue
		else
			exit 45 # ENOTSUP 45 Operation not supported
		fi
	fi

	# don't resolve symlinks
	filename="$(basename -- "$path")"
	dirname="$(dirname -- "$path")"
	is-accessible.bash -- "$dirname" || exit # not accessible, supported, but needs elevation
	is-present.bash -- "$dirname" || exit 45 # ENOTSUP 45 Operation not supported
	if [[ $filename == '/' ]]; then
		# handles root
		printf '%s\n' '/'
	elif [[ $filename == '..' ]]; then
		# handles parent
		(
			cd "$dirname/.." || exit # unknown failure, should have been caught earlier
			pwd
		)
	elif [[ $filename == '.' ]]; then
		# handles cwd
		(
			cd "$dirname" || exit # unknown failure, should have been caught earlier
			pwd
		)
	else
		# handles files and directories
		(
			cd "$dirname" || exit # unknown failure, should have been caught earlier
			printf '%s\n' "$(pwd)/$filename"
		)
	fi
done
exit 0
