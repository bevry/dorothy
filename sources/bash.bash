#!/usr/bin/env bash

# For bash version compatibility and changes, see:
# See <https://github.com/bevry/dorothy/blob/master/docs/bash/versions.md> for documentation about significant changes between bash versions.
# See <https://git.savannah.gnu.org/cgit/bash.git/tree/CHANGES> <https://tiswww.case.edu/php/chet/bash/CHANGES> <https://github.com/bminor/bash/blob/master/CHANGES> for documentation on changes from bash v2 and above.

# For bash configuration options, see:
# https://www.gnu.org/software/bash/manual/bash.html#The-Set-Builtin
# https://www.gnu.org/software/bash/manual/bash.html#The-Shopt-Builtin

# Note that [&>] is available to all bash versions, however [&>>] is not, they are different.

# bash <= 3.2 is not supported by Dorothy for reasons stated in [versions.md], however it is also too incompetent of a version to even bother checking for it

# bash v4.4
# aa. Bash now puts `s' in the value of $- if the shell is reading from standard input, as Posix requires.
# w.  `set -i' is no longer valid, as in other shells.

# =============================================================================
# Print Helpers

# These should be the same in [bash.bash] and [zsh.zsh].
# They exist because [echo] has flaws, notably [v='-n'; echo "$v"] will not output [-n].
# In UNIX there is no difference between an empty string and no input:
# empty stdin:  printf '' | wc
#               wc < <(printf '')
#    no stdin:  : | wc
#               wc < <(:)

