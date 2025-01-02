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
	if [[ -L $1 ]]; then
		if [[ ! -e $1 ]]; then
			# does exist: is a broken symlink
			exit 9 # EBADF 9 Bad file descriptor
		fi
	elif [[ ! -e $1 ]]; then
		# doesn't exist: not a symlink, file, nor directory
		exit 2 # ENOENT 2 No such file or directory
	fi
	if [[ ! -f $1 ]]; then
		# does exist: not a symlink to a file, nor a file
		exit 79 # EFTYPE 79 Inappropriate file type or format
	fi
	if [[ ! -s $1 ]]; then
		# does exist: is a symlink to an empty file, or an empty file
		exit 66 # ENOTEMPTY 66 Directory not empty
	fi
	# does exist: is a symlink to a non-empty file, or a non-empty file
	shift
done
exit 0
