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
	if [[ -e $1 || -L $1 ]]; then
		# does exist: is a symlink, file, or directory
		exit 17 # EEXIST 17 File exists
	fi
	# doesn't exist: not a symlink, file, nor directory
	shift
done
exit 0