# print each argument concatenated together with no spacing, if no arguments, do nothing
function __print_string { # b/c alias for __print_strings_or_nothing
	if [[ $# -ne 0 ]]; then
		printf '%s' "$@"
	fi
}
function __print_strings { # b/c alias for __print_strings_or_nothing
	if [[ $# -ne 0 ]]; then
		printf '%s' "$@"
	fi
}
function __print_strings_or_nothing {
	if [[ $# -ne 0 ]]; then
		printf '%s' "$@"
	fi
}

# print each argument on its own line, if no arguments, print a line
function __print_line {
	printf '\n'
}
function __print_lines_or_line {
	# equivalent to [printf '\n'] if no arguments
	printf '%s\n' "$@"
}

# print each argument on its own line, if no arguments, do nothing
function __print_lines { # b/c alias for __print_lines_or_nothing
	if [[ $# -ne 0 ]]; then
		printf '%s\n' "$@"
	fi
}
function __print_lines_or_nothing {
	if [[ $# -ne 0 ]]; then
		printf '%s\n' "$@"
	fi
}

# print only arguments that are non-empty, concatenated together with no spacing, if no arguments, do nothing
function __print_value_strings_or_nothing {
	local values=()
	while [[ $# -ne 0 ]]; do
		if [[ -n $1 ]]; then
			values+=("$1")
		fi
		shift
	done
	if [[ ${#values[@]} -ne 0 ]]; then
		printf '%s' "${values[@]}"
	fi
}

# print only arguments that are non-empty on their own line, if no arguments, do nothing
function __print_value_lines_or_nothing {
	local values=()
	while [[ $# -ne 0 ]]; do
		if [[ -n $1 ]]; then
			values+=("$1")
		fi
		shift
	done
	if [[ ${#values[@]} -ne 0 ]]; then
		printf '%s\n' "${values[@]}"
	fi
}

# print only arguments that are non-empty on their own line, if no arguments, print a line
function __print_value_lines_or_line {
	local values=()
	while [[ $# -ne 0 ]]; do
		if [[ -n $1 ]]; then
			values+=("$1")
		fi
		shift
	done
	if [[ ${#values[@]} -eq 0 ]]; then
		printf '\n'
	else
		printf '%s\n' "${values[@]}"
	fi
}

function __ternary {
	local condition="$1" true_value="$2" false_value="$3"
	if eval "$condition"; then
		__print_lines "$true_value"
	else
		__print_lines "$false_value"
	fi
}

# debug
DEBUG_TARGET=''
function __debug_lines {
	if [[ -n ${DEBUG-} ]]; then
		if [[ -z $DEBUG_TARGET ]]; then
			DEBUG_TARGET="$TERMINAL_DEVICE_FILE"
		fi
		__print_lines "$@" >>"$DEBUG_TARGET"
	fi
}
DEBUG_FORMAT='+ ${BASH_SOURCE[0]} [${LINENO}] [${FUNCNAME-}] [${BASH_SUBSHELL-}]'$'    \t'
function __enable_debugging {
	PS4="$DEBUG_FORMAT"
	DEBUG=yes
	set -x
}
function __disable_debugging {
	DEBUG=
	set +x
}

# =============================================================================
# Common Toolkit

# see [commands/is-brew] for details
# workaround for Dorothy's [brew] helper
function __is_brew {
	[[ -n ${HOMEBREW_PREFIX-} && -x "${HOMEBREW_PREFIX-}/bin/brew" ]] || return
}

# see [commands/command-missing] for details
# returns [0] if ANY command is missing
# returns [1] if ALL commands were present
function __command_missing {
	# trim -- prefix
	if [[ ${1-} == '--' ]]; then
		shift
	fi
	# proceed
	local command
	for command in "$@"; do
		if [[ $command == 'brew' ]]; then
			# workaround for our [brew] wrapper
			if __is_brew; then
				continue
			else
				return 0 # a command is missing
			fi
		elif type -P "$command" &>/dev/null; then
			continue
		else
			return 0 # a command is missing
		fi
	done
	return 1 # all commands are present

}

# see [commands/command-exists] for details
# returns [0] if all commands are available
# returns [1] if any command was not available
function __command_exists {
	# trim -- prefix
	if [[ ${1-} == '--' ]]; then
		shift
	fi
	# proceed
	local command
	for command in "$@"; do
		if [[ $command == 'brew' ]]; then
			# workaround for our [brew] wrapper
			if __is_brew; then
				continue
			else
				return 1 # a command is missing
			fi
		elif type -P "$command" &>/dev/null; then
			continue
		else
			return 1 # a command is missing
		fi
	done
	return 0 # all commands are present
}

# see [commands/eval-helper --elevate] for details
function __elevate {
	# trim -- prefix
	if [[ ${1-} == '--' ]]; then
		shift
	fi
	# forward to [eval-helper --elevate] if it exists, as it is more detailed
	if __command_exists -- eval-helper; then
		eval-helper --elevate -- "$@"
		return
	elif __command_exists -- sudo; then
		# check if password is required
		if ! sudo --non-interactive "$@" &>/dev/null; then
			# password is required, let the user know what they are being prompted for
			__print_lines 'Your password is required to momentarily grant privileges to execute the command:' >&2
			__print_lines "sudo $*" >&2
			sudo "$@"
			return
		else
			# session still active, password not required
			sudo "$@"
			return
		fi
	elif __command_exists -- doas; then
		local status=0
		set -x # <inform the user of why they are being prompted for a doas password>
		doas "$@" || status=$?
		set +x # </inform>
		return "$status"
	else
		"$@"
		return
	fi
}
# bc alias
function __try_sudo {
	dorothy-warnings add --code='__try_sudo' --bold=' has been deprecated in favor of ' --code='__elevate' || :
	__elevate "$@" || return
	return
}

# performantly make directories as many directories as possible without sudo
function __mkdirp {
	# trim -- prefix
	if [[ ${1-} == '--' ]]; then
		shift
	fi
	# proceed
	local status=0 dir missing=()
	for dir in "$@"; do
		if [[ -n $dir && ! -d $dir ]]; then
			missing+=("$dir")
		fi
	done
	if [[ ${#missing[@]} -ne 0 ]]; then
		mkdir -p -- "${missing[@]}" || status=$?
		# none of this actually works, as there are more major issues if this happens, and needs to be worked around manually
		# see: https://github.com/orgs/community/discussions/148648#discussioncomment-11862303
		# if [[ $status -ne 0 ]]; then
		# 	local sudo_missing=()
		# 	status=0
		# 	for dir in "${missing[@]}"; do
		# 		if [[ ! -d $dir ]]; then
		# 			sudo_missing+=("$dir")
		# 			# for some reason, this detection doesn't work:
		# 			# if mkdir -p -- "$dir" 2>&1 | grep --quiet --regexp=': Permission denied$'; then
		# 			# 	sudo_missing+=("$dir")
		# 			# else
		# 			# 	mkdir -p -- "$dir" || return
		# 			# fi
		# 		fi
		# 	done
		# 	if [[ ${#sudo_missing[@]} -ne 0 ]]; then
		# 		__elevate_mkdirp -- "${sudo_missing[@]}" || status=$?
		# 	fi
		# fi
	fi
	return "$status"
}

# performantly make directories with sudo
function __elevate_mkdirp {
	# trim -- prefix
	if [[ ${1-} == '--' ]]; then
		shift
	fi
	# proceed
	local status=0 dir missing=()
	for dir in "$@"; do
		if [[ -n $dir && ! -d $dir ]]; then
			missing+=("$dir")
		fi
	done
	if [[ ${#missing[@]} -ne 0 ]]; then
		__elevate -- mkdir -p -- "${missing[@]}" || status=$?
	fi
	return "$status"
}
# bc alias
function __sudo_mkdirp {
	dorothy-warnings add --code='__sudo_mkdirp' --bold=' has been deprecated in favor of ' --code='__elevate_mkdirp' || :
	__elevate "$@" || return
	return
}

# bash < 4.2 doesn't support negative lengths, bash >= 4.2 supports negative start indexes however it requires a preceding space or wrapped parenthesis if done directly: ${var: -1} or ${var:(-1)}
# the bash >= 4.2 behaviour returns empty string if negative start index is out of bounds, rather than the entire string, which is unintuitive: v=12345; s=-6; __print_lines "${v:s}"
# function __get_substring_native {
# 	local string="$1" start="${2:-0}" length="${3-}"
# 	if [[ -n "$length" ]]; then
# 		__print_lines "${string:start:length}"
# 	elif [[ -n "$start" ]]; then
# 		__print_lines "${string:start}"
# 	else
# 		__print_lines "$string"
# 	fi
# }
# __get_substring <string> [<start>] [<length>]
function __get_substring {
	local string="$1"
	local -i start="${2:-0}" length size remaining
	size="${#string}"
	if [[ $start -lt 0 ]]; then
		# this isn't an official thing, as it is conflated with "${var:-fallback}", however it is intuited and expected
		if [[ $start*-1 -ge $size ]]; then
			start=0
		else
			start+=size
		fi
	elif [[ $start -ge $size ]]; then
		return 0
	fi
	# trunk-ignore(shellcheck/SC2100)
	remaining=size-start
	if [[ -z ${3-} ]]; then
		length=remaining
	else
		length=$3
		if [[ $length -gt $remaining ]]; then
			length=remaining
		elif [[ $length -lt 0 ]]; then
			if [[ $length -le $remaining*-1 ]]; then
				return 0
			else
				# trunk-ignore(shellcheck/SC2100)
				length+=size-start
			fi
		fi
	fi
	__print_lines "${string:start:length}"
}

# bc alias
function __substr {
	dorothy-warnings add --code='__substr' --bold=' has been deprecated in favor of ' --code='__get_substring' || :
	__get_substring "$@" || return
	return
}

# @todo replace all native occurrences with this self-documenting and less-error prone function
# __get_substring_before_first <string> <delimiter> [<fallback>]
function __get_substring_before_first {
	local string="$1" delimiter="$2"
	result="${string%%"$delimiter"*}"
	if [[ $result != "$string" ]]; then
		__print_lines "$result"
		return 0
	fi
	# local string="$1" delimiter="$2" i n dn
	# n="${#string}"
	# dn="${#delimiter}"
	# for (( i = 0; i < n; i++ )); do
	# 	if [[ ${string:i:dn} == "$delimiter" ]]; then
	# 		__print_lines "${string:0:i}"
	# 		return 0
	# 	fi
	# done
	if [[ $# -eq 3 ]]; then
		__print_lines "$3"
		return 0
	else
		__print_lines "ERROR: ${FUNCNAME[0]}: Delimiter $delimiter was not found within: $string" >&2
		return 1
	fi
}

# @todo replace all native occurrences with this self-documenting and less-error prone function
# __get_substring_before_last <string> <delimiter> [<fallback>]
function __get_substring_before_last {
	local string="$1" delimiter="$2" result
	result="${string%"$delimiter"*}"
	if [[ $result != "$string" ]]; then
		__print_lines "$result"
		return 0
	fi
	# local string="$1" delimiter="$2" i n dn
	# n="${#string}"
	# dn="${#delimiter}"
	# for (( i = n - dn; i >= 0; i-- )); do
	# 	if [[ ${string:i:dn} == "$delimiter" ]]; then
	# 		__print_lines "${string:0:i}"
	# 		return 0
	# 	fi
	# done
	if [[ $# -eq 3 ]]; then
		__print_lines "$3"
		return 0
	else
		__print_lines "ERROR: ${FUNCNAME[0]}: Delimiter $delimiter was not found within: $string" >&2
		return 1
	fi
}

# @todo replace all native occurrences with this self-documenting and less-error prone function
# __get_substring_after_first <string> <delimiter> [<fallback>]
function __get_substring_after_first {
	local string="$1" delimiter="$2" result
	result="${string#*"$delimiter"}"
	if [[ $result != "$string" ]]; then
		__print_lines "$result"
		return 0
	fi
	# local string="$1" delimiter="$2" i n dn r
	# n="${#string}"
	# dn="${#delimiter}"
	# for (( i = 0; i < n; i++ )); do
	# 	if [[ ${string:i:dn} == "$delimiter" ]]; then
	# 		__print_lines "${string:i+dn}"
	# 		return 0
	# 	fi
	# done
	if [[ $# -eq 3 ]]; then
		__print_lines "$3"
		return 0
	else
		__print_lines "ERROR: ${FUNCNAME[0]}: Delimiter $delimiter was not found within: $string" >&2
		return 1
	fi
}

# @todo replace all native occurrences with this self-documenting and less-error prone function
# __get_substring_after_last <string> <delimiter> [<fallback>]
function __get_substring_after_last {
	local string="$1" delimiter="$2" result
	result="${string##*"$delimiter"}"
	if [[ $result != "$string" ]]; then
		__print_lines "$result"
		return 0
	fi
	# local string="$1" delimiter="$2" i n dn r
	# n="${#string}"
	# dn="${#delimiter}"
	# for (( i = n - dn; i >= 0; i-- )); do
	# 	if [[ ${string:i:dn} == "$delimiter" ]]; then
	# 		__print_lines "${string:i+dn}"
	# 		return 0
	# 	fi
	# done
	if [[ $# -eq 3 ]]; then
		__print_lines "$3"
		return 0
	else
		__print_lines "ERROR: ${FUNCNAME[0]}: Delimiter $delimiter was not found within: $string" >&2
		return 1
	fi
}

# has needle / is needle
# __is_within <needle> <array-var-name>
# __is_within <needle> -- ...<element>
function __is_within {
	if [[ $2 == '--' ]]; then
		local needle="$1" item
		shift # trim needle
		shift # trim --
		for item in "$@"; do
			if [[ $needle == "$item" ]]; then
				return 0
			fi
		done
		return 1
	else
		local needle="$1" array_var_name="$2" n i
		# trunk-ignore(shellcheck/SC1087)
		eval "n=\${#$array_var_name[@]}"
		for ((i = 0; i < n; ++i)); do
			# trunk-ignore(shellcheck/SC1087)
			if eval "[[ \$needle == \"\${$array_var_name[i]}\" ]]"; then
				return 0
			fi
		done
		return 1
	fi
}

# # __intersect <array-var-name> <array-var-name>
# function __intersect {
# 	local array_var_name_left="$1" array_var_name_right="$2" n_left n_right i_left i_right
# 	# trunk-ignore(shellcheck/SC1087)
# 	eval "n_left=\${#$array_var_name_left[@]}"
# 	# trunk-ignore(shellcheck/SC1087)
# 	eval "n_right=\${#$array_var_name_right[@]}"
# 	for ((i_left = 0; i_left < n_left; ++i_left)); do
# 		for ((i_right = 0; i_right < n_right; ++i_right)); do
# 			if eval "[[ \"\${$array_var_name_left[i]}\" == \"\${$array_var_name_right[i]}\" ]]"; then
# 				eval "__print_lines \"\${$array_var_name_left[i]}\""
# 				break
# 			fi
# 		done
# 	done
# }

# # __complement <array-var-name> <array-var-name>
# function __complement {
# 	local array_var_name_left="$1" array_var_name_right="$2" n_left n_right i_left i_right found
# 	# trunk-ignore(shellcheck/SC1087)
# 	eval "n_left=\${#$array_var_name_left[@]}"
# 	# trunk-ignore(shellcheck/SC1087)
# 	eval "n_right=\${#$array_var_name_right[@]}"
# 	for ((i_left = 0; i_left < n_left; ++i_left)); do
# 		found='no'
# 		for ((i_right = 0; i_right < n_right; ++i_right)); do
# 			if eval "[[ \"\${$array_var_name_left[i]}\" == \"\${$array_var_name_right[i]}\" ]]"; then
# 				found='yes'
# 				break
# 			fi
# 		done
# 		if [[ $found == 'no' ]]; then
# 			eval "__print_lines \"\${$array_var_name_left[i]}\""
# 		fi
# 	done
# }

# replace shapeshifting ANSI Escape Codes with newlines
function __split_shapeshifting {
	# trim -- prefix
	if [[ ${1-} == '--' ]]; then
		shift
	fi
	# proceed
	# regexp should match [echo-clear-lines] [echo-revolving-door] [is-shapeshifter]
	# https://www.gnu.org/software/bash/manual/bash.html#Pattern-Matching
	local input
	for input in "$@"; do
		input="${input//[[:cntrl:]]\[*([\;\?0-9])[\][\^\`\~\\ABCDEFGHIJKLMNOPQSTUVWXYZabcdefghijklnosu]/$'\n'}"
		input="${input//[[:cntrl:]][\]\`\^\\78M]/$'\n'}" # save and restore cursor
		input="${input//[[:cntrl:]][bf]/$'\n'}"          # page-up, page-down
		input="${input//[$'\r'$'\177'$'\b']/$'\n'}"
		__print_lines "$input"
	done
}

# determine if the input contains shapeshifting ANSI Escape Codes
function __is_shapeshifter {
	# trim -- prefix
	if [[ ${1-} == '--' ]]; then
		shift
	fi
	# proceed
	local input trimmed
	for input in "$@"; do
		trimmed="$(__split_shapeshifting -- "$input")"
		if [[ $input != "$trimmed" ]]; then
			return 0
		fi
	done
	return 1
}

# see [commands/get-terminal-device-file] for details
TERMINAL_DEVICE_FILE="${TERMINAL_DEVICE_FILE-}"
function __refresh_terminal_device_file {
	# see [commands/get-terminal-device-file] for details
	if __has_tty_support; then
		TERMINAL_DEVICE_FILE='/dev/tty'
	else
		TERMINAL_DEVICE_FILE='/dev/stderr'
	fi
}
function __has_tty_support {
	# see [commands/get-terminal-tty-support] for details
	# don't cache this
	(: </dev/tty >/dev/tty) &>/dev/null
	return
}
if [[ -z $TERMINAL_DEVICE_FILE ]]; then
	__refresh_terminal_device_file
fi

function __is_special_file {
	local target="$1"
	case "$target" in
	1 | stdout | STDOUT | /dev/stdout | 2 | stderr | STDERR | /dev/stderr | tty | TTY | /dev/tty | null | NULL | /dev/null | [0-9]*) return 0 ;; # is a special file
	'')
		__print_lines "ERROR: ${FUNCNAME[0]}: An unrecognised target was provided: $target" >&2
		return 22
		;;            # EINVAL 22 Invalid argument
	*) return 1 ;; # not a special file
	esac
}

# use this to ensure that the prior command's exit status bubbles a failure, regardless of whether errexit is on or off:
# __return $? || return
# in your [__*] functions instead of this mess:
# status=$?; if [[ $status -ne 0 ]]; then return $status; fi
# this is all necessary as just doing this disables errexit in [__fn]:
# __fn || return
#
# use this to ensure the touch always functions and the failure status is persisted:
# >(tee -a -- "${samasama[@]}" 2>&1; __return $? -- touch "$semaphore")
# instead of this mess:
# >(if tee -a -- "${samasama[@]}" 2>&1; then touch "$semaphore"; else status=$?; touch "$semaphore"; return "$status"; fi)
# note that this disabled errexit on the eval'd code
function __return {
	# __return $?
	if [[ $# -eq 1 ]]; then
		return "$1"
	fi

	# sanity
	if [[ $# -eq 0 || $2 != '--' ]]; then
		__print_lines "ERROR: ${FUNCNAME[0]}: Invalid arguments provided: $*" >&2
		return 22 # EINVAL 22 Invalid argument
	fi

	# __return $? -- command ...
	local return_status="$1"
	shift # trim status
	shift # trim --
	if [[ $return_status -eq 0 ]]; then
		# the caller didn't fail, so return with the eval's exit status
		"$@"
		return
	else
		# the caller failed, so run the eval, but use the caller's failure status
		"$@" || :
		return "$return_status"
	fi
}

# these aren't used anywhere yet:

# ignore an exit status
function __ignore_exit_status {
	local status="$?" item
	for item in "$@"; do
		if [[ $status -eq $item ]]; then
			return 0
		fi
	done
	return "$status"
}

# ignore a sigpipe exit status
# this enables the following:
# { curl --silent --show-error 'https://www.google.com' | : || __ignore_exit_status 56; } | { { cat; yes; } | head -n 1 || __ignore_sigpipe; } | cat
# note that the curl pipefail 56 occurs because we pipe [curl] to [:], similar to how we cause another pipefail later by piping [yes] to [head -n 1], this is a contrived example to demonstrate the point
function __ignore_sigpipe {
	__ignore_exit_status 141
}

# exit on a specific exit status
function __exit_on_exit_status {
	local status="$?" item
	for item in "$@"; do
		if [[ $status -eq $item ]]; then
			exit 0
		fi
	done
	return 0
}

function __is_errexit {
	[[ $- == *e* ]] || return # explicit `|| return` required to prevent ERR trap from firing, which is important here as it is used within our ERR trap
}

function __is_not_errexit {
	[[ $- != *e* ]] || return # explicit `|| return` required to prevent ERR trap from firing, which is important here as it is used within our ERR trap
}

function __is_subshell_function {
	local cmd="$1"
	# test "$(declare -f "$cmd")" == "$cmd"$' () \n{ \n    ('
	[[ "$(declare -f "$cmd")" == "$cmd"$' () \n{ \n    ('* ]] || return # explicit `|| return` required to prevent ERR trap from firing, which is important here as it is used within our ERR trap
}

function __get_index_of_parent_function {
	# if it is only this helper function then skip
	if [[ ${#FUNCNAME[@]} -le 1 ]]; then
		return 1
	fi
	local until fns=() i
	# skip __has_subshell_function_until which will be index [0]
	fns=("${FUNCNAME[@]:1}")

	# find a match
	for i in "${!fns[@]}"; do
		for until in "$@"; do
			if [[ ${fns[i]} == "$until" ]]; then
				__print_lines "$i"
				return 0
			fi
		done
	done
	return 1
}

function __get_first_parent_that_is_not {
	# if it is only this helper function then skip
	if [[ ${#FUNCNAME[@]} -le 1 ]]; then
		return 1
	fi
	local fn fns=() not nots=("$@")
	# skip __get_first_parent_that_is_not
	fns=("${FUNCNAME[@]:1}")

	# find a match
	for fn in "${fns[@]}"; do
		for not in "${nots[@]}"; do
			if [[ $fn == "$not" ]]; then
				continue 2
			fi
		done
		__print_lines "$fn"
		return 0
	done
	return 1
}

function __get_function_inner {
	local cmd="$1" code osb='{' csb='}' newline=$'\n'
	code="$(declare -f "$cmd")"
	# remove header and footer of function
	# this only works bash 5.2 and above:
	# code="${code#*$'\n{ \n'}"
	# code="${code%$'\n}'*}"
	# this works, but reveals the issue with the above is the escaping:
	# code="${code#*"$osb $newline"}"
	# code="${code%"$newline$csb"*}"
	# as such, use this wrapper, which is is clear to our intent:
	code="$(__get_substring_after_first "$code" "$osb $newline")"
	code="$(__get_substring_before_last "$code" "$newline$csb")"
	__print_string "$code"
}

# For semaphores, use $RANDOM$RANDOM as a single $RANDOM caused conflicts on Dorothy's CI tests when we didn't actually use semaphores, now that we use semaphores, we solve the underlying race conditions that caused the conflicts in the first place, however keep the double $RANDOM so it is enough entropy we don't have to bother for an existence check, here are the tests that had conflicts:
# https://github.com/bevry/dorothy/actions/runs/13038210988/job/36373738417#step:2:7505
# https://github.com/bevry/dorothy/actions/runs/13038210988/job/36373738417#step:2:12541
# as to why use [__get_semaphore] instead of [mktemp], is that we want [dorothy test] to check if we cleaned everything up, furthermore, [mktemp] actually makes the files, so you have to do more expensive [-s] checks
function __get_semaphore {
	# local name="${1:-"$RANDOM$RANDOM"}"
	local name="$RANDOM$RANDOM" dir="${XDG_CACHE_HOME:-"$HOME/.cache"}/dorothy/semaphores"
	__mkdirp "$dir" || return
	__print_lines "$dir/$name"
}

# As to why semaphores are even necessary,
# >( ... ) happens asynchronously, however the commands within >(...) happen synchronously, as such we can use this technique to know when they are done, otherwise on the very rare occasion the files may not exist or be incomplete by the time we get to to reading them: https://github.com/bevry/dorothy/issues/277
# Note that this waits forever on bash 4.1.0, as the [touch] commands that create our semaphore only execute after a [ctrl+c], other older and newer versions are fine
function __wait_for_semaphores {
	local semaphore_file
	for semaphore_file in "$@"; do
		while [[ ! -f $semaphore_file ]]; do
			# __debug_lines "waiting for:" "$semaphore_file" "$(basename -- "$semaphore_file")" "has:" "$(ls -l1 "$temp_directory")"
			sleep 0.01
		done
	done
}
function __wait_for_and_remove_semaphores {
	__wait_for_semaphores "$@" || return
	rm -f -- "$@" || return
}
function __wait_for_and_return_semaphores {
	local semaphore_file semaphore_status=0
	for semaphore_file in "$@"; do
		# needs -s as otherwise the file may exist but may not have finished writing, which would result in:
		# return: : numeric argument required
		while [[ ! -s $semaphore_file ]]; do
			# __debug_lines "waiting for:" "$semaphore_file" "$(basename -- "$semaphore_file")" "has:" "$(ls -l1 "$temp_directory")"
			sleep 0.01
		done
		# always return the failure
		# __wait_for_and_return_semaphores "$semaphore_file-with-0" "$semaphore_file-with-1" "$semaphore_file-with-0" # returns 1
		if [[ $semaphore_status -eq 0 ]]; then
			semaphore_status="$(<"$semaphore_file")"
		fi
	done
	rm -f -- "$@" || :
	return "$semaphore_status"
}

# =============================================================================
# Determine the bash version information, which is used to determine if we can use certain features or not.
#
# for example:
# __require_upgraded_bash -- BASH_VERSION_CURRENT != BASH_VERSION_LATEST, fail.
# BASH_VERSION_CURRENT -- 5.2.15(1)-release => 5.2.15
# $BASH_VERSION_MAJOR -- 5
# BASH_VERSION_MINOR -- 2
# BASH_VERSION_PATCH -- 15
# BASH_VERSION_LATEST -- 5.2.15
# IS_BASH_VERSION_OUTDATED -- yes/no

if [[ -z ${BASH_VERSION_CURRENT-} ]]; then
	# e.g. 5.2.15(1)-release => 5.2.15
	# https://www.gnu.org/software/bash/manual/bash.html#index-BASH_005fVERSINFO
	# [read] technique not needed as [BASH_VERSINFO] exists in all versions:
	# IFS=. read -r BASH_VERSION_MAJOR BASH_VERSION_MINOR BASH_VERSION_PATCH <<<"${BASH_VERSION%%(*}"
	BASH_VERSION_MAJOR="${BASH_VERSINFO[0]}"
	BASH_VERSION_MINOR="${BASH_VERSINFO[1]}"
	BASH_VERSION_PATCH="${BASH_VERSINFO[2]}"
	BASH_VERSION_CURRENT="${BASH_VERSION_MAJOR}.${BASH_VERSION_MINOR}.${BASH_VERSION_PATCH}"
	# trunk-ignore(shellcheck/SC2034)
	BASH_VERSION_LATEST='5.2.37' # https://ftp.gnu.org/gnu/bash/?C=M;O=D
	# any v5 version is supported by dorothy, earlier throws on empty array access which is annoying
	if [[ $BASH_VERSION_MAJOR -gt 4 || ($BASH_VERSION_MAJOR -eq 4 && $BASH_VERSION_MINOR -ge 4) ]]; then
		IS_BASH_VERSION_OUTDATED='no'
		function __require_upgraded_bash {
			:
		}
	else
		# trunk-ignore(shellcheck/SC2034)
		IS_BASH_VERSION_OUTDATED='yes'
		function __require_upgraded_bash {
			echo-style --stderr \
				--code="$0" ' ' --error='is incompatible with' ' ' --code="bash $BASH_VERSION" $'\n' \
				'Run ' --code='setup-util-bash' ' to upgrade capabilities, then run the prior command again.' || return
			return 45 # ENOTSUP 45 Operation not supported
		}
	fi
fi

# =============================================================================
# Configure bash for Dorothy best practices.

# Disable completion (not needed in scripts)
# bash v2: progcomp: If set, the programmable completion facilities (see Programmable Completion) are enabled. This option is enabled by default.
shopt -u progcomp

# Promote the cleanup of nested commands if its login shell terminates.
# bash v2: huponexit: If set, Bash will send SIGHUP to all jobs when an interactive login shell exits (see Signals).
shopt -s huponexit

# __require_lastpipe -- if lastpipe not supported, fail.
# Enable [cmd | read -r var] usage.
# bash v4.2:    lastpipe    If set, and job control is not active, the shell runs the last command of a pipeline not executed in the background in the current shell environment.
if shopt -s lastpipe 2>/dev/null; then
	BASH_CAN_LASTPIPE='yes'
	function __require_lastpipe {
		:
	}
else
	# trunk-ignore(shellcheck/SC2034)
	BASH_CAN_LASTPIPE='no'
	function __require_lastpipe {
		echo-style --stderr --error='Missing lastpipe support:' || return
		__require_upgraded_bash || return
	}
fi

# Disable functrace, as it causes unexpected behaviour when you know what you are doing.
# bash v3:  -T  functrace   DEBUG and RETURN traps get inherited to nested commands.
set +T

# Ensure errors can be captured.
# bash v3:  -E  errtrace    Any trap on ERR is inherited by shell functions, command substitutions, and commands executed in a subshell environment.
# bash v1:  -e  errexit     Return failure immediately upon non-conditional commands.
# bash v1:  -u  nounset     Return failure immediately when accessing an unset variable.
# bash v3:  -o  pipefail    The return value of a pipeline is the status of the last command to exit with a non-zero status, or zero if no command exited with a non-zero status.
# bash v4.4: inherit_errexit: Subshells inherit errexit.
# Ensure subshells also get the settings
set -Eeuo pipefail
# set +E # __try now crashes or never finishes on bash versions prior to 4.4
shopt -s inherit_errexit 2>/dev/null || : # has no effect on __try

# normally, with > it is right to left, however that makes sense as > portions of our statement are on the right-side
# however, __do is on the left side, so it should be left to right, such that this intuitively makes sense:
# __do --stderr=stderr.txt --stdout=stdout.txt --stderr=stdout --stdout=output.txt -stdout=null -- echo-style --stderr=my-stderr --stdout=my-stdout
# as this makes no sense in this context:
# __do --stdout=null --stdout=output.txt --stderr=stdout --stdout=stdout.txt --stderr=stderr.txt -- echo-style --stderr=my-stderr --stdout=my-stdout
#
# @todo re-add samasama support: https://gist.github.com/balupton/32bfc21702e83ad4afdc68929af41c23
function __do {
	# 🧙🏻‍♀️ the power is yours, send donations to github.com/sponsors/balupton
	if [[ $# -eq 0 ]]; then
		__print_lines "ERROR: ${FUNCNAME[0]}: Arguments are required." >&2
		return 22 # EINVAL 22 Invalid argument
	fi
	# externally, we support left to right, however internally, it is implemented right to left, so perform the conversion
	if [[ $1 != '--right-to-left' ]]; then
		local inversion=("$1")
		shift
		while [[ $# -ne 0 && $1 != '--' ]]; do
			inversion=("$1" "${inversion[@]}")
			shift
		done
		__do --right-to-left "${inversion[@]}" "$@"
		return
	fi
	shift # trim --right-to-left
	# explicit return handling is to have this work in conditional mode
	local arg="$1" arg_value arg_flag
	# process
	arg_value="${arg#*=}"
	arg_flag="${arg%%=*}" # [--stdout=], [--stderr=], [--output=] to [--stdout], [--stderr], [--output]
	shift
	case "$arg" in
	--)
		"$@"
		return
		;; # done

	# stdout+stderr alias
	'--redirect-stdout+stderr='*)
		__print_lines "ERROR: ${FUNCNAME[0]}: A to be implemented flag was provided: $arg. You probably want [--redirect-stdout=$arg_value --redirect-stderr=$arg_value] or [--redirect-output=$arg_value] instead. If you are doing a process substitution, you want the former suggestion and have the stderr process substitution output to >&2." >&2
		return 78 # NOSYS 78 Function not implemented
		;;
	'--copy-stdout+stderr='*)
		__print_lines "ERROR: ${FUNCNAME[0]}: A to be implemented flag was provided: $arg" >&2
		return 78 # NOSYS 78 Function not implemented
		;;

	# discard status
	--discard-status | --no-status | --status=no)
		# catch and discard the status
		__try -- __do --right-to-left "$@"
		return
		;;

	# aliases for discard stdout, stderr, output
	--discard-stdout | --no-stdout | --stdout=no)
		__do --right-to-left "$@" >/dev/null
		return
		;;
	--discard-stderr | --no-stderr | --stderr=no)
		__do --right-to-left "$@" 2>/dev/null
		return
		;;
	--discard-output | --no-output | --output=no | --discard-stdout+stderr | --no-stdout+stderr | --stdout+stderr=no)
		__do --right-to-left "$@" &>/dev/null
		return
		;;

	# redirect or copy, status, to a var target
	--redirect-status={*} | --copy-status={*})
		# trim starting { and trailing }, converting {<var>} to <var>
		local var
		var="$(__get_substring "$arg_value" 1 -1)"
		__return $? || return

		# catch the status
		local do_status
		__try {do_status} -- __do --right-to-left "$@"
		__return $? || return

		# apply the status ti the var target
		eval "$var=\$do_status"

		# return or discard the status
		case "$arg_flag" in
		--redirect-*) return 0 ;;
		--copy-*) return "$do_status" ;;
		*)
			__print_lines "ERROR: ${FUNCNAME[0]}: An unrecognised target was encountered: $arg" >&2
			return 76 # EPROCUNAVAIL 76 Bad procedure for program
			;;
		esac
		;;

	# redirect or copy, status, to a non-var target
	--redirect-status=* | --copy-status=*)
		# catch the status
		local do_status
		__try {do_status} -- __do --right-to-left "$@"
		__return $? || return

		# apply the status to the non-var target
		__do --redirect-stdout="$arg_value" -- __print_lines "$do_status"
		__return $? || return

		# return or discard the status
		case "$arg_flag" in
		--redirect-*) return 0 ;;
		--copy-*) return "$do_status" ;;
		*)
			__print_lines "ERROR: ${FUNCNAME[0]}: An unrecognised target was encountered: $arg" >&2
			return 76 # EPROCUNAVAIL 76 Bad procedure for program
			;;
		esac
		;;

	# redirect or copy, device files, to a var target
	--redirect-stdout={*} | --redirect-stderr={*} | --redirect-output={*} | --copy-stdout={*} | --copy-stderr={*} | --copy-output={*})
		# trim starting { and trailing }, converting {<var>} to <var>
		local var
		var="$(__get_substring "$arg_value" 1 -1)"
		__return $? || return

		# reset all var to prevent inheriting prior values of the same name if this one has a failure status which prevents updating the values
		eval "$var="
		__return $? || return

		# execute and write to a file
		# @todo consider a way to set the vars with what was written even if this fails, may not be a good idea
		local result_file
		result_file="$(mktemp)"
		__do --right-to-left "$arg_flag=$result_file" "$@"
		__return $? || return

		# load the file
		local result_value
		# trunk-ignore(shellcheck/SC2034)
		result_value="$(<"$result_file")"
		__return $? || return

		# clean the file
		rm -f -- "$result_file"
		__return $? || return

		# apply the result
		eval "$var=\$result_value"
		return
		;;

	# redirect, device files, to process substitution
	--redirect-stdout=\(*\) | --redirect-stderr=\(*\) | --redirect-output=\(*\))
		# trim starting ( and trailing ), converting (<code>) to <code>
		local code
		code="$(__get_substring "$arg_value" 1 -1)"
		__return $? || return

		# executing this in errexit mode:
		# __do --stderr='(cat; __return 10; __return 20)' -- echo-style --stderr=stderr-result --stdout=stdout-result; echo "status=[${statusvar-}] stdout=[${stdoutvar-}] stderr=[${stderrvar-}]"
		#
		# with this internal code, will not fail, as the return statuses of the subshell redirections are ignored:
		# --stderr) __do --right-to-left "$@" 2> >(eval "$code"; __return $? -- touch "$semaphore") ;;
		#
		# with this internal code, will fail with 20:
		# --stderr) __do --right-to-left "$@" 2> >(set +e; eval "$code"; printf '%s' "$?" >"$semaphore") ;;
		#
		# with this internal code, will fail with 10, which is what we want
		# --stderr) __do --right-to-left "$@" 2> >(__do --status="$semaphore" -- eval "$code") ;;

		# prepare our semaphore file that will track the exit status of the process substitution
		local semaphore_file_target
		semaphore_file_target="$(__get_semaphore)"
		__return $? || return

		# execute while tracking the exit status to our semaphore file
		# can't use `__try` as >() is a subshell, so the status variable application won't escape the subshell
		case "$arg_flag" in
		--redirect-stdout) __do --right-to-left "$@" >(__do --redirect-status="$semaphore_file_target" -- eval "$code") ;;
		--redirect-stderr) __do --right-to-left "$@" 2> >(__do --redirect-status="$semaphore_file_target" -- eval "$code") ;;
		--redirect-output) __do --right-to-left "$@" &> >(__do --redirect-status="$semaphore_file_target" -- eval "$code") ;;
		*)
			__print_lines "ERROR: ${FUNCNAME[0]}: An unrecognised target was encountered: $arg" >&2
			return 76 # EPROCUNAVAIL 76 Bad procedure for program
			;;
		esac

		# once completed, wait for and return the status of our process substitution
		__return $? -- __wait_for_and_return_semaphores "$semaphore_file_target"
		return
		;;

	# note that copying to a process substitution is not yet supported
	# @todo implement this
	--copy-stdout=\(*\) | --copy-stderr=\(*\) | --copy-output=\(*\))
		__print_lines "ERROR: ${FUNCNAME[0]}: A to be implemented flag was provided: $arg" >&2
		return 78 # NOSYS 78 Function not implemented
		;;

	# redirect, stdout, to various targets
	--redirect-stdout=*)
		case "$arg_value" in

		# redirect stdout to stdout, this is a no-op, continue to next
		1 | stdout | STDOUT | /dev/stdout)
			__do --right-to-left "$@"
			return
			;;

		# redirect stdout to stderr
		2 | stderr | STDERR | /dev/stderr)
			__do --right-to-left "$@" >&2
			return
			;;

		# redirect stdout to tty
		tty | TTY | /dev/tty)
			case "$TERMINAL_DEVICE_FILE" in
			# redirect stdout to /dev/tty
			tty | TTY | /dev/tty)
				__do --right-to-left "$@" >>/dev/tty
				return
				;;
			# redo with the actual target
			*)
				__do --right-to-left "$arg_flag=$TERMINAL_DEVICE_FILE" "$@"
				return
				;;
			esac
			;;

		# redirect stdout to null
		null | NULL | /dev/null)
			__do --right-to-left "$@" >/dev/null
			return
			;;

		# redirect stdout to FD target
		[0-9]*)
			__do --right-to-left "$@" >&"$arg_value"
			return
			;;

		# invalid
		'')
			__print_lines "ERROR: ${FUNCNAME[0]}: An unrecognised target was provided: $arg" >&2
			return 22 # EINVAL 22 Invalid argument
			;;

		# redirect stdout to file target
		*)
			__do --right-to-left "$@" >>"$arg_value"
			return
			;;

		# done with stdout redirect
		esac
		;;

	# copy, stdout, to various targets
	--copy-stdout=*)
		case "$arg_value" in

		# copy stdout to stdout, this behaviour is unspecified, should it double the data to stdout?
		1 | stdout | STDOUT | /dev/stdout)
			# @todo implement this
			__print_lines "ERROR: ${FUNCNAME[0]}: A to be implemented flag was provided: $arg" >&2
			return 78 # NOSYS 78 Function not implemented
			;;

		# copy stdout to stderr
		2 | stderr | STDERR | /dev/stderr)
			# @todo implement this
			__print_lines "ERROR: ${FUNCNAME[0]}: A to be implemented flag was provided: $arg" >&2
			return 78 # NOSYS 78 Function not implemented
			;;

		# copy stdout to tty
		tty | TTY | /dev/tty)
			# @todo implement this
			__print_lines "ERROR: ${FUNCNAME[0]}: A to be implemented flag was provided: $arg" >&2
			return 78 # NOSYS 78 Function not implemented
			;;

		# copy stdout to null
		null | NULL | /dev/null)
			# @todo implement this
			__print_lines "ERROR: ${FUNCNAME[0]}: A to be implemented flag was provided: $arg" >&2
			return 78 # NOSYS 78 Function not implemented
			;;

		# copy stdout to FD target
		[0-9]*)
			# @todo implement this
			__print_lines "ERROR: ${FUNCNAME[0]}: A to be implemented flag was provided: $arg" >&2
			return 78 # NOSYS 78 Function not implemented
			;;

		# invalid
		'')
			__print_lines "ERROR: ${FUNCNAME[0]}: An unrecognised target was provided: $arg" >&2
			return 22
			;;

		# copy stdout to file target
		*)
			# prepare our semaphore file that will track the exit status of the process substitution
			local semaphore_file_target
			semaphore_file_target="$(__get_semaphore)"
			__return $? || return

			# execute, keeping stdout, copying to the value target, and tracking the exit status to our semaphore file
			__do --right-to-left "$@" > >(
				set +e
				tee -a -- "$arg_value"
				printf '%s' "$?" >"$semaphore_file_target"
			)

			# once completed, wait for and return the status of our process substitution
			__return $? -- __wait_for_and_return_semaphores "$semaphore_file_target"
			return
			;;

		# done with stdout copy
		esac
		;;

	--redirect-stderr=*)
		case "$arg_value" in

		# redirect stderr to stdout
		1 | stdout | STDOUT | /dev/stdout)
			__do --right-to-left "$@" 2>&1
			return
			;;

		# redirect stderr to stderr, this is a no-op, continue to next
		2 | stderr | STDERR | /dev/stderr)
			__do --right-to-left "$@"
			return
			;;

		# redirect stderr to tty
		tty | TTY | /dev/tty)
			case "$TERMINAL_DEVICE_FILE" in
			# redirect stdout to /dev/tty
			tty | TTY | /dev/tty)
				__do --right-to-left "$@" 2>>/dev/tty
				return
				;;
			# redo with the actual target
			*)
				__do --right-to-left "$arg_flag=$TERMINAL_DEVICE_FILE" "$@"
				return
				;;
			esac
			;;

		# redirect stderr to null
		null | NULL | /dev/null)
			__do --right-to-left "$@" 2>/dev/null
			return
			;;

		# redirect stderr to FD target
		[0-9]*)
			__do --right-to-left "$@" 2>&"$arg_value"
			return
			;;

		# invalid
		'')
			__print_lines "ERROR: ${FUNCNAME[0]}: An unrecognised target was provided: $arg" >&2
			return 22 # EINVAL 22 Invalid argument
			;;

		# redirect stderr to file target
		*)
			__do --right-to-left "$@" 2>>"$arg_value"
			return
			;;

		# done with stderr redirect
		esac
		;;

	# copy, stderr, to various targets
	--copy-stderr=*)
		case "$arg_value" in

		# copy stderr to stdout
		1 | stdout | STDOUT | /dev/stdout)
			# @todo implement this
			__print_lines "ERROR: ${FUNCNAME[0]}: A to be implemented flag was provided: $arg" >&2
			return 78 # NOSYS 78 Function not implemented
			;;

		# copy stderr to stderr, this behaviour is unspecified, should it double the data to stderr?
		2 | stderr | STDERR | /dev/stderr)
			# @todo implement this
			__print_lines "ERROR: ${FUNCNAME[0]}: A to be implemented flag was provided: $arg" >&2
			return 78 # NOSYS 78 Function not implemented
			;;

		# copy stderr to tty
		tty | TTY | /dev/tty)
			# @todo implement this
			__print_lines "ERROR: ${FUNCNAME[0]}: A to be implemented flag was provided: $arg" >&2
			return 78 # NOSYS 78 Function not implemented
			;;

		# copy stderr to null
		null | NULL | /dev/null)
			# @todo implement this
			__print_lines "ERROR: ${FUNCNAME[0]}: A to be implemented flag was provided: $arg" >&2
			return 78 # NOSYS 78 Function not implemented
			;;

		# copy stderr to FD target
		[0-9]*)
			# @todo implement this
			__print_lines "ERROR: ${FUNCNAME[0]}: A to be implemented flag was provided: $arg" >&2
			return 78 # NOSYS 78 Function not implemented
			;;

		# invalid
		'')
			__print_lines "ERROR: ${FUNCNAME[0]}: An unrecognised target was provided: $arg" >&2
			return 22
			;;

		# copy stderr to file target
		*)
			# prepare our semaphore file that will track the exit status of the process substitution
			local semaphore_file_target
			semaphore_file_target="$(__get_semaphore)"
			__return $? || return

			# execute, keeping stderr, copying to the value target, and tracking the exit status to our semaphore file
			__do --right-to-left "$@" 2> >(
				set +e
				tee -a -- "$arg_value" >&2
				printf '%s' "$?" >"$semaphore_file_target"
			)

			# once completed, wait for and return the status of our process substitution
			__return $? -- __wait_for_and_return_semaphores "$semaphore_file_target"
			return
			;;

		# done with stderr copy
		esac
		;;

	--redirect-output=*)
		case "$arg_value" in

		# redirect stderr to stdout
		1 | stdout | STDOUT | /dev/stdout)
			__do --right-to-left "$@" 2>&1
			return
			;;

		# redirect stdout to stderr
		2 | stderr | STDERR | /dev/stderr)
			__do --right-to-left "$@" >&2
			return
			;;

		# redirect stderr to stdout, then stdout to tty, as `&>>` is not supported
		tty | TTY | /dev/tty)
			case "$TERMINAL_DEVICE_FILE" in
			# stderr to stdout, such that and then, both stdout and stderr are redirected to tty
			tty | TTY | /dev/tty)
				__do --right-to-left "$@" >>/dev/tty 2>&1
				return
				;;
			# redo with the actual target
			*)
				__do --right-to-left "$arg_flag=$TERMINAL_DEVICE_FILE" "$@"
				return
				;;
			esac
			;;

		# redirect output to null
		null | NULL | /dev/null | no)
			__do --right-to-left "$@" &>/dev/null
			return
			;;

		# redirect stderr to stdout, such that and then, both stdout and stderr are redirected to the fd target
		[0-9]*)
			__do --right-to-left "$@" 1>&"$target" 2>&1
			return
			;;

		# invalid
		'')
			__print_lines "ERROR: ${FUNCNAME[0]}: An unrecognised target was provided: $item" >&2
			return 22 # EINVAL 22 Invalid argument
			;;

		# redirect stderr to stdout, such that and then, both stdout and stderr are redirect to the file target
		*)
			__do --right-to-left "$@" >"$arg_value" 2>&1
			return
			;;

		# done with output redirect
		esac
		;;

	# copy, output, to various targets
	--copy-output=*)
		case "$arg_value" in

		# copy output to stdout, this behaviour is unspecified, should it double the data to stderr?
		1 | stdout | STDOUT | /dev/stdout)
			# @todo implement this
			__print_lines "ERROR: ${FUNCNAME[0]}: A to be implemented flag was provided: $arg" >&2
			return 78 # NOSYS 78 Function not implemented
			;;

		# copy output to stderr, this behaviour is unspecified, should it double the data to stderr?
		2 | stderr | STDERR | /dev/stderr)
			# @todo implement this
			__print_lines "ERROR: ${FUNCNAME[0]}: A to be implemented flag was provided: $arg" >&2
			return 78 # NOSYS 78 Function not implemented
			;;

		# copy output to tty
		tty | TTY | /dev/tty)
			# @todo implement this
			__print_lines "ERROR: ${FUNCNAME[0]}: A to be implemented flag was provided: $arg" >&2
			return 78 # NOSYS 78 Function not implemented
			;;

		# copy stderr to null
		null | NULL | /dev/null)
			# @todo implement this
			__print_lines "ERROR: ${FUNCNAME[0]}: A to be implemented flag was provided: $arg" >&2
			return 78 # NOSYS 78 Function not implemented
			;;

		# copy output to FD target
		[0-9]*)
			# @todo implement this
			__print_lines "ERROR: ${FUNCNAME[0]}: A to be implemented flag was provided: $arg" >&2
			return 78 # NOSYS 78 Function not implemented
			;;

		# invalid
		'')
			__print_lines "ERROR: ${FUNCNAME[0]}: An unrecognised target was provided: $arg" >&2
			return 22
			;;

		# copy output to file target, note that this functionality is ambiguous, fail instead
		*)
			# @todo implement this
			__print_lines "ERROR: ${FUNCNAME[0]}: A to be implemented flag was provided: $arg. You probably want [--copy-stdout+stderr=$arg_value] or [--redirect-output=stderr --copy-stderr=$arg_value --redirect-output=tty] instead." >&2
			return 78 # NOSYS 78 Function not implemented
			;;

		# done with stderr copy
		esac
		;;

	# unknown arg
	*)
		__print_lines "ERROR: ${FUNCNAME[0]}: An unrecognised target was provided: $arg" >&2
		return 22 # EINVAL 22 Invalid argument
		;;

	# done with arg
	esac

	# it should never have reached here from the explicit returns
	__print_lines "ERROR: ${FUNCNAME[0]}: An unhandled argument provided: $arg" >&2
	return 29 # ESPIPE 29 Illegal seek
}

