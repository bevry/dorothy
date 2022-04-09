#!/usr/bin/env bash
source "$DOROTHY/sources/strict.bash"

# allow sourcer to overide
if test -z "${REQUIRE_STDIN-}"; then
	REQUIRE_STDIN='no'
fi
if test -z "${TIMEOUT-}"; then
	TIMEOUT=1 # one second
	# don't use a value less than 1 (unless 0, which means infinite timeout)
	# as too many commands take longer than a second to generate output (`mas search xcode` especially)
	# and decimal timeouts will fail in bash v3
	# also can't use something like: mas search xcode | echo-wait | echo-trim-each-line
	# as `echo-trim-each-line` will wait even longer in this case
	# as such, this is the best solution: mas search xcode | env TIMEOUT=0 echo-trim-each-line
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
	# for each argument, call `on_arg` or `on_input`
	has_args='yes'
	for item in "$@"; do
		if test "$(type -t on_arg)" = 'function'; then
			on_arg "$item"
		else
			on_input "$item"
		fi
	done
fi

# if no arguments, or stdin required, then do stdin
if test "$has_args" != 'yes' -o "$REQUIRE_STDIN" = 'yes'; then
	has_stdin='no'

	# read stdin
	# if stdin works, then mark it as so
	# for each line, call `on_line` or `on_input`
	# for each inline, call `on_inline` or `on_line` or `on_input`
	read_args=()
	if test -n "$TIMEOUT" -a "$TIMEOUT" -ne 0; then
		read_args+=("-t" "$TIMEOUT")
	fi
	while read -r "${read_args[@]}" item; do
		has_stdin='yes'
		if test "$(type -t on_line)" = 'function'; then
			on_line "$item"
		else
			on_input "$item"
		fi
	done </dev/stdin
	if test -n "$item"; then
		has_stdin='yes'
		if test "$(type -t on_inline)" = 'function'; then
			on_inline "$item"
		elif test "$(type -t on_line)" = 'function'; then
			on_line "$item"
		else
			on_input "$item"
		fi
	fi
fi

# verify
if test "$has_args" = 'no' -a "$has_stdin" = 'no'; then
	# no stdin, no argument
	if test "$(type -t on_no_input)" = 'function'; then
		on_no_input
	fi
fi
if test "$has_args" = 'no' -a "$(type -t on_no_args)" = 'function'; then
	on_no_args
fi
if test "$has_stdin" = 'no' -a "$(type -t on_no_stdin)" = 'function'; then
	on_no_stdin
fi

# if `finish` exists, call it
if test "$(type -t on_finish)" = 'function'; then
	on_finish
fi
