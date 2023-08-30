#!/usr/bin/env bash
source "$DOROTHY/sources/bash.bash"

BREAK='no'

# uncatched help argument
if test "${1-}" = '--help'; then
	if test "$(type -t help)" = 'function'; then
		help >/dev/stderr && exit 22 # EINVAL 22 Invalid argument
		return
	else
		echo-error 'A [help] function is required.'
		return 78 # ENOSYS 78 Function not implemented
	fi
fi

# start
if test "$(type -t on_start)" = 'function'; then
	on_start
fi

# support custom arg handling
if test -z "${ARGS-}"; then
	ARGS=("$@")
fi

# allow sourcer to overide
if test -z "${REQUIRE_STDIN-}"; then
	REQUIRE_STDIN='no'
fi
# -t timeout: time out and return failure if a complete line of input is not read within TIMEOUT seconds. The value of the TMOUT variable is the default timeout. TIMEOUT may be a fractional number. If TIMEOUT is 0, read returns immediately, without trying to read any data, returning success only if input is available on the specified file descriptor. The exit status is greater than 128 if the timeout is exceeded.
if test -n "${TIMEOUT-}"; then
	if test "$TIMEOUT" = 'no'; then
		TIMEOUT='' # unlimiited
	else
		# ensure timeout is compatible across bash versions
		TIMEOUT="$(get_read_decimal_timeout "$TIMEOUT")"
	fi
else
	TIMEOUT=1 # default to 1 second, don't use 0 by default as too many commands aren't immediate, e.g.
	# echo-lines a b c | echo-quote <-- this will output nothing if the above line is TIMEOUT=0
	# for commands that take a long time, e.g. `mas search xcode`, you can use:
	# mas search xcode | sponge | echo-trim-each-line <-- however this will wait until all input is read before operating
	# or
	# mas search xcode | env TIMEOUT=no echo-trim-each-line <-- this will allow each line to be processed as it comes
fi

# prepare
HAD_ARGS='maybe'
HAD_STDIN='maybe'

# attempt arguments first
# arguments are instantanous and won't mangle stdin for parent processes
if test "${#ARGS[@]}" -eq 0; then
	HAD_ARGS='no'
else
	# for each argument, call `on_arg` or `on_input`
	HAD_ARGS='yes'
	for item in "${ARGS[@]}"; do
		if test "$BREAK" = 'yes'; then
			break
		fi
		if test "$(type -t on_arg)" = 'function'; then
			on_arg "$item"
		else
			on_input "$item"
		fi
	done
fi

# if no arguments, or stdin required, then do stdin
if test "$HAD_ARGS" != 'yes' -o "$REQUIRE_STDIN" = 'yes'; then
	HAD_STDIN='no'

	# read stdin
	# if stdin works, then mark it as so
	# for each line, call `on_line` or `on_input`
	# for each inline, call `on_inline` or `on_line` or `on_input`
	# [read -t 0 item] will not read anything, so it must be done seperately
	if test -n "$TIMEOUT" -a "$TIMEOUT" -ne 0; then
		read_args+=("-t" "$TIMEOUT")
	fi
	item=''
	while (test -z "$TIMEOUT" -o "$TIMEOUT" -ne 0 || read -t 0) && read -r "${read_args[@]}" item; do
		HAD_STDIN='yes'
		if test "$BREAK" = 'yes'; then
			break
		fi
		if test "$(type -t on_line)" = 'function'; then
			on_line "$item"
		else
			on_input "$item"
		fi
	done </dev/stdin
	if test -n "$item"; then
		HAD_STDIN='yes'
		if test "$BREAK" = 'yes'; then
			:
		elif test "$(type -t on_inline)" = 'function'; then
			on_inline "$item"
		elif test "$(type -t on_line)" = 'function'; then
			on_line "$item"
		else
			on_input "$item"
		fi
	fi
fi

# verify
if test "$HAD_ARGS" = 'no' -a "$HAD_STDIN" = 'no'; then
	# no stdin, no argument
	if test "$(type -t on_no_input)" = 'function'; then
		on_no_input
	fi
fi
if test "$HAD_ARGS" = 'no' -a "$(type -t on_no_args)" = 'function'; then
	on_no_args
fi
if test "$HAD_STDIN" = 'no' -a "$(type -t on_no_stdin)" = 'function'; then
	on_no_stdin
fi

# if `finish` exists, call it
if test "$(type -t on_finish)" = 'function'; then
	on_finish
fi