# debug helpers, that are overwritten within [dorothy-internals]
function dorothy_try__context_lines {
	:
}
function dorothy_try__dump_lines {
	:
}

# See [dorothy-internals] for details, this is [i6a]
function dorothy_try__trap_outer {
	# do not use local, as this is not executed as a function
	DOROTHY_TRY__TRAP_STATUS=$?
	DOROTHY_TRY__TRAP_LOCATION="${BASH_SOURCE[0]}:${LINENO}:${FUNCNAME-}:$DOROTHY_TRY__SUBSHELL:${BASH_SUBSHELL-}:$-:$BASH_VERSION"
	if [[ $DOROTHY_TRY__TRAP_STATUS -eq 1 && -f $DOROTHY_TRY__FILE_STATUS ]]; then
		# Bash versions 4.2 and 4.3 will change a caught but thrown or continued exit status to 1
		# So we have to restore our saved one from the throw-in-trap-subshell workaround
		DOROTHY_TRY__TRAP_STATUS="$(<"$DOROTHY_TRY__FILE_STATUS")"
		dorothy_try__context_lines "REPLACED: $DOROTHY_TRY__TRAP_STATUS" "LOCATION: $DOROTHY_TRY__TRAP_LOCATION" || :
	fi

	# if we are applicable, necessary for `do recursed [subshell]` when not using --no-status
	if [[ -z ${DOROTHY_TRY__CONTEXT-} ]]; then
		dorothy_try__dump_lines 'NO CONTEXT' || :
	elif __is_not_errexit; then
		# not applicable, as we are not in errexit, so want to continue as usual
		dorothy_try__dump_lines "NO ERREXIT $-" || :
	else
		# we are in errexit, we caught a thrown exception, a crash will occur and EXIT will fire, unless we return anything
		# returning a non-zero exit status in bash v4.4 and up causes the non-zero exit status to be returned to the caller
		# returning a non-zero exit status in bash versions earlier that v4.4 will cause 0 to be returned to the caller
		# I have been unable to find a way for a non-zero exit status to propagate to the caller in bash versions earlier than v4.4
		# using [__return ...] instead of [return ...] just causes the crash to occur

		# check subshell
		# in theory, a subshell check only matters if the current subshell is deeper than the original subshell
		# if our subshell is higher, then it doesn't matter... in theory, however if we are in a higher subshell, it means something has gone terribly wrong, as it means our trap is firing in contexts it should not be
		if [[ $DOROTHY_TRY__SUBSHELL == "${BASH_SUBSHELL-}" ]]; then
			# we are in the same subshell, so our changes to DOROTHY_TRY__STATUS will persist
			dorothy_try__context_lines "SHARE: $DOROTHY_TRY__TRAP_STATUS" "LOCATION: $DOROTHY_TRY__TRAP_LOCATION" || :
			DOROTHY_TRY__STATUS="$DOROTHY_TRY__TRAP_STATUS"
		else
			# lacking this causes nearly all subshell executions to fail on 3.2, 4.0, 4.2
			dorothy_try__context_lines "SAVE: $DOROTHY_TRY__TRAP_STATUS" "LOCATION: $DOROTHY_TRY__TRAP_LOCATION" || :
			{ __mkdirp "$DOROTHY_TRY__DIR" && __print_lines "$DOROTHY_TRY__TRAP_STATUS" >"$DOROTHY_TRY__FILE_STATUS"; } || :
			# wait for semaphores if needed
			if [[ $BASH_VERSION_MAJOR -eq 4 && ($BASH_VERSION_MINOR -eq 2 || $BASH_VERSION_MINOR -eq 3) ]]; then
				__wait_for_semaphores "$DOROTHY_TRY__FILE_STATUS"
			fi
		fi

		# return the status accordingly
		if [[ ${FUNCNAME-} == 'dorothy_try__wrapper' ]]; then
			dorothy_try__context_lines "SKIP: $DOROTHY_TRY__TRAP_STATUS" "LOCATION: $DOROTHY_TRY__TRAP_LOCATION" || :
			return 0
		elif [[ -n ${FUNCNAME-} ]]; then
			# Only return the status on if we are the same subshell, or we are on bash v4.4 and up
			# Earlier versions of bash will turn a `return <non-zero>` into a `return 0`: https://stackoverflow.com/q/79495360/130638
			# As such for earlier versions of bash, we have to either:
			# - use `__return <non-zero>` to throw
			# - or not do any action, allowing the default action to propagate
			# In bash v4.2 and v4.3 both of these two options will change the behaviour to `return 1`, as such we have to ensure our status file is written before we continue
			if [[ $BASH_VERSION_MAJOR -gt 4 || ($BASH_VERSION_MAJOR -eq 4 && $BASH_VERSION_MINOR -ge 4) ]]; then
				dorothy_try__context_lines "RETURN NEW BASH: $DOROTHY_TRY__TRAP_STATUS" "LOCATION: $DOROTHY_TRY__TRAP_LOCATION" "FUNCNAME: ${FUNCNAME[*]}" || :
				return "$DOROTHY_TRY__TRAP_STATUS"
			elif [[ "$(__get_index_of_parent_function 'dorothy_try__wrapper' || :)" -eq 1 ]]; then
				# this is useful regardless of subshell same or same shell, as it will still return us to the wrapper which is what we want
				dorothy_try__context_lines "RETURN SKIPS TO TRY: $DOROTHY_TRY__TRAP_STATUS" "LOCATION: $DOROTHY_TRY__TRAP_LOCATION" "FUNCNAME: ${FUNCNAME[*]}" || :
				return "$DOROTHY_TRY__TRAP_STATUS" # bash v3.2, 4.0 will turn this into [return 0]; bash v4.2, 4.3 will turn this into [return 1]
			elif [[ $DOROTHY_TRY__SUBSHELL != "${BASH_SUBSHELL-}" ]]; then
				# throw to any effective subshell
				dorothy_try__context_lines "THROW TO SUBSHELL OLD BASH: $DOROTHY_TRY__TRAP_STATUS" "LOCATION: $DOROTHY_TRY__TRAP_LOCATION" "FUNCNAME: ${FUNCNAME[*]}" || :
				# Bash 3.2, 4.0 will crash
				# Bash 4.2, 4.3 will be ok
			elif [[ "$(__get_index_of_parent_function 'dorothy_try__wrapper' '__do' '__try' || :)" -eq 1 ]]; then
				dorothy_try__context_lines "RETURN TO PARENT SUBSHELL OLD BASH: $DOROTHY_TRY__TRAP_STATUS" "LOCATION: $DOROTHY_TRY__TRAP_LOCATION" "FUNCNAME: ${FUNCNAME[*]}" || :
				return "$DOROTHY_TRY__TRAP_STATUS" # for some reason this changes to [return 0] even on 4.2 and 4.3, however this is going to one of our functions, which will load the STORE or SAVED value
				# on bash 3.2 and 4.0 this still results in a crash on: do recursed[subshell] --no-status
				# however that is mitigated by the [RETURN SKIPS TO TRY] functionality earlier, except on macos bash 3.2 which behaves differently and still crashes
				# however on 4.2 and 4.3 it lets it pass
				# note that the crashes are still the correct exit status and are not continuing
			else
				if [[ $BASH_VERSION_MAJOR -eq 4 && ($BASH_VERSION_MINOR -eq 2 || $BASH_VERSION_MINOR -eq 3) ]]; then
					dorothy_try__context_lines "THROW TO UN-CATCHABLE OLD BASH: $DOROTHY_TRY__TRAP_STATUS" "LOCATION: $DOROTHY_TRY__TRAP_LOCATION" "FUNCNAME: ${FUNCNAME[*]}" || :
					# return "$DOROTHY_TRY__TRAP_STATUS" # for some reason this gets converted into `return 0` here, despite typical behaviour of bash 4.2 and 4.3 converting this to a `return 1` instead
				else
					dorothy_try__context_lines "CRASH TO UN-CATCHABLE OLD BASH: $DOROTHY_TRY__TRAP_STATUS" "LOCATION: $DOROTHY_TRY__TRAP_LOCATION" "FUNCNAME: ${FUNCNAME[*]}" || :
				fi
			fi
		else
			dorothy_try__context_lines "EXIT: $DOROTHY_TRY__TRAP_STATUS" "LOCATION: $DOROTHY_TRY__TRAP_LOCATION" || :
			# exit "$DOROTHY_TRY__TRAP_STATUS"
			# ^ by not returning or exiting, we allow the caller to exit itself
		fi
	fi
}
dorothy_try__trap_inner="$(__get_function_inner dorothy_try__trap_outer)"
function dorothy_try__wrapper {
	local continued_status
	# trunk-ignore(shellcheck/SC2064)
	trap "$dorothy_try__trap_inner" ERR

	# handle accordingly to bash version
	if [[ $BASH_VERSION_MAJOR -gt 4 || ($BASH_VERSION_MAJOR -eq 4 && $BASH_VERSION_MINOR -ge 4) ]]; then
		# bash version 4.4 and up
		dorothy_try__context_lines "DIRECT: ${DOROTHY_TRY__COMMAND[0]}" || :
		"${DOROTHY_TRY__COMMAND[@]}"
		# if errexit is enabled, we depend on the trap, and would not have reached here, which is fine
		# if errexit is disabled, the trap may or may not have fired, depending on the bash version, in which we need the status via the technique below
		continued_status=$?
	elif __is_subshell_function "${DOROTHY_TRY__COMMAND[0]}"; then
		if __is_errexit; then
			# this workaround is necessary to prevent macos bash v3.2 from crashing on `try __solo[subshell]`
			# compiled bash v3.2 does not have this issue, and is not harmed by this logic path
			# this has no effect on the macos bash v3.2 crash of: do recursed[subshell] --no-status
			dorothy_try__context_lines "ERREXIT SUBSHELL WORKAROUND: ${DOROTHY_TRY__COMMAND[0]}" || :
			set +e
			(
				set -e
				"${DOROTHY_TRY__COMMAND[@]}"
			)
			continued_status=$?
			set -e
		else
			dorothy_try__context_lines "SUBSHELL: ${DOROTHY_TRY__COMMAND[0]}" || :
			"${DOROTHY_TRY__COMMAND[@]}"
			continued_status=$?
		fi
	else
		# yolo it, and detect failure within the trap
		dorothy_try__context_lines "YOLO: ${DOROTHY_TRY__COMMAND[0]}" || :
		"${DOROTHY_TRY__COMMAND[@]}"
		continued_status=$?
	fi

	# capture status in case of set +e
	dorothy_try__context_lines "CONTINUED: ${DOROTHY_TRY__COMMAND[0]}: $continued_status" || :
	if [[ $continued_status -ne 0 ]]; then
		DOROTHY_TRY__STATUS="$continued_status"
	fi

	# we've stored the status, we return success
	return 0
}
# NOTE: DO NOT IMPLEMENT `--discard-status` and `--redirect-status={<status-var>}` as it means you will need to do this:
# `__try --discard-status --` same as `__try --`
# `__try --redirect-status={<status-var>} --` same as `__try {<status-var>} --`
# implement `__try --copy-status={<status-var>} --` such that it is applied and returned
# then you will discover that this then makes it seem that `__try --` returns/keeps the status, but it does not
# as such, trying for compat with `__do` is silly, as they are different
function __try {
	local item cmd=() exit_status_variable=''
	while [[ $# -ne 0 ]]; do
		item="$1"
		shift
		case "$item" in
		'--')
			cmd+=("$@")
			shift $#
			break
			;;
		{*}) exit_status_variable="$(__get_substring "$item" 1 -1)" ;; # trim starting { and trailing }
		*)
			__print_lines "ERROR: ${FUNCNAME[0]}: An unrecognised flag was provided: $item" >&2
			return 22 # EINVAL 22 Invalid argument
			;;
		esac
	done

	# prepare globals
	DOROTHY_TRY__COUNT="${DOROTHY_TRY__COUNT:-0}" # so we can remove our trap once all tries are finished

	# prepare locals specific to our context
	local DOROTHY_TRY__STATUS=
	local DOROTHY_TRY__CONTEXT
	DOROTHY_TRY__CONTEXT="$BASH_VERSION_CURRENT-$(__get_first_parent_that_is_not 'eval_capture' '__do' '__try' 'dorothy_try_wrapper' || :)-$RANDOM"
	local DOROTHY_TRY__COMMAND=("${cmd[@]}")
	local DOROTHY_TRY__SUBSHELL="${BASH_SUBSHELL-}"
	local DOROTHY_TRY__DIR="${XDG_CACHE_HOME:-"$HOME/.cache"}/dorothy-try"
	local DOROTHY_TRY__FILE_STATUS="$DOROTHY_TRY__DIR/$DOROTHY_TRY__CONTEXT.status"

	# execute the command within our wrapper, such that we can handle edge cases, and identify it inside our trap
	DOROTHY_TRY__COUNT="$((DOROTHY_TRY__COUNT + 1))" # increment the count
	dorothy_try__wrapper
	DOROTHY_TRY__COUNT="$((DOROTHY_TRY__COUNT - 1))"
	if [[ $DOROTHY_TRY__COUNT -eq 0 ]]; then
		# if all our tries have now finished, remove the lingering trap
		trap - ERR
	fi

	# load the exit status if necessary
	if [[ -f $DOROTHY_TRY__FILE_STATUS ]]; then
		local loaded_status
		loaded_status="$(<"$DOROTHY_TRY__FILE_STATUS")"
		if [[ $loaded_status -ne $DOROTHY_TRY__STATUS ]]; then
			dorothy_try__context_lines "LOADED: $loaded_status    PRIOR: $DOROTHY_TRY__STATUS    NEEDED" || :
		else
			dorothy_try__context_lines "LOADED: $loaded_status    PRIOR: $DOROTHY_TRY__STATUS    SAME" || :
		fi
		DOROTHY_TRY__STATUS="$loaded_status"
		rm -f -- "$DOROTHY_TRY__FILE_STATUS" || :
	fi

	# apply the exit status
	dorothy_try__context_lines "RESULT: ${DOROTHY_TRY__STATUS:-0}" || :
	if [[ -n $exit_status_variable ]]; then
		eval "$exit_status_variable=${DOROTHY_TRY__STATUS:-0}"
	fi

	# return success
	return 0
}

