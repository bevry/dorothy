#!/usr/bin/env bash

# calls the act function on each stdin line or argument

# wait 0.1 seconds for stdin lines, and call act on each of them
stdin="no"
while IFS= read -rt 0.1 item; do
	stdin="yes"
	act "$item"
done <&0

# stdin was empty, so try arguments
if test "$stdin" = "no"; then
	# if no args, and noact exists, call noact
	if test "$#" -eq 0; then
		# check if noact exists
		if test "$(type -t noact)" = 'function' ; then
			noact
			exit "$?"
		fi
	fi

	# we have args, so call act on each of them
	for item in "$@"; do
		act "$item"
	done
fi
