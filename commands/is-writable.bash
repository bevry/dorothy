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
	# just -e is faulty, as -e fails on broken symlinks
	if ! [[ -e $1 || -L $1 ]]; then
		# doesn't exist: not a symlink, file, nor directory
		exit 2 # ENOENT 2 No such file or directory
	fi
	if [[ ! -w $1 ]]; then
		# does exist: is not writable
		exit 93 # ENOATTR 93 Attribute not found
	fi
	# does exist: is writable
	shift
done
exit 0