function eval_capture {
	local item cmd=() exit_status_variable='' stdout_variable='' stderr_variable='' output_variable='' stdout_target='/dev/stdout' stderr_target='/dev/stderr'
	while [[ $# -ne 0 ]]; do
		item="$1"
		shift
		case "$item" in
		'--help')
			cat <<-EOF >/dev/stderr
				ABOUT:
				Capture or ignore exit status, without disabling errexit, and without a subshell.
				Copyright 2023+ Benjamin Lupton <b@lupton.cc> (https://balupton.com)
				Written for Dorothy (https://github.com/bevry/dorothy)
				Licensed under the Reciprocal Public License 1.5 (http://spdx.org/licenses/RPL-1.5.html)

				USAGE:
				local status=0 stdout='' stderr='' output=''
				eval_capture [--status-var=status] [--stdout-var=stdout] [--stderr-var=stderr] [--output-var=output] [--stdout-target=/dev/stdout] [--stderr-target=/dev/stderr] [--output-target=...] [--no-stdout] [--no-stderr] [--no-output] [--] cmd ...

				QUIRKS:
				Using --stdout-var will set --stdout-target=/dev/null
				Using --stderr-var will set --stderr-target=/dev/null
				Using --output-var will set --stdout-target=/dev/null --stderr-target=/dev/null

				WARNING:
				If [eval_capture] triggers something that still does function invocation via [if], [&&], [||], or [!], then errexit will still be disabled for that invocation.
				This is a limitation of bash, with no workaround (at least at the time of bash v5.2).
				Refer to https://github.com/bevry/dorothy/blob/master/docs/bash/errors.md for guidance.
			EOF
			return 22 # EINVAL 22 Invalid argument
			;;
		'--status-var='* | '--statusvar='*)
			exit_status_variable="${item#*=}"
			;;
		'--stdout-var='* | '--stdoutvar='*)
			stdout_variable="${item#*=}"
			stdout_target='/dev/null'
			;;
		'--stderr-var='* | '--stderrvar='*)
			stderr_variable="${item#*=}"
			stderr_target='/dev/null'
			;;
		'--output-var='* | '--outputvar='*)
			output_variable="${item#*=}"
			stdout_target='/dev/null'
			stderr_target='/dev/null'
			;;
		'--no-stdout' | '--ignore-stdout' | '--stdout=no')
			stdout_target='/dev/null'
			;;
		'--no-stderr' | '--ignore-stderr' | '--stderr=no')
			stderr_target='/dev/null'
			;;
		'--no-output' | '--ignore-output' | '--output=no')
			stdout_target='/dev/null'
			stderr_target='/dev/null'
			;;
		'--stdout-target='* | '--stdout-pipe='* | '--stdoutpipe='*)
			stdout_target="${item#*=}"
			;;
		'--stderr-target='* | '--stderr-pipe='* | '--stderrpipe='*)
			stderr_target="${item#*=}"
			;;
		'--output-target='* | '--output-pipe='* | '--outputpipe='*)
			stdout_target="${item#*=}"
			stderr_target="$stdout_target"
			;;
		'--')
			cmd+=("$@")
			shift $#
			break
			;;
		'-'*)
			__print_lines "ERROR: ${FUNCNAME[0]}: An unrecognised flag was provided: $item" >/dev/stderr
			return 22 # EINVAL 22 Invalid argument
			;;
		*)
			cmd+=(
				"$item"
				"$@"
			)
			shift $#
			break
			;;
		esac
	done

	# prep our values
	local do=(__do)
	# status
	if [[ -n $exit_status_variable ]]; then
		do+=("--redirect-status={$exit_status_variable}")
	else
		do+=(--discard-status)
	fi
	# vars
	if [[ -n $stdout_variable ]]; then
		do+=("--copy-stdout={$stdout_variable}")
	fi
	if [[ -n $stderr_variable ]]; then
		do+=("--copy-stderr={$stderr_variable}")
	fi
	if [[ -n $output_variable ]]; then
		do+=("--copy-output={$output_variable}")
	fi
	# targets
	if [[ -n $stdout_target ]]; then
		do+=("--redirect-stdout=$stdout_target")
	fi
	if [[ -n $stderr_target ]]; then
		do+=("--redirect-stderr=$stderr_target")
	fi
	# execute to the newer function
	"${do[@]}" -- "${cmd[@]}"
}

