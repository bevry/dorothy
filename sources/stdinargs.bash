#!/usr/bin/env bash
source "$DOROTHY/sources/strict.bash"

# allow sourcer to overide
if test -z "${require_stdin-}"; then
	require_stdin='no'
fi
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
if test "${1-}" = '--help'; then
	if test "$(type -t help)" = 'function'; then
		help >/dev/stderr && exit 22 # Invalid argument
		exit "$?"
	else
		echo "please update the function you called with a [help] method" >/dev/stderr
		exit 38 # Function not implemented
	fi
fi

# prepare
has_args='maybe'
has_stdin='maybe'

# attempt arguments first
# arguments are instantanous and won't mangle stdin for parent processes
if test "$#" -eq 0; then
	has_args='no'
else
	# for each argument, call `arg` or `act`
	has_args='yes'
	for item in "$@"; do
		if test "$(type -t arg)" = 'function'; then
			arg "$item"
		else
			act "$item"
		fi
	done
fi

# if no arguments, or stdin required, then do stdin
if test "$has_args" != 'yes' -o "$require_stdin" = 'yes'; then
	has_stdin='no'

	# read stdin
	# if stdin works, then mark it as so
	# for each line, call `line` or `act`
	# for each inline, call `inline` or `line` or `act`
	read_args=()
	if test -n "$timeout" -a "$timeout" -ne 0; then
		read_args+=("-t" "$timeout")
	fi
	while read -r "${read_args[@]}" item; do
		has_stdin='yes'
		if test "$(type -t line)" = 'function'; then
			line "$item"
		else
			act "$item"
		fi
	done </dev/stdin
	if test -n "$item"; then
		has_stdin='yes'
		if test "$(type -t inline)" = 'function'; then
			inline "$item"
		elif test "$(type -t line)" = 'function'; then
			line "$item"
		else
			act "$item"
		fi
	fi
fi

# verify
if test "$has_args" = 'no' -a "$has_stdin" = 'no'; then
	if test "$(type -t no_args_nor_stdin)" = 'function'; then
		no_args_nor_stdin
	elif test "$(type -t noact)" = 'function'; then
		noact # deprecated
	fi
fi
if test "$has_args" = 'no' -a "$(type -t no_args)" = 'function'; then
	no_args
fi
if test "$has_stdin" = 'no' -a "$(type -t no_stdin)" = 'function'; then
	no_stdin
fi

# if `finish` exists, call it
if test "$(type -t finish)" = 'function'; then
	finish
fi
