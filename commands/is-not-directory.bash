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
	if [[ -d $1 ]]; then
		# does exist: is a symlink to a directory, or a directory
		exit 21 # EISDIR 21 Is a directory
	fi
	# does exist: is a symlink to a non-directory, or a non-directory
	shift
done
exit 0
