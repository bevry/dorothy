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
		exit 2 # ENOENT 2 No such file or directory
	fi
	if [[ ! -w $1 ]]; then
		exit 1
	fi
	shift
done
exit 0