# disable failglob (nullglob is better)
# bash v3: failglob: If set, patterns which fail to match filenames during filename expansion result in an expansion error.
shopt -u failglob

# bash v1?: nullglob: If set, Bash allows filename patterns which match no files to expand to a null string, rather than themselves.
shopt -s nullglob

# __require_globstar -- if globstar not supported, fail.
# bash v4: globstar: If set, the pattern ‘**’ used in a filename expansion context will match all files and zero or more directories and subdirectories. If the pattern is followed by a ‘/’, only directories and subdirectories match.
if shopt -s globstar 2>/dev/null; then
	BASH_CAN_GLOBSTAR='yes'
	function __require_globstar {
		:
	}
else
	# trunk-ignore(shellcheck/SC2034)
	BASH_CAN_GLOBSTAR='no'
	function __require_globstar {
		echo-style --stderr --error='Missing globstar support:' || return
		__require_upgraded_bash || return
	}
fi

# __require_extglob -- if extglob not supported, fail.
# bash v5: extglob: If set, the extended pattern matching features described above (see Pattern Matching) are enabled.
if shopt -s extglob 2>/dev/null; then
	BASH_CAN_EXTGLOB='yes'
	function __require_extglob {
		:
	}
else
	# trunk-ignore(shellcheck/SC2034)
	BASH_CAN_EXTGLOB='no'
	function __require_extglob {
		echo-style --stderr --error='Missing extglob support:' || return
		__require_upgraded_bash || return
	}
