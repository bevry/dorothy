#!/usr/bin/env bash
source "$DOROTHY/sources/bash.bash"

# the reason we disable timeout with --stdin is so that:
# [waiter --no-magic | echo-wait | echo-count-lines --stdin] provides 5 instead of 0
function stdinargs_options_help {
	cat <<-EOF
		--timeout | --timeout=yes
		    Wait one second for STDIN content before timing out.
		    This is the default behaviour.
		--no-timeout | --timeout=no | --timeout=max
		    Do not timeout waiting for STDIN content.
		--timeout=immediate | --timeout=0
		    STDIN content must be immediate.
		--timeout=<seconds>
		    We will wait <seconds> before moving on. Decimal values are supported, but will be changed to 1 second on earlier bash versions.

		--inline | --inline=yes
		    When processing STDIN, always include the last line.
		    This is the default behaviour.
		--no-inline | --inline=no
		    When processing STDIN, ignore the last line if it does not have a trailing line.

		--stdin=
		    Use arguments if they are provided, otherwise wait the timeout duration for STDIN.
		--stdin | --stdin=yes | -
		    Require STDIN for processing inputs, and disable timeout.
		--no-stdin | --stdin=no | --
		    Require arguments for processing inputs, and ignore STDIN.
	EOF
	if test "$*" = '--stdin'; then
		cat <<-EOF

			[--stdin] is the default for this command.
		EOF
	else
		cat <<-EOF

			[--stdin=] is the default for this command.
		EOF
	fi
}

function stdinargs {
	# prepare
	local had_args='maybe' had_stdin='maybe' complete='no'
	local timeout_immediate='no' timeout_max='no' timeout_seconds=1
	function stdinargs_eval {
		local status
		eval_capture --statusvar=status -- "$@"
		if test "$status" = 210; then
			complete='yes'
			return 0
		fi
		return "$status"
	}

	# process
	local item option_stdin='' option_inline='yes' args=()
	while test "$#" -ne 0; do
		item="$1"
		shift
		case "$item" in
		'--help' | '-h')
			if test "$(type -t help)" = 'function'; then
				help >/dev/stderr && exit 22 # EINVAL 22 Invalid argument
				return
			else
				echo-error 'A [help] function is required.'
				return 78 # ENOSYS 78 Function not implemented
			fi
			;;
		'--timeout' | '--timeout=' | '--timeout=yes')
			timeout_seconds=1
			;;
		'--no-timeout' | '--timeout=no' | '--timeout=max')
			timeout_max='yes'
			;;
		'--timeout=0' | '--timeout=immediate')
			timeout_immediate='yes'
			timeout_seconds=0
			;;
		'--timeout='*)
			timeout_seconds="${item#*--timeout=}"
			timeout_seconds="$(get_read_decimal_timeout "$timeout_seconds")"
			;;
		# inline
		'--no-inline' | '--inline=no')
			option_inline='no'
			;;
		'--inline' | '--inline=yes')
			option_inline='yes'
			;;
		# don't use get-flag-value, as that will cause a never ending loop
		'--no-stdin' | '--stdin=no')
			option_stdin='no'
			;;
		'--stdin' | '--stdin=yes')
			option_stdin='yes'
			timeout_max='yes'
			;;
		# arguments, stdin
		'-')
			if test "$#" -eq 0; then
				# if - was the last argument, this is a convention for enforcing stdin
				option_stdin='yes'
				timeout_max='yes'
			else
				args+=("$item")
			fi
			;;
		'--')
			if test "$#" -eq 0; then
				# if -- was the last argument, this is a convention for skipping stdin
				option_stdin='no'
			else
				args+=("$@")
				shift "$#"
				break
			fi
			;;
		'--'*) help "An unrecognised flag was provided: $item" ;;
		*) args+=("$item") ;;
		esac
	done

	# start
	if test "$(type -t on_start)" = 'function'; then
		on_start
	fi

	# attempt arguments first
	# arguments are instantanous and won't mangle stdin for parent processes
	if test "${#args[@]}" -eq 0; then
		had_args='no'
	else
		# for each argument, call `on_arg` or `on_input`
		had_args='yes'
		for item in "${args[@]}"; do
			if test "$complete" = 'yes'; then
				break
			fi
			if test "$(type -t on_arg)" = 'function'; then
				stdinargs_eval on_arg "$item"
			else
				stdinargs_eval on_input "$item"
			fi
		done
	fi

	# if we want stdin, always read stdin, e.g. [echo-* --stdin] or [echo-* -]
	# if we don't want stdin, never read stdin, e.g. [echo-* --] or [echo-* --no-stdin]
	# if we autodetect stdin, then skip stdin if arguments were provided
	if test "$option_stdin" != 'no' && test "$option_stdin" = 'yes' -o "$had_args" != 'yes'; then
		had_stdin='no'

		# read stdin
		# if stdin works, then mark it as so
		# for each line, call `on_line` or `on_input`
		# for each inline, call `on_inline` or `on_line` or `on_input`
		# [read -t 0 item] will not read anything, so it must be done seperately
		# IFS='' to not trim whitespace lines (e.g. ' ' would otherwise become '')
		local read_args=('-r') # bash v3 compat
		if test "$timeout_max" = 'no' -a "$timeout_immediate" = 'no' -a -n "$timeout_seconds"; then
			read_args+=('-t' "$timeout_seconds")
		fi
		item=''
		# trunk-ignore(shellcheck/SC2162)
		while (test "$timeout_immediate" = 'no' || read -t 0) && IFS='' read "${read_args[@]}" item; do
			had_stdin='yes'
			if test "$complete" = 'yes'; then
				break
			fi
			if test "$(type -t on_line)" = 'function'; then
				stdinargs_eval on_line "$item"
			else
				stdinargs_eval on_input "$item"
			fi
		done </dev/stdin
		if test -n "$item" -a "$option_inline" != 'no'; then
			had_stdin='yes'
			if test "$complete" = 'yes'; then
				:
			elif test "$(type -t on_inline)" = 'function'; then
				stdinargs_eval on_inline "$item"
			elif test "$(type -t on_line)" = 'function'; then
				stdinargs_eval on_line "$item"
			else
				stdinargs_eval on_input "$item"
			fi
		fi
	fi

	# verify (note that values can be yes/no/maybe)
	if test "$had_args" != 'yes' -a "$had_stdin" != 'yes'; then
		# no stdin, no argument
		if test "$(type -t on_no_input)" = 'function'; then
			on_no_input
		fi
	fi
	if test "$had_args" != 'yes' -a "$(type -t on_no_args)" = 'function'; then
		on_no_args
	fi
	if test "$had_stdin" != 'yes' -a "$(type -t on_no_stdin)" = 'function'; then
		on_no_stdin
	fi

	# if `finish` exists, call it
	if test "$(type -t on_finish)" = 'function'; then
		on_finish
	fi
}
