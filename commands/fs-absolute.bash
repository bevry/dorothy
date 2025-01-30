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

	# Affirm accessibility
	if [[ ! -e $path ]]; then
		# discern if inaccessible
		is-accessible.bash -- "$path" || exit
		# if missing, then it only matters if the parent is missing, which the following will deal with
	fi

	# It is accessible and exists
	# don't use [pwd -P] as -P resolves symlinks
	# and resolving symlinks is what [fs-realpath] is for
	filename="$(basename -- "$path")"
	if [[ $filename == '/' ]]; then
		# handles root
		printf '%s\n' '/'
	elif [[ $filename == '..' ]]; then
		# handles parent
		(
			cd "$(dirname -- "$path")/.."
			pwd
		)
	elif [[ $filename == '.' ]]; then
		# handles cwd
		(
			cd "$(dirname -- "$path")"
			pwd
		)
	else
		# handles files and directories
		(
			cd "$(dirname -- "$path")"
			printf '%s\n' "$(pwd)/$filename"
		)
	fi
done
exit 0
