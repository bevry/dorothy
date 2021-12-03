#!/usr/bin/env bash
# calls the act function on each stdin line or argument

export STDIN='no'

# allow sourcer to overide
if test -z "${timeout-}"; then
	# don't use a value less than 1 (unless 0, which means infinite timeout)
	# as too many commands take longer than a second to generate output (`mas search xcode` especially)
	# and decimal timeouts will fail in bash v3
	timeout="${TIMEOUT:-1}" # allow caller to override
	# also can't use something like: mas search xcode | echo-wait | echo-trim-lines
	# as `echo-trim-lines` will wait even longer in this case
	# as such, this is the best solution: mas search xcode | env TIMEOUT=0 echo-trim-lines
fi

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
		if test "$(type -t arg)" = 'function'; then
			arg "$item"
		else
			act "$item"
		fi
	done
else
	# args was empty, so attempt stdin
	STDIN='no'

	# read stdin
	# if stdin works, then mark it as so
	# and call `act` on each line
	read_args=()
	if test -n "$timeout" -a "$timeout" -ne 0; then
		read_args+=("-t" "$timeout")
	fi
	while read -r "${read_args[@]}" item; do
		STDIN='yes'
		if test "$(type -t line)" = 'function'; then
			line "$item"
		else
			act "$item"
		fi
	done </dev/stdin
	if test -n "$item"; then
		STDIN='yes'
		if test "$(type -t inline)" = 'function'; then
			inline "$item"
		else
			act "$item"
		fi
	fi

	# if stdin is empty
	# then it means stdin and arguments were empty
	# so if `noact` exists, call it
	if test "$STDIN" = 'no' -a "$(type -t noact)" = 'function'; then
		noact
		exit "$?"
	fi
fi

# if `finish` exists, call it
if test "$(type -t finish)" = 'function'; then
	finish
	exit "$?"
fi