fi

# CONSIDER
# bash v5: localvar_inherit: If set, local variables inherit the value and attributes of a variable of the same name that exists at a previous scope before any new value is assigned. The nameref attribute is not inherited.
# shopt -s localvar_inherit 2>/dev/null || :

# bash v1?: localvar_unset: If set, calling unset on local variables in previous function scopes marks them so subsequent lookups find them unset until that function returns. This is identical to the behavior of unsetting local variables at the current function scope.
# shopt -s localvar_unset 2>/dev/null || :

# =============================================================================
# Shim bash functionality that is inconsistent between bash versions.

# put changelog entries in [versions.md]

# Bash >= 4, < 4
if [[ $BASH_VERSION_MAJOR -ge 4 ]]; then
	# bash >= 4
	BASH_CAN_READ_I='yes'
	BASH_CAN_READ_DECIMAL_TIMEOUT='yes'
	BASH_CAN_PIPE_STDOUT_AND_STDERR_SHORTHAND='yes'
	function __get_read_decimal_timeout {
		__print_lines "$1"
	}
else
	# bash < 4
	# Bash versions prior to 4, will error with "invalid timeout specification" on decimal timeouts
	# trunk-ignore(shellcheck/SC2034)
	BASH_CAN_READ_I='no'
	# trunk-ignore(shellcheck/SC2034)
	BASH_CAN_READ_DECIMAL_TIMEOUT='no'
	# trunk-ignore(shellcheck/SC2034)
	BASH_CAN_PIPE_STDOUT_AND_STDERR_SHORTHAND='no'
	function __get_read_decimal_timeout {
		# -lt requires integers, so we need to use regexp instead
		if [[ -n $1 && $1 =~ ^0[.] ]]; then
			__print_lines 1
		else
			__print_lines "$1"
		fi
	}
