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
	if [[ ! -f $1 ]]; then
		# not a file nor symlink to a file
		exit 9 # EBADF 9 Bad file descriptor
	fi
	if [[ ! -s $1 ]]; then
		exit 1
	fi
	shift
done
exit 0
