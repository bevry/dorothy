#!/usr/bin/env bash

# checks for applicability already occurred in `fs-dequarantine`

function __is_fs__operation {
	# checks
	if [[ -r $path ]]; then
		# does exist: is readable

		# if it is quarantined, remove the quarantine attribute
		# https://apple.stackexchange.com/a/436677/15131
		# note that the -r option doesn't exist, will return [option -r not recognized] on Ventura and Sonoma
		# cannot just -d directly, as will get a [No such xattr: com.apple.quarantine] error, so check for it first, this induces no errors
		if /usr/bin/xattr -l "$path" | grep --quiet --fixed-strings --regexp='com.apple.quarantine'; then
			# it is quarantined, so now try remove the quarantine
			/usr/bin/xattr -d com.apple.quarantine "$path" >&2 || return $?
		fi # else, it was not quarantined
	elif [[ -e $path ]]; then
		# does exist: is not readable
		return 13 # EACCES 13 Permission denied
	else
		# discern if inaccessible, broken, missing
		is-accessible.bash -- "$path" || return $?
		if [[ -L $path ]]; then
			# broken symlink
			return 9 # EBADF 9 Bad file descriptor
		else
			return 2 # ENOENT 2 No such file or directory
		fi
	fi
}

source "$DOROTHY/sources/is-fs-operation.bash"