fi

# Bash >= 5.1, >= 4, < 4
if [[ $BASH_VERSION_MAJOR -eq 5 && $BASH_VERSION_MINOR -ge 1 ]]; then
	# bash >= 5.1
	function __uppercase_first_letter {
		# trim -- prefix
		if [[ ${1-} == '--' ]]; then
			shift
		fi
		# proceed
		__print_lines "${1@u}"
	}
	function __uppercase_string {
		# trim -- prefix
		if [[ ${1-} == '--' ]]; then
			shift
		fi
		# proceed
		__print_lines "${1@U}"
	}
	function __lowercase_string {
		# trim -- prefix
		if [[ ${1-} == '--' ]]; then
			shift
		fi
		# proceed
		__print_lines "${1@L}"
	}
	# @Q is available, however it is strange, so don't shim
else
	# bash < 5.1
	# @Q is no longer available, however it is strange, so don't shim
	if [[ $BASH_VERSION_MAJOR -eq 4 ]]; then
		# bash >= 4
		function __uppercase_first_letter {
			# trim -- prefix
			if [[ ${1-} == '--' ]]; then
				shift
			fi
			# proceed
			__print_lines "${1^}"
		}
		function __uppercase_string {
			# trim -- prefix
			if [[ ${1-} == '--' ]]; then
				shift
			fi
			# proceed
			__print_lines "${1^^}"
		}
		function __lowercase_string {
			# trim -- prefix
			if [[ ${1-} == '--' ]]; then
				shift
			fi
			# proceed
			__print_lines "${1,,}"
		}
	else
		# bash < 4
		function __uppercase_first_letter {
			# trim -- prefix
			if [[ ${1-} == '--' ]]; then
				shift
			fi
			# proceed
			local input="$1"
			local first_char="${input:0:1}"
			local rest="${input:1}"
			__print_lines "$(tr '[:lower:]' '[:upper:]' <<<"$first_char")$rest"
		}
		function __uppercase_string {
			# trim -- prefix
			if [[ ${1-} == '--' ]]; then
				shift
			fi
			# proceed
			tr '[:lower:]' '[:upper:]' <<<"$1" || return
		}
		function __lowercase_string {
			# trim -- prefix
			if [[ ${1-} == '--' ]]; then
				shift
			fi
			# proceed
			tr '[:upper:]' '[:lower:]' <<<"$1" || return
		}
	fi
