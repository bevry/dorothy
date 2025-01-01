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
	if [[ ! -d $1 ]]; then
		# does exist: not a symlink to a directory, nor a directory
		exit 20 # ENOTDIR 20 Not a directory
	fi
	if [[ ! -r $1 ]]; then
		# does exist: not readable however, so no ability to check contents, as would get: ls: $path: Permission denied
		exit 13 # EACCES 13 Permission denied
	fi
	if [[ -n "$(ls -A "$1")" ]]; then
		# does exist: is a symlink to a non-empty directory, or a non-empty directory
		exit 66 # ENOTEMPTY 66 Directory not empty
	fi
	# does exist: is a symlink to an empty directory, or an empty directory
	shift
done
exit 0
