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
	if [[ ! -e $path ]]; then
		exit 2 # ENOENT 2 No such file or directory
	fi
	if [[ ! -r $path ]]; then
		exit 1 # EPERM 1 Operation not permitted
	fi
	# if it is quarantined, remove the quarantine attribute
	# https://apple.stackexchange.com/a/436677/15131
	# note that the -r option doesn't exist, will return [option -r not recognized] on Ventura and Sonoma
	# cannot just -d directly, as will get a [No such xattr: com.apple.quarantine] error, so check for it first, this induces no errors
	if xattr -l "$path" | grep --quiet --fixed-strings --regexp='com.apple.quarantine'; then
		xattr -d com.apple.quarantine "$path" >/dev/stderr || exit
	fi
done
exit 0
