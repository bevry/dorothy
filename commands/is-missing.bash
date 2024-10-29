#!/usr/bin/env bash

if [[ $1 == '--' ]]; then
	shift
fi
if [[ $# -eq 0 ]]; then
	exit 22 # EINVAL 22 Invalid argument
fi
while [[ $# -ne 0 ]]; do
	# just -e is faulty, as -e fails on broken symlinks
	[[ ! -e $1 && ! -L $1 ]] || exit
	shift
done
exit 0
