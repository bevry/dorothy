#!/usr/bin/env bash
# calls the act function on each stdin line or argument

# check for help argument
if is-help "$@"; then
	if test "$(type -t help)" = 'function'; then
		help && exit 22 # Invalid argument
		exit "$?"
	else
		echo "please update the function you called with a [help] method" >/dev/stderr
		exit 38 # Function not implemented
	fi
fi

# attempt arguments first
# arguments are instanous and won't mangle stdin for parent processes
if test "$#" -ne 0; then
	# we have args
	# so call `act` on each of argument
	for item in "$@"; do
		act "$item"
	done
else
	# args was empty, so attempt stdin
	stdin='no'

	# read stdin, with a timeout of 0.1 seconds
	# if stdin works, then mark it as so
	# and call `act` on each line
	while IFS= read -rt 0.1 item; do
		stdin='yes'
		act "$item"
	done </dev/stdin

	# if stdin is empty
	# then it means stdin and arguments were empty
	# so if `noact` exists, call it
	if test "$stdin" = 'no' -a "$(type -t noact)" = 'function'; then
		noact
		exit "$?"
	fi
fi

# if `finish` exists, call it
if test "$(type -t finish)" = 'function'; then
	finish
	exit "$?"
fi
