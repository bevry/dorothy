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
	path="$1"
	shift

	# checks
	if [[ -r $path ]]; then
		# does exist: is readable

		# if it is quarantined, remove the quarantine attribute
		# https://apple.stackexchange.com/a/436677/15131
		# note that the -r option doesn't exist, will return [option -r not recognized] on Ventura and Sonoma
		# cannot just -d directly, as will get a [No such xattr: com.apple.quarantine] error, so check for it first, this induces no errors
		if /usr/bin/xattr -l "$path" | grep --quiet --fixed-strings --regexp='com.apple.quarantine'; then
			/usr/bin/xattr -d com.apple.quarantine "$path" >&2 || {
				status=$?
				printf '%s\n' "$path" >>"$TMPDIR/is-fs-failed-paths"
				exit "$status"
			}
		fi
		continue
	elif [[ -e $path ]]; then
		# does exist: is not readable
		exit 13 # EACCES 13 Permission denied
	else
		# discern if inaccessible, broken, missing
		is-accessible.bash -- "$path" || exit
		if [[ -L $path ]]; then
			# broken symlink
			exit 9 # EBADF 9 Bad file descriptor
		fi
		exit 2 # ENOENT 2 No such file or directory
	fi
done
exit 0
