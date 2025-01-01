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
	if [[ ! -L $1 ]]; then
		# not a symlink
		if [[ ! -e $1 ]]; then
			# doesn't exist: not a symlink, file, nor directory
			exit 2 # ENOENT 2 No such file or directory
		fi
		# does exist: but not a symlink
		exit 79 # EFTYPE 79 Inappropriate file type or format
	fi
	# does exist: symlink (broken or otherwise)
	shift
done
exit 0
