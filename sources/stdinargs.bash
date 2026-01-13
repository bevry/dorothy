#!/usr/bin/env bash
source "$DOROTHY/sources/bash.bash"

# on_whole: argument, or entire stdin
# on_piece: argument, or line, or inline

# @todo use [declare -f help] to verify help supports arguments, otherwise our failure messages won't be seen

# the reason we disable timeout with --stdin is so that:
# > set -o pipefail
# > { sleep 1; echo 1; sleep 2; echo 2; sleep 3; echo 3; } | echo-count-lines --timeout=1
# 1
# [141] sigpipe
#
# > { sleep 1; echo 1; sleep 2; echo 2; sleep 3; echo 3; } | echo-count-lines --no-timeout
# 3
# [0] success

# This prints stdinargs options that callers should include in their help rendering.
function __stdinargs__help_options {
	local option_stdin='' \
		default_message=$'\n    This is the default behaviour.' \
		stdin_empty_message='' stdin_yes_message='' stdin_no_message=''
	__flag --target={option_stdin} --name='stdin' --affirmative --coerce -- "$@" || return $?
	if [[ $option_stdin == 'yes' ]]; then
		stdin_yes_message="$default_message"
	elif [[ $option_stdin == 'no' ]]; then
		stdin_no_message="$default_message"
	else
		stdin_empty_message="$default_message"
	fi
	cat <<-EOF || return $?
		--[no-]color[s]
		    Enforce or disable colored output, by exporting \`COLOR\` as \`tes\` (if enabled) or \`no\` (if disabled).

		--[no-]timeout[=<timeout:yes|no|max|immediate|0|<seconds>]
		    If enabled or omitted, STDIN content will be waited for \`1\` second before timing out.
		    If disabled or \`max\`, STDIN content will wait forever and not timeout.
		    If \`immediate\` or \`0\`, STDIN content must be immediate before timing out.
		    If <seconds>, STDIN content will be waited for <seconds> before timing out. Decimal values are supported, however decimals will be converted to \`1\` second on legacy bash versions.

		--[no-]stdin
		    If empty or omitted, use arguments if they are provided, otherwise wait the timeout duration for STDIN.$stdin_empty_message
		    If enabled, require STDIN for processing inputs, and disable timeout.$stdin_yes_message
		    If disabled, require arguments for processing inputs, and ignore STDIN.$stdin_no_message

		--[no-]inline
		    If enabled or omitted, always read the last line.
		    If disabled, only read the last tine if it has a terminating newline.
		    Support for this is dependent on the transformer, as it may not always be applicable.
	EOF
}
function stdinargs_options_help { __stdinargs__help_options "$@"; } # b/c alias

# Helpers for fetching our handlers
# This use to use `type -t` however that was slow
if [[ $BASH_HAS_NATIVE_ASSOCIATIVE_ARRAY == 'yes' ]]; then
	declare -A STDINARGS__functions_map=()
	function __stdinargs__prepare_functions {
		local line fn prefix='declare -f ' prefix_length
		prefix_length="${#prefix}"
		while read -r line; do
			fn="${line:prefix_length}"
			STDINARGS__functions_map["$fn"]=1
		done <<<"$(declare -F)"
	}
	function __stdinargs__get_first_function {
		local fn
		while [[ $# -ne 0 ]]; do
			fn="$1"
			shift
			if [[ -n $fn && -n ${STDINARGS__functions_map["$fn"]-} ]]; then
				__print_string "$fn"
				return 0
			fi
		done
		return 0 # empty result is fine
	}
else
	# trunk-ignore(shellcheck/SC2168)
	local STDINARGS__functions_composite=''
	function __stdinargs__prepare_functions {
		local line fn prefix='declare -f ' prefix_length
		prefix_length="${#prefix}"
		while read -r line; do
			fn="${line:prefix_length}"
			STDINARGS__functions_composite+="[$fn]"
		done <<<"$(declare -F)"
	}
	function __stdinargs__get_first_function {
		local fn
		while [[ $# -ne 0 ]]; do
			fn="$1"
			shift
			if [[ -n $fn && $STDINARGS__functions_composite == *"[$fn]"* ]]; then
				__print_string "$fn"
				return 0
			fi
		done
		return 0 # empty result is fine
	}
fi

# This is a helper callers of stdinargs can call to handle joining of pieces.
# trunk-ignore(shellcheck/SC2168)
local STDINARGS__pieces=0
function __print_piece {
	if [[ $STDINARGS__pieces -eq 0 ]]; then
		__print_string "$1" || return $?
		STDINARGS__pieces=$((STDINARGS__pieces + 1))
	else
		__print_string $'\n'"$1" || return $?
	fi
}

# This processes the arguments.
# This cannot become a safety function, as it needs to support unsafe functions, which safety functions cannot.
# Only if unsafe is hard deprecated, could it become a safety function, but that doesn't make sense.
function stdinargs {
	# function
	local fn_help fn_stdin fn_whole fn_piece fn_line fn_inline fn_arg fn_start fn_nothing fn_no_args fn_no_stdin fn_finish
	# cache the functions
	__stdinargs__prepare_functions
	# help function
	fn_help="$(__stdinargs__get_first_function __help help __on_help on_help)" || return $?
	# on argument function
	fn_arg="$(__stdinargs__get_first_function __on_argument on_argument __on_arg on_arg)" || return $?
	# if there is stdin content, handle it ourself
	fn_stdin="$(__stdinargs__get_first_function __on_stdin on_stdin)" || return $?
	# if there is stdin or argument content, receive it in whole
	fn_whole="$(__stdinargs__get_first_function __on_whole on_whole)" || return $?
	# before we begin parsing stdin or arguments, call this
	fn_start="$(__stdinargs__get_first_function __on_start on_start)" || return $?
	# if there were no stdin nor arguments, call this
	fn_nothing="$(__stdinargs__get_first_function __on_nothing on_nothing __on_no_input on_no_input)" || return $?
	# if there were no arguments, call this
	fn_no_args="$(__stdinargs__get_first_function __on_no_arguments on_no_arguments __on_no_args on_no_args)" || return $?
	# if there were no stdin, call this
	fn_no_stdin="$(__stdinargs__get_first_function __on_no_stdin on_no_stdin)" || return $?
	# after we finish parsing stdin and arguments, call this
	fn_finish="$(__stdinargs__get_first_function __on_finish on_finish)" || return $?
	if [[ -z $fn_whole ]]; then
		# if there isn't whole, then call these
		# inlines are a trailing line that isn't terminated by `\n`, either from STDIN or from arguments
		fn_inline="$(__stdinargs__get_first_function __on_inline on_inline)" || return $?
		# lines are STDIN and/or argument lines and/or inlines (iff no inline function)
		fn_line="$(__stdinargs__get_first_function __on_line on_line)" || return $?
		# pieces are a whole argument, or a STDIN line, or a STDIN inline (iff no arg nor whole nor inline nor line function)
		fn_piece="$(__stdinargs__get_first_function __on_piece on_piece __on_input on_input)" || return $?
	fi

	# arguments
	local item option_stdin='' option_timeout='' option_inline='yes' option_max_args='' option_args=()
	while [[ $# -ne 0 ]]; do
		item="$1"
		shift
		case "$item" in
		'--help' | '-h')
			if [[ -n $fn_help ]]; then
				"$fn_help" # eval
				return 22  # EINVAL 22 Invalid argument
			else
				__print_error 'A ' --code='help' ' function is required.' || return $?
				return 78 # ENOSYS 78 Function not implemented
			fi
			;;
		'--no-color'* | '--color'*) __flag --source={item} --target={COLOR} --affirmative --export || return $? ;;
		'--no-stdin'* | '--stdin'*) __flag --source={item} --target={option_stdin} --affirmative --no-coerce || return $? ;;
		'--no-timeout'* | '--timeout'*) __flag --source={item} --target={option_timeout} --affirmative --no-coerce || return  ;;
		'--no-inline'* | '--inline'*) __flag --source={item} --target={option_inline} --affirmative --coerce || return $? ;;
		'--max-args='*) option_max_args="${item#*=}" ;;
		# arguments, stdin
		'-')
			if [[ $# -eq 0 ]]; then
				# if - was the last argument, this is a convention for enforcing stdin
				option_stdin='yes'
			else
				option_args+=("$item")
			fi
			;;
		'--')
			if [[ $# -eq 0 ]]; then
				# if -- was the last argument, this is a convention for skipping stdin
				option_stdin='no'
			else
				option_args+=("$@")
				shift "$#"
				break
			fi
			;;
		'--'*)
			"$fn_help" 'An unrecognised flag was provided: ' --variable-value={item} # eval
			return 22                                                                # EINVAL 22 Invalid argument
			;;
		*) option_args+=("$item") ;;
		esac
	done

	# determine timeouts
	local timeout_immediate='no' timeout_max='no' timeout_seconds=1
	if [[ -z $option_timeout || $option_timeout == 'yes' || $option_timeout == 1 ]]; then
		timeout_seconds=1
	elif [[ $option_timeout == 'no' || $option_timeout == 'max' ]]; then
		timeout_max='yes'
	elif [[ $option_timeout == 0 || $option_timeout == 'immediate' ]]; then
		timeout_immediate='yes'
		timeout_seconds=0
	elif __is_number "$option_timeout"; then
		timeout_seconds="$(__get_read_decimal_timeout "$option_timeout")" || return $?
	else
		"$fn_help" 'An unrecognised <timeout> was provided: ' --variable-value={option_timeout}
	fi
	if [[ -z $timeout_max ]]; then
		timeout_max="${option_stdin:-"no"}"
	fi

	# process
	local had_args='maybe' had_stdin='maybe' args_count="${#option_args[@]}" complete='no' read_args=('-r')
	if [[ $timeout_max == 'no' && $timeout_immediate == 'no' && -n $timeout_seconds ]]; then
		read_args+=('-t' "$timeout_seconds")
	fi
	function stdinargs__eval {
		local stdinargs_status
		__try {stdinargs_status} -- "$@"
		if [[ $stdinargs_status == 210 ]]; then
			complete='yes'
			return 0
		fi
		return "$stdinargs_status"
	}
	function stdinargs__read {
		local what="$1" had_read='no'
		if [[ $what == 'stdin' && -n $fn_stdin ]]; then
			if [[ $timeout_immediate == 'no' ]] || read -t 0; then
				had_read='yes'
				stdinargs__eval "$fn_stdin"
			fi
		elif [[ -n $fn_whole ]]; then
			local piece='' whole=''
			while ([[ $timeout_immediate == 'no' ]] || read -t 0) && LC_ALL=C IFS= read -rd '' piece || [[ -n $piece ]]; do
				had_read='yes'
				if [[ $complete == 'yes' ]]; then
					break
				fi
				whole+="$piece"
				piece=''
			done
			stdinargs__eval "$fn_whole" "$whole"
		else
			# for each line, call `on_line` or `on_piece`
			# for each inline, call `on_inline` or `on_line` or `on_piece`
			# [read -t 0 line] will not read anything, so it must be done separately
			# IFS= to not trim whitespace lines (e.g. ' ' would otherwise become '')
			local piece=''
			# trunk-ignore(shellcheck/SC2162)
			while ([[ $timeout_immediate == 'no' ]] || read -t 0) && IFS= read "${read_args[@]}" piece; do
				had_read='yes'
				if [[ $complete == 'yes' ]]; then
					break
				fi
				if [[ -n $fn_line ]]; then
					stdinargs__eval "$fn_line" "$piece"
				else
					stdinargs__eval "$fn_piece" "$piece"
				fi
			done
			if [[ -n $piece && $option_inline != 'no' ]]; then # this needs to be `[[`` otherwise a piece of `>` will cause crash with `test`
				had_read='yes'
				if [[ $complete == 'yes' ]]; then
					:
				elif [[ -n $fn_inline ]]; then
					stdinargs__eval "$fn_inline" "$piece"
				elif [[ -n $fn_line ]]; then
					stdinargs__eval "$fn_line" "$piece"
				else
					stdinargs__eval "$fn_piece" "$piece"
				fi
			fi
		fi
		if [[ $had_read == 'yes' ]]; then
			if [[ $what == 'stdin' ]]; then
				had_stdin='yes'
			fi
		fi
	}

	# start
	if [[ -n $fn_start ]]; then
		"$fn_start" # eval
	fi

	# attempt arguments first
	# arguments are instantaneous and won't mangle stdin for parent processes
	if [[ $args_count -eq 0 ]]; then
		had_args='no'
	else
		# for each argument, call `on_(arg|input)` for each argument, otherwise call `on_(inline|line|input)` on each line of the argument
		had_args='yes'
		if [[ -n $option_max_args && $args_count -gt $option_max_args ]]; then
			"$fn_help" \
				'This command only supports a maximum of ' --value="$option_max_args" ' arguments, yet ' --value="$args_count" ' were provided:' --newline \
				--variable={option_args}
			return 22 # EINVAL 22 Invalid argument
		fi
		for item in "${option_args[@]}"; do
			if [[ $complete == 'yes' ]]; then
				break
			fi
			if [[ -n $fn_arg ]]; then
				stdinargs__eval "$fn_arg" "$item"
			elif [[ -n $fn_whole ]]; then
				stdinargs__eval "$fn_whole" "$item"
			elif [[ -n $fn_piece ]]; then
				stdinargs__eval "$fn_piece" "$item"
			else
				stdinargs__read arg < <(printf '%s' "$item") # don't use [ <<< "$item"] as that doesn't respect inlines, don't use [printf '%s' "$item" | ...] as that doesn't support shared scoping in bash v3
			fi
		done
	fi

	# if we don't want stdin, never read stdin, e.g. [echo-* --] or [echo-* --no-stdin]
	# if we want stdin, always read stdin, e.g. [echo-* --stdin] or [echo-* -]
	# if we autodetect stdin, then skip stdin if arguments were provided
	if [[ $option_stdin != 'no' && ($option_stdin == 'yes' || $had_args != 'yes') ]]; then
		had_stdin='no'
		stdinargs__read stdin
	fi

	# verify (note that values can be yes/no/maybe)
	if [[ $had_args != 'yes' && $had_stdin != 'yes' ]]; then
		# no stdin, no argument
		if [[ -n $fn_nothing ]]; then
			"$fn_nothing" # eval
		fi
	fi
	if [[ $had_args != 'yes' && -n $fn_no_args ]]; then
		"$fn_no_args" # eval
	fi
	if [[ $had_stdin != 'yes' && -n $fn_no_stdin ]]; then
		"$fn_no_stdin" # eval
	fi

	# if `finish` exists, call it
	if [[ -n $fn_finish ]]; then
		"$fn_finish" # eval
	fi
}