fi

# Bash >= 4.2, < 4.2
if [[ $BASH_VERSION_MAJOR -ge 5 || ($BASH_VERSION_MAJOR -eq 4 && $BASH_VERSION_MINOR -ge 2) ]]; then
	# bash >= 4.2
	# p.  Negative subscripts to indexed arrays, previously errors, now are treated
	#     as offsets from the maximum assigned index + 1.
	# q.  Negative length specifications in the ${var:offset:length} expansion,
	#     previously errors, are now treated as offsets from the end of the variable.
	function __is_var_set {
		# -v varname: True if the shell variable varname is set (has been assigned a value).
		# for some reason [[ -v $1 ]] has a syntax error, and shellcheck doesn't like [ -v "$1" ]
		test -v "$1" || return
	}
else
	# bash < 4.2
	function __is_var_set {
		[[ -n ${!1-} ]] || return
	}
fi

# Shim Array Support
# Bash v4 has the following capabilities, which must be shimmed in earlier versions:
# - `readarray` and `mapfile`
#     - our shim provides a workaround
# - associative arrays
#     - no workaround, you are out of luck
# - iterating empty arrays:
#     - broken: `arr=(); for item in "${arr[@]}"; do ...`
#     - broken: `arr=(); for item in "${!arr[@]}"; do ...`
#     - use: `[[ "${#array[@]}" -ne 0 ]] && for ...`
#     - or if you don't care for empty option_inputs, use: `[[ -n "$arr" ]] && for ...`
#
# BASH_ARRAY_CAPABILITIES -- string that stores the various capabilities: mapfile[native] mapfile[shim] readarray[native] empty[native] empty[shim] associative
# has_array_capability -- check if a capability is provided by the current bash version
# __require_array -- require a capability to be provided by the current bash version, otherwise fail
# mapfile -- shim [mapfile] for bash versions that do not have it

# note that there is no need to do [__require_array 'mapfile'] as `bash.bash` makes [mapfile] always available, it is just the native version that is not available

function __has_array_capability {
	local arg
	for arg in "$@"; do
		if [[ $BASH_ARRAY_CAPABILITIES != *" $arg"* ]]; then
			return 1
		fi
	done
}

function __require_array {
	if ! __has_array_capability "$@"; then
		echo-style --stderr --error='Array support insufficient, required:' ' ' --code="$*" || return
		__require_upgraded_bash || return
	fi
}

BASH_ARRAY_CAPABILITIES=''
if [[ $BASH_VERSION_MAJOR -ge 5 ]]; then
	# bash >= 5
	BASH_ARRAY_CAPABILITIES+=' mapfile[native] readarray[native] empty[native]'
	if [[ $BASH_VERSION_MINOR -ge 1 ]]; then
		# bash >= 5.1
		BASH_ARRAY_CAPABILITIES+=' associative'
	fi
elif [[ $BASH_VERSION_MAJOR -ge 4 ]]; then
	# bash >= 4
	BASH_ARRAY_CAPABILITIES+=' mapfile[native] readarray[native]'
	if [[ $BASH_VERSION_MINOR -ge 4 ]]; then
		# bash >= 4.4
		# finally supports nounset without crashing on defined empty arrays
		BASH_ARRAY_CAPABILITIES+=' empty[native]'
	else
		# bash 4.0, 4.1, 4.2, 4.3
		BASH_ARRAY_CAPABILITIES+=' empty[shim]'
		set +u # disable nounset to prevent crashes on empty arrays
	fi
elif [[ $BASH_VERSION_MAJOR -ge 3 ]]; then
	# bash >= 3
	BASH_ARRAY_CAPABILITIES+=' mapfile[shim] empty[shim]'
	set +u # disable nounset to prevent crashes on empty arrays
	# @todo implement support for all options
	function mapfile {
		# Copyright 2021+ Benjamin Lupton <b@lupton.cc> (https://balupton.com)
		# Written for Dorothy (https://github.com/bevry/dorothy)
		# Licensed under the CC BY-SA 4.0 (https://creativecommons.org/licenses/by-sa/4.0/)
		local delim=$'\n' item had_t='no'
		while :; do
			case "$1" in
			-t)
				had_t='yes'
				shift # trim -t
				;;
			-td)
				had_t='yes'
				shift # trim -td
				delim="$1"
				shift # trim delim
				;;
			-d)
				shift # trim -d
				delim="$1"
				shift # trim delim
				;;
			-*)
				__print_lines \
					"mapfile[shim]: $1: invalid option" \
					'mapfile[shim]: usage: mapfile -t [-d delim] <array>' >&2
				return 2 # that's what native mapfile returns
				;;
			*) break ;;
			esac
		done
		if [[ $had_t != 'yes' ]]; then
			__print_lines \
				'mapfile[shim]: -t is required in our bash v3 shim' \
				'mapfile[shim]: usage: mapfile -t [-d delim] <array>' >&2
			return 2 # that's what native mapfile returns
		fi
		if [[ -z ${1-} ]]; then
			__print_lines \
				'mapfile[shim]: <array> is required in our bash v3 shim' \
				'mapfile[shim]: usage: mapfile -t [-d delim] <array>' >&2
			return 2 # that's what native mapfile returns
		fi
		eval "$1=()"
		while IFS= read -rd "$delim" item || [[ -n $item ]]; do
			eval "$1+=($(printf '%q\n' "$item"))" || return
		done
	}
fi
BASH_ARRAY_CAPABILITIES+=' '

# note mapfile does not support multiple delimiters, as such do either of these instead:
# mapfile -t arr < <(<output-command> | echo-split --characters=' ,|' --stdin)
# mapfile -t arr < <(<output-command> | tr ' ,|' '\n')
