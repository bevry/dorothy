#!/usr/bin/env bash
# trunk-ignore-all(shellcheck/SC2140)

# For bash version compatibility and changes, see:
# See <https://github.com/bevry/dorothy/blob/master/docs/bash/versions.md> for documentation about significant changes between bash versions.
# See <https://git.savannah.gnu.org/cgit/bash.git/tree/CHANGES> <https://tiswww.case.edu/php/chet/bash/CHANGES> <https://github.com/bminor/bash/blob/master/CHANGES> for documentation on changes from bash v2 and above.

# For bash configuration options, see:
# https://www.gnu.org/software/bash/manual/bash.html#The-Set-Builtin
# https://www.gnu.org/software/bash/manual/bash.html#The-Shopt-Builtin

# Note that `&>` is available to all bash versions, however `&>>` is not, they are different.

# bash <= 3.2 is not supported by Dorothy for reasons stated in `versions.md`, however it is also too incompetent of a version to even bother checking for it

# bash v4.4
# aa. Bash now puts `s' in the value of $- if the shell is reading from standard input, as Posix requires.
# w.  `set -i' is no longer valid, as in other shells.

# =============================================================================
# Essential Toolkit

# -------------------------------------
# Print Toolkit Dependencies

# see `commands/is-brew` for details
# workaround for Dorothy's `brew` helper
function __is_brew {
	[[ -n ${HOMEBREW_PREFIX-} && -x "${HOMEBREW_PREFIX-}/bin/brew" ]] || return
}

# see `commands/command-missing` for details
# returns `0` if ANY command is missing
# returns `1` if ALL commands were present
function __command_missing {
	# trim -- prefix
	if [[ ${1-} == '--' ]]; then
		shift
	fi
	__affirm_length_defined $# 'command' || return
	# proceed
	local command
	for command in "$@"; do
		if [[ $command == 'brew' ]]; then
			# workaround for our `brew` wrapper
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

# see `commands/command-exists` for details
# returns `0` if all commands are available
# returns `1` if any command was not available
function __command_exists {
	# trim -- prefix
	if [[ ${1-} == '--' ]]; then
		shift
	fi
	__affirm_length_defined $# 'command' || return
	# proceed
	local command
	for command in "$@"; do
		if [[ $command == 'brew' ]]; then
			# workaround for Dorothy's `brew` wrapper
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

# -------------------------------------
# Print Toolkit

# They exist because `echo` has flaws, notably `v='-n'; echo "$v"` will not output `-n`.
# In UNIX there is no difference between an empty string and no input:
# empty stdin:  printf '' | wc
#               wc < <(printf '')
#    no stdin:  : | wc
#               wc < <(:)

# print each argument concatenated together with no spacing, if no arguments, do nothing
function __print_string { # b/c alias for __print_strings_or_nothing
	if [[ $# -ne 0 ]]; then
		printf '%s' "$@" || return
	fi
}
function __print_strings { # b/c alias for __print_strings_or_nothing
	if [[ $# -ne 0 ]]; then
		printf '%s' "$@" || return
	fi
}
function __print_strings_or_nothing {
	if [[ $# -ne 0 ]]; then
		printf '%s' "$@" || return
	fi
}

# print each argument on its own line, if no arguments, print a line
function __print_line {
	printf '\n' || return
}
function __print_lines_or_line {
	# equivalent to `printf '\n'` if no arguments
	printf '%s\n' "$@" || return
}

# print each argument on its own line, if no arguments, do nothing
function __print_lines { # b/c alias for __print_lines_or_nothing
	if [[ $# -ne 0 ]]; then
		printf '%s\n' "$@" || return
	fi
}
function __print_lines_or_nothing {
	if [[ $# -ne 0 ]]; then
		printf '%s\n' "$@" || return
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
		printf '%s' "${values[@]}" || return
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
		printf '%s\n' "${values[@]}" || return
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
		printf '\n' || return
	else
		printf '%s\n' "${values[@]}" || return
	fi
}

function __print_style {
	if __command_exists -- echo-style; then
		echo-style "$@" || return
	else
		# trim flag names and only output values
		local args=() trail='yes'
		while [[ $# -ne 0 ]]; do
			case "$1" in
			--no-trail | --trail=no) trail='no' ;;
			--*=*) args+=("${1#*=}") ;;
			--newline) args+=($'\n') ;;
			--*) : ;; # ignore other flags, as they empty styles
			*) args+=("$1") ;;
			esac
			shift
		done
		if [[ ${#args[@]} -eq 0 ]]; then
			return 0
		fi
		if [[ $trail == 'yes' ]]; then
			printf '%s\n' "${args[@]}" || return
		else
			printf '%s' "${args[@]}" || return
		fi
	fi
}

function __dump {
	if [[ $# -eq 0 ]]; then
		return 0
	fi
	local DUMP__reference DUMP__value DUMP__log=()
	while [[ $# -ne 0 ]]; do
		__dereference --origin="$1" --name={DUMP__reference} || return
		shift
		if __is_array "$DUMP__reference"; then
			local DUMP__index DUMP__total
			eval "DUMP__total=\${#${DUMP__reference}[@]}"
			if [[ $DUMP__total == 0 ]]; then
				DUMP__log+=(--bold="${DUMP__reference}[@]" ' = ' --dim+icon-nothing-provided='' --newline)
			else
				for ((DUMP__index = 0; DUMP__index < DUMP__total; ++DUMP__index)); do
					eval "DUMP__value=\"\${${DUMP__reference}[\$DUMP__index]}\""
					if [[ -z $DUMP__value ]]; then
						DUMP__log+=(--bold="${DUMP__reference}[${DUMP__index}]" ' = ' --dim+icon-nothing-provided='' --newline)
					else
						DUMP__log+=(--bold="${DUMP__reference}[${DUMP__index}]" ' = ' --invert="$DUMP__value" --newline)
					fi
				done
			fi
		else
			DUMP__value="${!DUMP__reference}"
			DUMP__log+=(--bold="$DUMP__reference" ' = ' --invert="$DUMP__value" --newline)
		fi
	done
	__print_style --no-trail "${DUMP__log[@]}" || return
}

# =============================================================================
# Bash Configuration & Capability Detection, Including Shims/Polyfills
# Place changelog entries in `versions.md`

# Determine the bash version information, which is used to determine if we can use certain features or not.
# BASH_VERSION_CURRENT --
# BASH_VERSION_MAJOR -- 5
# BASH_VERSION_MINOR -- 2
# BASH_VERSION_PATCH -- 15
# BASH_VERSION_LATEST -- 5.2.15
# IS_BASH_VERSION_OUTDATED -- yes/no
if [[ -z ${BASH_VERSION_CURRENT-} ]]; then
	# e.g. 5.2.15(1)-release => 5.2.15
	# https://www.gnu.org/software/bash/manual/bash.html#index-BASH_005fVERSINFO
	# `read` technique not needed as `BASH_VERSINFO` exists in all versions:
	# IFS=. read -r BASH_VERSION_MAJOR BASH_VERSION_MINOR BASH_VERSION_PATCH <<<"${BASH_VERSION%%(*}"
	BASH_VERSION_MAJOR="${BASH_VERSINFO[0]}" #
	BASH_VERSION_MINOR="${BASH_VERSINFO[1]}"
	BASH_VERSION_PATCH="${BASH_VERSINFO[2]}"
	BASH_VERSION_CURRENT="${BASH_VERSION_MAJOR}.${BASH_VERSION_MINOR}.${BASH_VERSION_PATCH}" # 5.2.15(1)-release => 5.2.15
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
			local reason="${1-}" reason_args=()
			if [[ -n $reason ]]; then
				reason_args+=(--=' due to ' --notice="$reason" --='.')
			fi
			__print_style \
				--path="$0" ' ' --error='is incompatible with' ' ' --code="bash $BASH_VERSION" "${reason_args[@]}" $'\n' \
				'Run ' --code='setup-util-bash' ' to upgrade capabilities, then run the prior command again.' >&2 || :
			return 45 # ENOTSUP 45 Operation not supported
		}
	fi
fi

# Custom debug target
# BASH_XTRACEFD aka DEBUG_OUTPUT_TARGET
export BASH_XTRACEFD
BASH_XTRACEFD="${BASH_XTRACEFD:-"${DEBUG_OUTPUT_TARGET:-"2"}"}"
function __debug_lines {
	if [[ -n ${DEBUG-} ]]; then
		if [[ -z $BASH_XTRACEFD ]]; then
			BASH_XTRACEFD="$TERMINAL_OUTPUT_TARGET"
		fi
		__print_lines "$@" >>"$BASH_XTRACEFD" || return
	fi
}

# more detailed `set -x`
DEBUG_FORMAT='+ ${BASH_SOURCE[0]-} [${LINENO}] [${FUNCNAME-}] [${BASH_SUBSHELL-}]'$'    \t'
function __enable_debugging {
	PS4="$DEBUG_FORMAT"
	DEBUG=yes
	set -x
}
function __disable_debugging {
	set +x
	DEBUG=
}

function __stack {
	local index size=${#FUNCNAME[@]}
	for ((index = 0; index < size; ++index)); do
		printf '%s\n' "${BASH_SOURCE[index]}:${BASH_LINENO[index]} ${FUNCNAME[index]}"
	done
	__dump {BASH_SOURCE} {LINENO} {FUNCNAME} {BASH_LINENO} {BASH_SUBSHELL} || return
	caller
}

# CONSIDER
# bash v5: localvar_inherit: If set, local variables inherit the value and attributes of a variable of the same name that exists at a previous scope before any new value is assigned. The nameref attribute is not inherited.
# shopt -s localvar_inherit 2>/dev/null || :
# bash v1?: localvar_unset: If set, calling unset on local variables in previous function scopes marks them so subsequent lookups find them unset until that function returns. This is identical to the behavior of unsetting local variables at the current function scope.
# shopt -s localvar_unset 2>/dev/null || :

# Disable completion (not needed in scripts)
# bash v2: progcomp: If set, the programmable completion facilities (see Programmable Completion) are enabled. This option is enabled by default.
shopt -u progcomp

# Promote the cleanup of nested commands if its login shell terminates.
# bash v2: huponexit: If set, Bash will send SIGHUP to all jobs when an interactive login shell exits (see Signals).
shopt -s huponexit

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
		__require_upgraded_bash 'missing globstar support' || return
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
		__require_upgraded_bash 'missing extglob support' || return
	}
fi

# __require_lastpipe -- if lastpipe not supported, fail.
# Enable `cmd | read -r var` usage.
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
		__require_upgraded_bash 'missing lastpipe support' || return
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

# Detect errexit
function __is_errexit {
	[[ $- == *e* ]] || return # explicit `|| return` required to prevent ERR trap from firing, which is important here as it is used within our ERR trap
}
function __is_not_errexit {
	[[ $- != *e* ]] || return # explicit `|| return` required to prevent ERR trap from firing, which is important here as it is used within our ERR trap
}

# Whether the terminal supports the [/dev/tty] device file
if (: </dev/tty >/dev/tty) &>/dev/null; then
	# This applies to:
	# - normal execution: <cmd>
	# - background execution: <cmd> &
	# - stdin execution: echo | <cmd>
	TERMINAL_OUTPUT_TARGET="${TERMINAL_OUTPUT_TARGET:-"/dev/tty"}" # allow custom value for testing
	TERMINAL_INPUT_TARGET='/dev/tty'
	TERMINAL_POSITION_INPUT_TARGET='/dev/tty'
	CAN_QUERY_TERMINAL_SIZE='yes'
	IS_STDIN_LINE_BUFFERED='no'
	IS_TTY_AVAILABLE='yes'
else
	# This applies to:
	# - ssh -T execution: ssh -T localhost <cmd>
	# - GitHub Actions execution
	TERMINAL_OUTPUT_TARGET="${TERMINAL_OUTPUT_TARGET:-"/dev/stderr"}" # allow custom value for testing
	# trunk-ignore(shellcheck/SC2034)
	TERMINAL_INPUT_TARGET='/dev/stdin'
	# trunk-ignore(shellcheck/SC2034)
	TERMINAL_POSITION_INPUT_TARGET=''
	# trunk-ignore(shellcheck/SC2034)
	CAN_QUERY_TERMINAL_SIZE='no'
	# trunk-ignore(shellcheck/SC2034)
	IS_STDIN_LINE_BUFFERED='yes' # @todo this not should not apply to CI
	# trunk-ignore(shellcheck/SC2034)
	IS_TTY_AVAILABLE='no'
fi
if [[ -t 0 ]]; then
	# This applies to:
	# - normal execution: <cmd>
	IS_STDIN_OPENED_ON_TERMINAL='yes'
	TERMINAL_THEME_INPUT_TARGET='/dev/tty' # /dev/stdin also supported, but /dev/tty is always available in this case
else
	# This applies to:
	# - stdin execution: echo | <cmd>
	# - background execution: <cmd> &
	# - ssh -T execution: ssh -T localhost <cmd>
	# - GitHub Actions execution
	IS_STDIN_OPENED_ON_TERMINAL='no'
	# trunk-ignore(shellcheck/SC2034)
	TERMINAL_THEME_INPUT_TARGET=''
fi

if [[ $BASH_VERSION_MAJOR -ge 5 ]]; then
	# Bash >= 5
	function __get_epoch_time {
		printf '%s' "$EPOCHREALTIME" || return
	}
else
	# Bash < 5
	function __get_epoch_time {
		local time size
		time="$(date +%s.%N)" || return
		if [[ $time == *000 ]]; then
			size="${#time}"
			printf '%s' "${time:0:size-3}" || return # trim last 3 digits, as they are just zeroes
		else
			printf '%s' "$time" || return
		fi
	}
fi

if [[ $BASH_VERSION_MAJOR -ge 4 ]]; then
	# bash >= 4
	# `read -i` only works if STDIN is open on terminal
	if [[ $IS_STDIN_OPENED_ON_TERMINAL == 'yes' ]]; then
		# `read -rei`  | direct                                | default shown and exit status `0` if enter pressed or `1` if nothing sent
		BASH_CAN_READ_I='yes'
	else
		# `read -rei`  | immediate pipe/redirection            | default ignored and exit status `0` if input sent or `1` if nothing sent
		# `read -rei`  | delayed pipe/redirection              | default ignored and exit status `0` if input sent or `1` if nothing sent
		# `read -rei`  | background task: all                  | input and default ignored and exit status `1`, regardless of piping and redirection
		# `read -rei`  | ssh -T: direct                        | default ignored and exit status `0` if enter pressed or `142` if timed out
		# `read -rei`  | GitHub Actions: direct                | default ignored and exit status `0` if input sent, or `1` if nothing sent
		# `read -rei`  | GitHub Actions: background task: all  | input and default ignored and exit status `1`, regardless of piping and redirections
		BASH_CAN_READ_I='no'
	fi
	BASH_CAN_READ_DECIMAL_TIMEOUT='yes'
	BASH_CAN_PIPE_STDOUT_AND_STDERR_SHORTHAND='yes'
	function __get_read_decimal_timeout {
		printf '%s' "$1" || return
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
			printf '%s' 1 || return
		else
			printf '%s' "$1" || return
		fi
	}
fi

# Bash >= 5.1, >= 4, < 4
if [[ $BASH_VERSION_MAJOR -eq 5 && $BASH_VERSION_MINOR -ge 1 ]]; then
	# bash >= 5.1
	function __get_uppercase_first_letter {
		# trim -- prefix
		if [[ ${1-} == '--' ]]; then
			shift
		fi
		# proceed
		printf '%s' "${1@u}" || return
	}
	function __get_uppercase_string {
		# trim -- prefix
		if [[ ${1-} == '--' ]]; then
			shift
		fi
		# proceed
		printf '%s' "${1@U}" || return
	}
	function __get_lowercase_string {
		# trim -- prefix
		if [[ ${1-} == '--' ]]; then
			shift
		fi
		# proceed
		printf '%s' "${1@L}" || return
	}
	# @Q is available, however it is strange, so don't shim
else
	# bash < 5.1
	# @Q is no longer available, however it is strange, so don't shim
	if [[ $BASH_VERSION_MAJOR -eq 4 ]]; then
		# bash >= 4
		function __get_uppercase_first_letter {
			# trim -- prefix
			if [[ ${1-} == '--' ]]; then
				shift
			fi
			# proceed
			printf '%s' "${1^}" || return
		}
		function __get_uppercase_string {
			# trim -- prefix
			if [[ ${1-} == '--' ]]; then
				shift
			fi
			# proceed
			printf '%s' "${1^^}" || return
		}
		function __get_lowercase_string {
			# trim -- prefix
			if [[ ${1-} == '--' ]]; then
				shift
			fi
			# proceed
			printf '%s' "${1,,}" || return
		}
	else
		# bash < 4
		function __get_uppercase_first_letter {
			# trim -- prefix
			if [[ ${1-} == '--' ]]; then
				shift
			fi
			# proceed
			local input="$1"
			local first_char="${input:0:1}" rest="${input:1}" result
			result="$(tr '[:lower:]' '[:upper:]' <<<"$first_char")" || return
			printf '%s' "$result$rest" || return
		}
		function __get_uppercase_string {
			# trim -- prefix
			if [[ ${1-} == '--' ]]; then
				shift
			fi
			# proceed
			printf '%s' "$1" | tr '[:lower:]' '[:upper:]' || return
		}
		function __get_lowercase_string {
			# trim -- prefix
			if [[ ${1-} == '--' ]]; then
				shift
			fi
			# proceed
			printf '%s' "$1" | tr '[:upper:]' '[:lower:]' || return
		}
	fi
fi

# bash >= 4.2
# p.  Negative subscripts to indexed arrays, previously errors, now are treated
#     as offsets from the maximum assigned index + 1.
# q.  Negative length specifications in the `${var:offset:length}` expansion,
#     previously errors, are now treated as offsets from the end of the variable.
# `test -v varname` is not used as it behaviour is inconsistent to expectations and across versions
function __is_var_set {
	# trim -- prefix
	if [[ ${1-} == '--' ]]; then
		shift
	fi
	__affirm_length_defined $# 'variable reference' || return
	# process
	local IS_VAR_SET__item IS_VAR_SET__reference IS_VAR_SET__fodder
	while [[ $# -ne 0 ]]; do
		IS_VAR_SET__item="$1"
		shift
		# support with and without squigglies for these references
		__dereference --origin="$IS_VAR_SET__item" --name={IS_VAR_SET__reference} || return
		# bash 3.2 and 4.0 will have `local z; declare -p z` will result in `declare -- z=""`, this is because on these bash versions, `local z` is actually `local z=` so the var is actually set
		# bash 4.2 will have `local z; declare -p z` will result in `declare: z: not found`
		# bash 4.4+ will have `local z; declare -p z` will result in `declare -- z`
		# `set -u` has no effect
		IS_VAR_SET__reference="${IS_VAR_SET__reference%%\[*}" # remove array indexes, as `declare -p` only wants the parent variable, not the index
		IS_VAR_SET__fodder="$(declare -p "$IS_VAR_SET__reference" 2>/dev/null)" || return 1
		[[ $IS_VAR_SET__fodder == *'='* ]] || return 1
	done
	return 0
}

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
# BASH_ARRAY_CAPABILITIES -- string that stores the various capabilities:
# `mapfile[native] mapfile[shim] readarray[native] empty[native] empty[shim] associative`
# note that there is no need to do `__require_array 'mapfile'` as `bash.bash` makes `mapfile` always available, it is just the native version that is not available

# has_array_capability -- check if a capability is provided by the current bash version
function __has_array_capability {
	local arg
	for arg in "$@"; do
		if [[ $BASH_ARRAY_CAPABILITIES != *" $arg"* ]]; then
			return 1
		fi
	done
}

# __require_array -- require a capability to be provided by the current bash version, otherwise fail
function __require_array {
	if ! __has_array_capability "$@"; then
		__require_upgraded_bash "missing array $* support" || return
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
	# note that these versions do not support [-d <delim>] or [-t] options with mapfile
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
		if __command_exists -- dorothy-warnings; then
			dorothy-warnings add --code='mapfile' --bold=' has been deprecated in favor of ' --code='__split' || :
		fi
		local MAPFILE__delim=$'\n' MAPFILE__t='no' MAPFILE__reference='' MAPFILE__reply
		while :; do
			case "$1" in
			-t)
				MAPFILE__t='yes'
				shift # trim -t
				;;
			-td)
				MAPFILE__t='yes'
				shift # trim -td
				MAPFILE__delim="$1"
				shift # trim delim
				;;
			-d)
				shift # trim -d
				MAPFILE__delim="$1"
				shift # trim delim
				;;
			-*)
				__print_lines \
					"mapfile[shim]: $1: invalid option" \
					'mapfile[shim]: usage: mapfile -t [-d delim] <array>' >&2 || :
				return 2 # that's what native mapfile returns
				;;
			*)
				if [[ -z $MAPFILE__reference ]]; then
					# support with and without squigglies for these references
					__dereference --origin="$1" --name={MAPFILE__reference} || return
				else
					__print_lines \
						"mapfile[shim]: unknown argument: $1" \
						'mapfile[shim]: usage: mapfile -t [-d delim] <array>' >&2 || :
					return 2 # that's what native mapfile returns
				fi
				;;
			esac
		done
		if [[ -z $MAPFILE__reference ]]; then
			__print_lines \
				'mapfile[shim]: <array> is required in our bash v3 shim' \
				'mapfile[shim]: usage: mapfile -t [-d delim] <array>' >&2 || :
			return 2 # that's what native mapfile returns
		fi
		if [[ $MAPFILE__t != 'yes' ]]; then
			__print_lines \
				'mapfile[shim]: -t is required in our bash v3 shim' \
				'mapfile[shim]: usage: mapfile -t [-d delim] <array>' >&2 || :
			return 2 # that's what native mapfile returns
		fi
		shift
		eval "$MAPFILE__reference=()" || return
		while IFS= read -rd "$MAPFILE__delim" MAPFILE__reply || [[ -n $MAPFILE__reply ]]; do
			eval "${MAPFILE__reference}+=(\"\${MAPFILE__reply}\")" || return
		done
	}
fi
BASH_ARRAY_CAPABILITIES+=' '

# =============================================================================
# Bash Essential Toolkit

# -------------------------------------
# Errors Toolkit

function __unrecognised_flag {
	__print_lines "ERROR: ${FUNCNAME[1]}: An unrecognised flag was provided: $1" >&2 || :
	return 22 # EINVAL 22 Invalid argument
}

function __unrecognised_argument {
	__print_lines "ERROR: ${FUNCNAME[1]}: An unrecognised argument was provided: $1" >&2 || :
	return 22 # EINVAL 22 Invalid argument
}

# affirm the mode value is a valid mode
# __affirm_value_is_valid_write_mode <mode-value>
function __affirm_value_is_valid_write_mode {
	case "$1" in
	'' | prepend | append | overwrite) return 0 ;; # valid modes
	*)
		__print_lines "ERROR: \${FUNCNAME[1]}: An invalid mode was provided: \$$1" >&2 || :
		return 22 # EINVAL 22 Invalid argument
		;;
	esac
}

# affirm the value is defined
# __affirm_value_is_defined <value> <description>
function __affirm_value_is_defined {
	if [[ -z $1 ]]; then
		__print_lines "ERROR: ${FUNCNAME[1]}: A ${2:-"value"} must be provided." >&2 || :
		__stack >&2 || :
		return 22 # EINVAL 22 Invalid argument
	fi
}

# affirm the value is undefined
# __affirm_value_is_undefined <value> <description>
function __affirm_value_is_undefined {
	if [[ -n $1 ]]; then
		__print_lines "ERROR: ${FUNCNAME[1]}: A ${2:-"value"} was already defined [$1]." >&2 || :
		return 22 # EINVAL 22 Invalid argument
	fi
}

# affirm the value is an integer
# __affirm_value_is_integer <value> <description>
function __affirm_value_is_integer {
	if ! __is_integer "$1"; then
		__print_lines "ERROR: ${FUNCNAME[1]}: The ${2:-"value"} [$1] must be an integer." >&2 || :
		return 22 # EINVAL 22 Invalid argument
	fi
}

# affirm the value is a positive integer
# __affirm_value_is_positive_integer <value> <description>
function __affirm_value_is_positive_integer {
	if ! __is_positive_integer "$1"; then
		__print_lines "ERROR: ${FUNCNAME[1]}: The ${2:-"value"} [$1] must be a positive integer." >&2 || :
		return 22 # EINVAL 22 Invalid argument
	fi
}

# affirm value is greater than one
# __affirm_length_defined <value> <description>
function __affirm_length_defined {
	if [[ $1 -eq 0 ]]; then # ignore positive integer check, as that is too strict for this
		__print_lines "ERROR: ${FUNCNAME[1]}: At least one ${2:-"value"} must be provided." >&2 || :
		return 22 # EINVAL 22 Invalid argument
	fi
}

# affirm variable is an array
# __affirm_variable_is_array <variable-name> <description>
function __affirm_variable_is_array {
	if ! __is_array "$1"; then # ignore positive integer check, as that is too strict for this
		__print_lines "ERROR: ${FUNCNAME[1]}: The ${2:-"variable"} $1 must be an array." >&2 || :
		return 22 # EINVAL 22 Invalid argument
	fi
}

# affirm the array is defined
# __affirm_array_is_defined <array> <description>
# function __affirm_array_is_defined {
# 	local AFFIRM_ARRAY_IS_DEFINED__item="$1" AFFIRM_ARRAY_IS_DEFINED__reference
# 	__dereference --origin="$AFFIRM_ARRAY_IS_DEFINED__item" --name={AFFIRM_ARRAY_IS_DEFINED__reference} || return
# 	if ! __is_array "$AFFIRM_ARRAY_IS_DEFINED__reference" || eval "[[ \${#${AFFIRM_ARRAY_IS_DEFINED__reference}[@]} -eq 0 ]]"; then
# 		__print_lines "ERROR: ${FUNCNAME[1]}: At least one ${2:-"value"} must be provided." >&2 || :
# 		return 22 # EINVAL 22 Invalid argument
# 	fi
# }

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

	# __return $? -- command ...
	local RETURN__item RETURN__status=0 RETURN__invoke_only_on_failure=no RETURN__invoke_command=()
	while [[ $# -ne 0 ]]; do
		RETURN__item="$1"
		shift
		case "$RETURN__item" in
		--invoke-only-on-failure) RETURN__invoke_only_on_failure=yes ;;
		--)
			RETURN__invoke_command+=("$@")
			shift $#
			break
			;;
		[0-9]*)
			__affirm_value_is_positive_integer "$RETURN__item" 'exit status' || return
			# it is an exit status, update our result exit status if it is still non-zero
			if [[ $RETURN__status -eq 0 ]]; then
				RETURN__status="$RETURN__item"
			fi
			;;
		--*) __unrecognised_flag "$RETURN__item" || return ;;
		*) __unrecognised_argument "$RETURN__item" || return ;;
		esac
	done

	# sanity
	if [[ ${#RETURN__invoke_command[@]} -eq 0 ]]; then
		return "$RETURN__status"
	fi

	# invoke
	if [[ $RETURN__status -eq 0 ]]; then
		# the caller didn't fail
		if [[ $RETURN__invoke_only_on_failure == 'no' ]]; then
			# invoke returning the invocation's exit status
			"${RETURN__invoke_command[@]}" # eval
			return
		fi
		return 0
	else
		# the caller failed, so run the eval, but use the caller's failure status
		# note that this is generally run within a conditional, so errexit is probably disabled
		# so we probably do not need || return and || :
		# @todo at some point validate that the invoke command is either a command or a safety function, then we can enforce `|| :` and `|| return` usage, see `dorothy-internals` for some commented out helper functions
		"${RETURN__invoke_command[@]}" # eval
		return "$RETURN__status"
	fi
}

# ignore an exit status
function __ignore_exit_status {
	local actual_status="$?" ignore_status
	for ignore_status in "$@"; do
		if [[ $actual_status -eq $ignore_status ]]; then
			return 0
		fi
	done
	return "$actual_status"
}

# ignore a sigpipe exit status
# this enables the following:
# { curl --silent --show-error 'https://www.google.com' | : || __ignore_exit_status 56; } | { { cat; yes; } | head -n 1 || __ignore_sigpipe; } | cat
# note that the curl pipefail 56 occurs because we pipe `curl` to `:`, similar to how we cause another pipefail later by piping `yes` to `head -n 1`, this is a contrived example to demonstrate the point
function __ignore_sigpipe {
	__ignore_exit_status 141 || return
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

# -------------------------------------
# Variable & Value Toolkit

# as __dereference calls __is_array, we cannot call __dereference from __is_array
# NOTE:
# if you do `local arr=(); a='string'` then `declare -p arr` will report `arr` as an array with a single element
# to avoid that, you must do `local arr; a='string'` as such, never mangling types; or use separate variables (safe and explicit)
function __is_array {
	local IS_ARRAY__item IS_ARRAY__size IS_ARRAY__reference='' IS_ARRAY__fodder
	__affirm_length_defined $# 'variable reference' || return
	while [[ $# -ne 0 ]]; do
		IS_ARRAY__item="$1"
		shift
		case "$IS_ARRAY__item" in
		{*})
			# trim starting and trailing squigglies
			IS_ARRAY__size="${#IS_ARRAY__item}"
			IS_ARRAY__reference="${IS_ARRAY__item:1:IS_ARRAY__size-2}"
			;;
		*) IS_ARRAY__reference="$IS_ARRAY__item" ;;
		esac
		# verify the reference
		if [[ -z $IS_ARRAY__reference || $IS_ARRAY__reference == IS_ARRAY__* ]]; then
			__print_lines "ERROR: ${FUNCNAME[0]}: The variable reference [$IS_ARRAY__reference] is invalid." >&2 || :
			return 22 # EINVAL 22 Invalid argument
		fi
		# verify the variable is an array
		IS_ARRAY__fodder="$(declare -p "$IS_ARRAY__reference" 2>/dev/null)" || return 1
		[[ $IS_ARRAY__fodder == 'declare -a '* ]] || return 1
	done
}

function __is_positive_integer {
	__affirm_length_defined $# 'input' || return
	while [[ $# -ne 0 ]]; do
		[[ $1 =~ ^[0-9]+$ ]] || return
		shift
	done
}

# or you if you already know it is an integer, you can just do: [[ $1 -lt 0 ]]
function __is_negative_integer {
	__affirm_length_defined $# 'input' || return
	while [[ $# -ne 0 ]]; do
		[[ $1 =~ ^-[0-9]+$ ]] || return
		shift
	done
}

function __is_integer {
	__affirm_length_defined $# 'input' || return
	while [[ $# -ne 0 ]]; do
		[[ $1 =~ ^[-]?[0-9]+$ ]] || return
		shift
	done
}

function __is_digit {
	__affirm_length_defined $# 'input' || return
	while [[ $# -ne 0 ]]; do
		[[ $1 =~ ^[0-9]$ ]] || return
		shift
	done
}

function __is_even {
	__affirm_length_defined $# 'input' || return
	local input
	while [[ $# -ne 0 ]]; do
		input="$1"
		shift
		[[ $((input % 2)) -eq 0 ]] || return
	done
}

function __is_odd {
	__affirm_length_defined $# 'input' || return
	local input
	while [[ $# -ne 0 ]]; do
		input="$1"
		shift
		[[ $((input % 2)) -ne 0 ]] || return
	done
}

function __is_zero {
	__affirm_length_defined $# 'input' || return
	while [[ $# -ne 0 ]]; do
		[[ $1 -eq 0 ]] || return
		shift
	done
}

# -------------------------------------
# Reference Toolkit

# check if the value is a reference, i.e. starts with `{` and ends with `}`, e.g. `{var_name}`.
function __is_reference {
	__affirm_length_defined $# 'input' || return
	while [[ $# -ne 0 ]]; do
		[[ $1 == '{'*'}' && $1 != '{}' ]] || return
		shift
	done
}

# with the reference, trim its squigglies to get its variable name, and apply it to the variable name reference, and affirm there won't be a conflict
# e.g. `my_result=hello; MY_CONTEXT__item={my_result}; __dereference --origin="$MY_CONTEXT__item" --name={MY_CONTEXT__reference}; MY_CONTEXT__reference=my_result`
# e.g. `my_result=hello; MY_CONTEXT__item='{my_result}'; __dereference --origin="$MY_CONTEXT__item"--value={MY_CONTEXT__value}; MY_CONTEXT__value=hello`
function __dereference {
	local DEREFERENCE__item DEREFERENCE__origin_reference='' DEREFERENCE__name_reference='' DEREFERENCE__value_reference='' DEREFERENCE__size DEREFERENCE__origin_prefix='' DEREFERENCE__internal_prefix=''
	while [[ $# -ne 0 ]]; do
		DEREFERENCE__item="$1"
		shift
		case "$DEREFERENCE__item" in
		--origin={*})
			DEREFERENCE__item="${DEREFERENCE__item#*=}"
			DEREFERENCE__size="${#DEREFERENCE__item}"
			DEREFERENCE__origin_reference="${DEREFERENCE__item:1:DEREFERENCE__size-2}" # trim starting and trailing squigglies
			DEREFERENCE__origin_prefix="${DEREFERENCE__origin_reference%%__*}__"
			;;
		--origin=*)
			DEREFERENCE__origin_reference="${DEREFERENCE__item#*=}"
			DEREFERENCE__origin_prefix="${DEREFERENCE__origin_reference%%__*}__"
			;;
		--name={*})
			DEREFERENCE__item="${DEREFERENCE__item#*=}"
			DEREFERENCE__size="${#DEREFERENCE__item}"
			DEREFERENCE__name_reference="${DEREFERENCE__item:1:DEREFERENCE__size-2}" # trim starting and trailing squigglies
			DEREFERENCE__internal_prefix="${DEREFERENCE__name_reference%%__*}__"
			;;
		--value={*})
			DEREFERENCE__item="${DEREFERENCE__item#*=}"
			DEREFERENCE__size="${#DEREFERENCE__item}"
			DEREFERENCE__value_reference="${DEREFERENCE__item:1:DEREFERENCE__size-2}" # trim starting and trailing squigglies
			DEREFERENCE__internal_prefix="${DEREFERENCE__value_reference%%__*}__"
			;;
		--*) __unrecognised_flag "$DEREFERENCE__item" || return ;;
		*) __unrecognised_argument "$DEREFERENCE__item" || return ;;
		esac
	done
	if [[ -z $DEREFERENCE__origin_reference ]]; then
		__print_lines "ERROR: ${FUNCNAME[0]}: The origin reference is required." >&2 || :
		return 22 # EINVAL 22 Invalid argument
	fi
	# validate that the reference does not use our variable name prefix
	if [[ -n $DEREFERENCE__origin_prefix && -n $DEREFERENCE__internal_prefix && $DEREFERENCE__origin_prefix == "$DEREFERENCE__internal_prefix" ]]; then
		__print_lines "ERROR: ${FUNCNAME[0]}: To avoid conflicts, the origin reference [$DEREFERENCE__origin_reference] must not use the prefix [$DEREFERENCE__internal_prefix]." >&2 || :
		return 22 # EINVAL 22 Invalid argument
	fi
	if [[ -n $DEREFERENCE__name_reference ]]; then
		if __is_array "$DEREFERENCE__name_reference"; then
			# append is intentional, see __to usage
			eval "$DEREFERENCE__name_reference+=(\"\$DEREFERENCE__origin_reference\")" || return
		else
			eval "$DEREFERENCE__name_reference=\"\$DEREFERENCE__origin_reference\"" || return
		fi
	fi
	if [[ -n $DEREFERENCE__value_reference ]]; then
		if __is_array "$DEREFERENCE__origin_reference"; then
			# dereference an array, so we need to use the array variable name
			# append is intentional, see __to usage
			eval "$DEREFERENCE__value_reference+=(\"\${${DEREFERENCE__origin_reference}[@]}\")" || return
		else
			# dereference a variable, so we can just use the variable name
			eval "$DEREFERENCE__value_reference=\"\$${DEREFERENCE__origin_reference}\"" || return
		fi
	fi
	return 0
}

# -------------------------------------
# Function Toolkit

function __is_subshell_function {
	# don't assign $1 to a variable, as then that means the variable name could conflict with the evaluation from the declare
	# test "$(declare -f "$1")" == "$1"$' () \n{ \n    ('
	[[ "$(declare -f "$1")" == "$1"$' () \n{ \n    ('* ]] || return # explicit `|| return` required to prevent ERR trap from firing, which is important here as it is used within our ERR trap
}

function __get_function_inner {
	local GET_FUNCTION_INNER__function_code GET_FUNCTION_INNER__left=$'{ \n' GET_FUNCTION_INNER__right=$'\n}'
	GET_FUNCTION_INNER__function_code="$(declare -f "$1")" || return
	# remove header and footer of function
	# this only works bash 5.2 and above:
	# code="${code#*$'\n{ \n'}"
	# code="${code%$'\n}'*}"
	# this works, but reveals the issue with the above is the escaping:
	# code="${code#*"$osb $newline"}"
	# code="${code%"$newline$csb"*}"
	# as such, use this wrapper, which is is clear to our intent, do not use any other helper functions though, as this is executed in our complex __try flow
	GET_FUNCTION_INNER__function_code="${GET_FUNCTION_INNER__function_code#*"$GET_FUNCTION_INNER__left"}"
	GET_FUNCTION_INNER__function_code="${GET_FUNCTION_INNER__function_code%"$GET_FUNCTION_INNER__right"*}"
	printf '%s' "$GET_FUNCTION_INNER__function_code" || return
}

function __get_index_of_parent_function {
	# if it is only this helper function then skip
	if [[ ${#FUNCNAME[@]} -le 1 ]]; then
		return 1
	fi
	local until fns=() index
	# skip __has_subshell_function_until which will be index [0]
	fns=("${FUNCNAME[@]:1}")

	# find a match
	for index in "${!fns[@]}"; do
		for until in "$@"; do
			if [[ ${fns[$index]} == "$until" ]]; then
				printf '%s' "$index" || return
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
		printf '%s' "$fn" || return
		return 0
	done
	return 1
}

# =============================================================================
# Redirection & Error Handling Toolkit

# send the source to the targets, respecting the mode
function __to {
	local TO__item TO__source='' TO__targets=() TO__mode=''
	while [[ $# -ne 0 ]]; do
		TO__item="$1"
		shift
		case "$TO__item" in
		--source={*})
			__affirm_value_is_undefined "$TO__source" 'source reference' || return
			__dereference --origin="${TO__item#*=}" --name={TO__source} || return
			;;
		--targets=*) __dereference --origin="${TO__item#*=}" --value={TO__targets} || return ;;
		--target=*) TO__targets+=("${TO__item#*=}") ;;
		--mode=prepend | --mode=append | --mode=overwrite | --mode=)
			__affirm_value_is_undefined "$TO__mode" 'write mode' || return
			TO__mode="${TO__item#*=}"
			;;
		--append | --prepend | --overwrite)
			__affirm_value_is_undefined "$TO__mode" 'write mode' || return
			TO__mode="${TO__item:2}"
			;;
		--*) __unrecognised_flag "$TO__item" || return ;;
		*) __unrecognised_argument "$TO__item" || return ;;
		esac
	done
	__affirm_value_is_defined "$TO__source" 'source reference' || return
	__affirm_value_is_valid_write_mode "$TO__mode" || return
	if [[ ${#TO__targets[@]} -eq 0 ]]; then
		TO__targets+=('STDOUT') # default to STDOUT
	fi
	local TO__target TO__source_size
	for TO__target in "${TO__targets[@]}"; do
		__affirm_value_is_defined "$TO__target" 'target' || return
		if __is_reference "$TO__target"; then
			__dereference --origin="$TO__target" --name={TO__target} || return
			if __is_array "$TO__source"; then
				# `__at` and `__index` provide a source array, and the destination decides if it wants an array or string
				# and bash v3 does not simply declare empty variables, but defines them as strings, so we need to handle that
				# such as: `local destination; __at --source={option_paths} --target={destination} -- -1`
				# ^ we obviously want a string, bash v3 will give us a string, and bash v4+ will give us a single length array that works as a string, as: `a('a value'); echo "${a}"; echo "${#a}";` is as expected
				# such as: `local parts; __split --source={path} --target={parts} --delimiter='/' --no-zero-length`
				# ^ bash v4+ will make `parts` an array as it is declared, but not defined; however because bash v3 not just declares it but defines it as an empty string, will be notified of this mishap and need to do `parts=()`
				# as such, any joining by __to is off limits
				# such as: `local arr; arr+=('value'); __dump arr`
				# ^ bash v4+ will make `arr` an array with a single `'value'` element, however bash v3 because `arr` was not just declared but also defined as an empty string, will make `arr` have two elements in which the first is an empty string and the second is `'value'`, so when we are using arrays, we need to always not just declare them but define them as arrays to avoid bash v3 mishaps
				if __is_array "$TO__target" || ! __is_var_set "$TO__target"; then
					# array to array
					case "$TO__mode" in
					prepend) eval "$TO__target=(\"\${${TO__source}[@]}\" \"\${${TO__target}[@]}\")" || return ;;
					append) eval "$TO__target+=(\"\${${TO__source}[@]}\")" || return ;;
					'' | overwrite) eval "$TO__target=(\"\${${TO__source}[@]}\")" || return ;;
					# mode is already validated
					esac
				else
					eval "TO__source_size=\"\${#${TO__source}[@]}\"" || return
					if [[ $TO__source_size -eq 1 ]]; then
						# array of single element to string
						case "$TO__mode" in
						prepend) eval "$TO__target=\"\${${TO__source}[0]}\${${TO__target}}\"" || return ;;
						append) eval "$TO__target+=\"\${${TO__source}[0]}\")" || return ;;
						'' | overwrite) eval "$TO__target=\"\${${TO__source}[0]}\"" || return ;;
						# mode is already validated
						esac
					elif [[ $TO__source_size -gt 1 ]]; then
						__print_lines "ERROR: ${FUNCNAME[0]}: If the source [$TO__source] is an array, then the target [$TO__target] must be as well. Use an intermediate variable and send to [__join] if needed." >&2 || :
						__dump "$TO__source" "$TO__target" >&2 || :
						return 22 # EINVAL 22 Invalid argument
						# don't do this the below commented out code, as it is ambiguous to what should happen when destination a variable, stream, or file:
						# case "$TO__mode" in
						# prepend) IFS= eval "$TO__target=\"\${${TO__source}[*]}\${${TO__target}}\"" || return ;;
						# append) IFS= eval "$TO__target+=\"\${${TO__source}[*]}\")" || return ;;
						# '' | overwrite) IFS= eval "$TO__target=\"\${${TO__source}[*]}\"" || return ;;
						# # mode is already validated
						# esac
					fi
				fi
			else
				# string to array
				if __is_array "$TO__target"; then
					case "$TO__mode" in
					prepend) eval "$TO__target=(\"\${${TO__source}}\" \"\${${TO__target}[@]}\")" || return ;;
					append) eval "$TO__target+=(\"\${${TO__source}}\")" || return ;;
					'' | overwrite) eval "$TO__target=(\"\${${TO__source}}\")" || return ;;
					# mode is already validated
					esac
				else
					# string to string
					case "$TO__mode" in
					prepend) eval "$TO__target=\"\${${TO__source}}\${${TO__target}}\"" || return ;;
					append) eval "$TO__target+=\"\$${TO__source}\"" || return ;;
					'' | overwrite) eval "$TO__target=\"\${${TO__source}}\"" || return ;;
					# mode is already validated
					esac
				fi
			fi
		else
			function __affirm_empty_mode {
				if [[ -n $TO__mode ]]; then
					__print_lines "ERROR: ${FUNCNAME[0]}: The target [$TO__target] is not a variable reference, so it cannot be used with the mode [$TO__mode]." >&2 || :
					return 22 # EINVAL 22 Invalid argument
				fi
			}
			local TO__value=''
			if __is_array "$TO__source"; then
				eval "TO__source_size=\"\${#${TO__source}[@]}\"" || return
				if [[ $TO__source_size -eq 1 ]]; then
					# array of single element to string
					eval "TO__value=\"\${${TO__source}[0]}\"" || return
				elif [[ $TO__source_size -gt 1 ]]; then
					__print_lines "ERROR: ${FUNCNAME[0]}: If the source [$TO__source] is an array, then the target [$TO__target] must be as well. Use an intermediate variable and send to [__join] if needed." >&2 || :
					__dump "$TO__source" "$TO__target" >&2 || :
					return 22 # EINVAL 22 Invalid argument
				fi
				# don't do this the below commented out code, as it is ambiguous to what should happen when destination a variable, stream, or file:
				# eval "
				# local -i TO__index TO__size
				# for (( TO__index = 0, TO__size = \${#${TO__source}[@]}; TO__index < TO__size; TO__index++ )); do
				# 	TO__value+=\"\${${TO__source}[TO__index]}\"\$'\n'
				# done" || return
			else
				eval "TO__value=\"\$${TO__source}\"" || return
			fi
			function __to_target {
				case "$TO__target" in
				# stdout
				1 | STDOUT | stdout | /dev/stdout)
					__affirm_empty_mode
					printf '%s' "$TO__value" || return
					;;
				# stderr
				2 | STDERR | stderr | /dev/stderr)
					__affirm_empty_mode
					printf '%s' "$TO__value" >&2 || return
					;;
				# tty
				TTY | tty | /dev/tty)
					__affirm_empty_mode
					if ! __is_tty_special_file "$TERMINAL_OUTPUT_TARGET"; then
						TO__target="$TERMINAL_OUTPUT_TARGET"
						__to_target || return
					else
						printf '%s' "$TO__value" >>/dev/tty || return
					fi
					;;
				# null
				NULL | null | /dev/null) ;; # do nothing
				# file descriptor
				[0-9]*)
					__affirm_value_is_positive_integer "$TO__target" 'file descriptor' || return
					__affirm_empty_mode
					printf '%s' "$TO__value" >&"$TO__target" || return
					;;
				# file target
				*)
					case "$TO__mode" in
					prepend)
						TO__value="$(<"$TO__target")$TO__value"
						printf '%s' "$TO__value" >"$TO__target" || return
						;;
					append)
						printf '%s' "$TO__value" >>"$TO__target" || return
						;;
					'' | overwrite)
						printf '%s' "$TO__value" >"$TO__target" || return
						;;
					esac
					;;
				esac
			}
			__to_target || return
		fi
	done
}

# normally, with > it is right to left, however that makes sense as > portions of our statement are on the right-side
# however, __do is on the left side, so it should be left to right, such that this intuitively makes sense:
# __do --copy-stderr=stderr.txt --copy-stdout=stdout.txt --redirect-stderr=STDOUT --copy-stdout=output.txt --redirect-stdout=NULL -- echo-style --stderr=my-stderr --stdout=my-stdout
# as this makes no sense in this context:
# __do --redirect-stdout=NULL --copy-stdout=output.txt --redirect-stderr=STDOUT --copy-stdout=stdout.txt --copy-stderr=stderr.txt -- echo-style --stderr=my-stderr --stdout=my-stdout
#
# @todo re-add samasama support for possible performance improvement: https://gist.github.com/balupton/32bfc21702e83ad4afdc68929af41c23
# @todo consider using `FD>&-` instead of `FD>/dev/null`
function __do {
	# 🧙🏻‍♀️ the power is yours, send donations to github.com/sponsors/balupton
	__affirm_length_defined $# 'argument' || return
	# externally, we support left to right, however internally, it is implemented right to left, so perform the conversion
	if [[ $1 != '--right-to-left' ]]; then
		local DO__inversion=("$1")
		shift
		while [[ $# -ne 0 && $1 != '--' ]]; do
			DO__inversion=("$1" "${DO__inversion[@]}")
			shift
		done
		__do --right-to-left "${DO__inversion[@]}" "$@"
		return
	fi
	shift # trim --right-to-left
	# explicit return handling is to have this work in conditional mode
	local DO__arg="$1" DO__arg_value DO__arg_flag
	# process
	DO__arg_value="${DO__arg#*=}"
	DO__arg_flag="${DO__arg%%=*}" # [--stdout=], [--stderr=], [--output=] to [--stdout], [--stderr], [--output]
	shift
	# if target is tty, but terminal device file is redirected, then redo the flag with the redirection value
	if __is_tty_special_file "$DO__arg_value" && ! __is_tty_special_file "$TERMINAL_OUTPUT_TARGET"; then
		__do --right-to-left "$DO__arg_flag=$TERMINAL_OUTPUT_TARGET" "$@"
		return
	fi
	# process
	case "$DO__arg" in
	--)
		"$@"
		return
		;; # done

	# stdout+stderr alias
	'--redirect-stdout+stderr='*)
		__print_lines "ERROR: ${FUNCNAME[0]}: A to be implemented flag was provided: $DO__arg. You probably want [--redirect-stdout=$DO__arg_value --redirect-stderr=$DO__arg_value] or [--redirect-output=$DO__arg_value] instead. If you are doing a process substitution, you want the former suggestion and have the stderr process substitution output to >&2." >&2 || :
		return 78 # NOSYS 78 Function not implemented
		;;
	'--copy-stdout+stderr='*)
		__print_lines "ERROR: ${FUNCNAME[0]}: A to be implemented flag was provided: $DO__arg" >&2 || :
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
		local DO__reference DO__status
		__dereference --origin="$DO__arg_value" --name={DO__reference} || return

		# catch the status
		__try {DO__status} -- __do --right-to-left "$@"
		__return $? || return

		# apply the status to the var target
		eval "$DO__reference=\$DO__status" || return

		# return or discard the status
		case "$DO__arg_flag" in
		--redirect-*) return 0 ;;
		--copy-*) return "$DO__status" ;;
		*)
			__print_lines "ERROR: ${FUNCNAME[0]}: An unrecognised target was encountered: $DO__arg" >&2 || :
			return 76 # EPROCUNAVAIL 76 Bad procedure for program
			;;
		esac
		;;

	# redirect or copy, status, to a non-var target
	--redirect-status=* | --copy-status=*)
		# catch the status
		local DO__status
		__try {DO__status} -- __do --right-to-left "$@"
		__return $? || return

		# apply the status to the non-var target
		__do --redirect-stdout="$DO__arg_value" -- __print_lines "$DO__status" || return

		# return or discard the status
		case "$DO__arg_flag" in
		--redirect-*) return 0 ;;
		--copy-*) return "$DO__status" ;;
		*)
			__print_lines "ERROR: ${FUNCNAME[0]}: An unrecognised target was encountered: $DO__arg" >&2 || :
			return 76 # EPROCUNAVAIL 76 Bad procedure for program
			;;
		esac
		;;

	# redirect or copy, device files, to a var target
	--redirect-stdout={*} | --redirect-stderr={*} | --redirect-output={*} | --copy-stdout={*} | --copy-stderr={*} | --copy-output={*})
		local DO__reference DO__semaphore DO__result_value
		__dereference --origin="$DO__arg_value" --name={DO__reference} || return

		# reset to prevent inheriting prior values of the same name if this one has a failure status which prevents updating the values
		eval "$DO__reference=" || return

		# execute and write to a file
		# @todo consider a way to set the vars with what was written even if this fails, may not be a good idea
		DO__semaphore="$(__get_semaphore "__do.data-to-reference.$RANDOM$RANDOM")" || return
		__do --right-to-left "$DO__arg_flag=$DO__semaphore" "$@"
		__return $? --invoke-only-on-failure -- rm -f -- "$DO__semaphore" || return

		# load the value of the file, remove the file, apply the value to the var target
		# trunk-ignore(shellcheck/SC2034)
		DO__result_value="$(<"$DO__semaphore")" || return
		eval "$DO__reference=\$DO__result_value" || return
		rm -f -- "$DO__semaphore" || return
		return
		;;

	# this may seem like a good idea, but it isn't, the reason why is that pipelines are forks, and as such the hierarchy gets disconnected, with the updates of inner dos not having their updates seen by outer dos
	# # redirect, device files, to pipeline
	# '--redirect-stdout=|'* | '--redirect-stderr=|'* | '--redirect-output=|'*)
	# 	# trim starting |, converting |<code> to <code>
	# 	local DO__code
	# 	__slice --source={DO__arg_value} --target={DO__code} 1 || return

	# 	# run our pipes
	# 	case "$DO__arg_flag" in
	# 	--redirect-stdout)
	# 		__do --right-to-left "$@" | eval "$DO__code"
	# 		return
	# 		;;
	# 	--redirect-stderr)
	# 		# there is no |2 in bash
	# 		__print_lines "ERROR: ${FUNCNAME[0]}: An unrecognised target was encountered: $DO__arg" >&2
	# 		return 76 # EPROCUNAVAIL 76 Bad procedure for program
	# 		;;
	# 	--redirect-output)
	# 		__do --right-to-left "$@" 2>&1 | eval "$DO__code"
	# 		return
	# 		;;
	# 	*)
	# 		__print_lines "ERROR: ${FUNCNAME[0]}: An unrecognised target was encountered: $DO__arg" >&2
	# 		return 76 # EPROCUNAVAIL 76 Bad procedure for program
	# 		;;
	# 	esac
	# 	;;

	# redirect, device files, to process substitution
	--redirect-stdout=\(*\) | --redirect-stderr=\(*\) | --redirect-output=\(*\))
		local DO__code DO__semaphore DO__size

		# trim starting and trailing parentheses, converting (<code>) to <code>
		DO__size="${#DO__arg_value}"
		DO__code="${DO__arg_value:1:DO__size-2}"

		# executing this in errexit mode:
		# __do --stderr='(cat; __return 10; __return 20)' -- echo-style --stderr=stderr-result --stdout=stdout-result; echo "status=[${statusvar-}] stdout=[${stdoutvar-}] stderr=[${stderrvar-}]"
		#
		# with this internal code, will not fail, as the return statuses of the subshell redirections are ignored:
		# --stderr) __do --right-to-left "$@" 2> >(eval "$DO__code"; __return $? -- touch "$DO__semaphore") ;;
		#
		# with this internal code, will fail with 20:
		# --stderr) __do --right-to-left "$@" 2> >(set +e; eval "$DO__code"; printf '%s' "$?" >"$DO__semaphore") ;;
		#
		# with this internal code, will fail with 10, which is what we want
		# --stderr) __do --right-to-left "$@" 2> >(__do --status="$DO__semaphore" -- eval "$DO__code") ;;

		# prepare our semaphore file that will track the exit status of the process substitution
		DO__semaphore="$(__get_semaphore "__do.process.$RANDOM$RANDOM")" || return

		# execute while tracking the exit status to our semaphore file
		# can't use `__try` as >() is a subshell, so the status variable application won't escape the subshell
		# note [>(...)] and [> >(...)] are different, the former interpolates as a file descriptor, the latter forwards stdout to the file descriptor
		case "$DO__arg_flag" in
		--redirect-stdout) __do --right-to-left "$@" > >(__do --redirect-status="$DO__semaphore" -- eval "$DO__code") ;;
		--redirect-stderr) __do --right-to-left "$@" 2> >(__do --redirect-status="$DO__semaphore" -- eval "$DO__code") ;;
		--redirect-output) __do --right-to-left "$@" &> >(__do --redirect-status="$DO__semaphore" -- eval "$DO__code") ;;
		*)
			__print_lines "ERROR: ${FUNCNAME[0]}: An unrecognised target was encountered: $DO__arg" >&2 || :
			return 76 # EPROCUNAVAIL 76 Bad procedure for program
			;;
		esac

		# once completed, wait for and return the status of our process substitution
		__return $? -- __wait_for_and_return_semaphores "$DO__semaphore" || return
		return
		;;

	# note that copying to a process substitution is not yet supported
	# @todo implement this
	--copy-stdout=\(*\) | --copy-stderr=\(*\) | --copy-output=\(*\))
		__print_lines "ERROR: ${FUNCNAME[0]}: A to be implemented flag was provided: $DO__arg" >&2 || :
		return 78 # NOSYS 78 Function not implemented
		;;

	# redirect, stdout, to various targets
	--redirect-stdout=*)
		case "$DO__arg_value" in

		# redirect stdout to stdout, this is a no-op, continue to next
		1 | STDOUT | stdout | /dev/stdout)
			__do --right-to-left "$@"
			return
			;;

		# redirect stdout to stderr
		2 | STDERR | stderr | /dev/stderr)
			__do --right-to-left "$@" >&2
			return
			;;

		# redirect stdout to tty
		TTY | tty | /dev/tty)
			__do --right-to-left "$@" >>/dev/tty
			return
			;;

		# redirect stdout to null
		NULL | null | /dev/null)
			__do --right-to-left "$@" >/dev/null
			return
			;;

		# redirect stdout to FD target
		[0-9]*)
			__affirm_value_is_positive_integer "$DO__arg_value" 'file descriptor' || return
			__do --right-to-left "$@" >&"$DO__arg_value"
			return
			;;

		# no-op
		'')
			__do --right-to-left "$@"
			return
			;;

		# redirect stdout to file target
		*)
			__do --right-to-left "$@" >>"$DO__arg_value"
			return
			;;

		# done with stdout redirect
		esac
		;;

	# copy, stdout, to various targets
	--copy-stdout=*)
		case "$DO__arg_value" in

		# copy stdout to stdout
		1 | STDOUT | stdout | /dev/stdout)
			# no-op
			__do --right-to-left "$@"
			return
			;;

		# copy stdout to stderr
		2 | STDERR | stderr | /dev/stderr)
			# prepare our semaphore files that will track the exit status of the process substitution
			local DO__semaphores DO__context="__do.copy-stdout-to-stderr.$RANDOM$RANDOM"
			__semaphores --target={DO__semaphores} -- "$DO__context.1" "$DO__context.2" || return

			# execute, keeping stdout, copying to stderr, and tracking the exit status to our semaphore file
			__do --right-to-left "$@" > >(
				set +e
				tee -- >(
					set +e
					cat >&2
					printf '%s' "$?" >"${DO__semaphores[0]}"
				)
				printf '%s' "$?" >"${DO__semaphores[1]}"
			)

			# once completed, wait for and return the status of our process substitution
			__return $? -- __wait_for_and_return_semaphores "${DO__semaphores[@]}" || return
			return
			;;

		# copy stdout to tty
		TTY | tty | /dev/tty)
			# prepare our semaphore files that will track the exit status of the process substitution
			local DO__semaphores DO__context="__do.copy-stdout-to-tty.$RANDOM$RANDOM"
			__semaphores --target={DO__semaphores} -- "$DO__context.1" "$DO__context.2" || return

			# execute, keeping stdout, copying to stderr, and tracking the exit status to our semaphore file
			__do --right-to-left "$@" > >(
				set +e
				tee -- >(
					set +e
					cat >>/dev/tty
					printf '%s' "$?" >"${DO__semaphores[0]}"
				)
				printf '%s' "$?" >"${DO__semaphores[1]}"
			)

			# once completed, wait for and return the status of our process substitution
			__return $? -- __wait_for_and_return_semaphores "${DO__semaphores[@]}" || return
			return
			;;

		# copy stdout to null
		NULL | null | /dev/null)
			# no-op
			__do --right-to-left "$@"
			return
			;;

		# copy stdout to FD target
		[0-9]*)
			__affirm_value_is_positive_integer "$DO__arg_value" 'file descriptor' || return

			# prepare our semaphore files that will track the exit status of the process substitution
			local DO__semaphores DO__context="__do.copy-stdout-to-fd.$RANDOM$RANDOM"
			__semaphores --target={DO__semaphores} -- "$DO__context.1" "$DO__context.2" || return

			# execute, keeping stdout, copying to FD, and tracking the exit status to our semaphore file
			__do --right-to-left "$@" > >(
				set +e
				tee -- >(
					set +e
					cat >&"$DO__arg_value"
					printf '%s' "$?" >"${DO__semaphores[0]}"
				)
				printf '%s' "$?" >"${DO__semaphores[1]}"
			)

			# once completed, wait for and return the status of our process substitution
			__return $? -- __wait_for_and_return_semaphores "${DO__semaphores[@]}" || return
			return
			;;

		# no-op
		'')
			__do --right-to-left "$@"
			return
			;;

		# copy stdout to file target
		*)
			# prepare our semaphore file that will track the exit status of the process substitution
			local DO__semaphore DO__context="__do.copy-stdout-to-file.$RANDOM$RANDOM"
			DO__semaphore="$(__get_semaphore "$DO__context")" || return

			# execute, keeping stdout, copying to the value target, and tracking the exit status to our semaphore file
			__do --right-to-left "$@" > >(
				set +e
				tee -a -- "$DO__arg_value"
				printf '%s' "$?" >"$DO__semaphore"
			)

			# once completed, wait for and return the status of our process substitution
			__return $? -- __wait_for_and_return_semaphores "$DO__semaphore" || return
			return
			;;

		# done with stdout copy
		esac
		;;

	--redirect-stderr=*)
		case "$DO__arg_value" in

		# redirect stderr to stdout
		1 | STDOUT | stdout | /dev/stdout)
			__do --right-to-left "$@" 2>&1
			return
			;;

		# redirect stderr to stderr, this is a no-op, continue to next
		2 | STDERR | stderr | /dev/stderr)
			__do --right-to-left "$@"
			return
			;;

		# redirect stderr to tty
		TTY | tty | /dev/tty)
			__do --right-to-left "$@" 2>>/dev/tty
			return
			;;

		# redirect stderr to null
		NULL | null | /dev/null)
			__do --right-to-left "$@" 2>/dev/null
			return
			;;

		# redirect stderr to FD target
		[0-9]*)
			__affirm_value_is_positive_integer "$DO__arg_value" 'file descriptor' || return
			__do --right-to-left "$@" 2>&"$DO__arg_value"
			return
			;;

		# no-op
		'')
			__do --right-to-left "$@"
			return
			;;

		# redirect stderr to file target
		*)
			__do --right-to-left "$@" 2>>"$DO__arg_value"
			return
			;;

		# done with stderr redirect
		esac
		;;

	# copy, stderr, to various targets
	--copy-stderr=*)
		case "$DO__arg_value" in

		# copy stderr to stdout
		1 | STDOUT | stdout | /dev/stdout)
			# prepare our semaphore files that will track the exit status of the process substitution
			local DO__semaphores DO__context="__do.copy-stderr-to-stdout.$RANDOM$RANDOM"
			__semaphores --target={DO__semaphores} -- "$DO__context.1" "$DO__context.2" || return

			# execute, keeping stderr, copying to stdout, and tracking the exit status to our semaphore file
			__do --right-to-left "$@" 2> >(
				set +e
				tee -- >(
					set +e
					cat
					printf '%s' "$?" >"${DO__semaphores[0]}"
				) >&2
				printf '%s' "$?" >"${DO__semaphores[1]}"
			)

			# once completed, wait for and return the status of our process substitution
			__return $? -- __wait_for_and_return_semaphores "${DO__semaphores[@]}" || return
			return
			;;

		# copy stderr to stderr, this behaviour is unspecified, should it double the data to stderr?
		2 | STDERR | stderr | /dev/stderr)
			# no-op
			__do --right-to-left "$@"
			return
			;;

		# copy stderr to tty
		TTY | tty | /dev/tty)
			# prepare our semaphore files that will track the exit status of the process substitution
			local DO__semaphores DO__context="__do.copy-stderr-to-tty.$RANDOM$RANDOM"
			__semaphores --target={DO__semaphores} -- "$DO__context.1" "$DO__context.2" || return

			# execute, keeping stderr, copying to stdout, and tracking the exit status to our semaphore file
			__do --right-to-left "$@" 2> >(
				set +e
				tee -- >(
					set +e
					cat >>/dev/tty
					printf '%s' "$?" >"${DO__semaphores[0]}"
				) >&2
				printf '%s' "$?" >"${DO__semaphores[1]}"
			)

			# once completed, wait for and return the status of our process substitution
			__return $? -- __wait_for_and_return_semaphores "${DO__semaphores[@]}" || return
			return
			;;

		# copy stderr to null
		NULL | null | /dev/null)
			# no-op
			__do --right-to-left "$@"
			return
			;;

		# copy stderr to FD target
		[0-9]*)
			__affirm_value_is_positive_integer "$DO__arg_value" 'file descriptor' || return

			# prepare our semaphore files that will track the exit status of the process substitution
			local DO__semaphores DO__context="__do.copy-stderr-to-fd.$RANDOM$RANDOM"
			__semaphores --target={DO__semaphores} -- "$DO__context.1" "$DO__context.2" || return

			# execute, keeping stdout, copying to FD, and tracking the exit status to our semaphore file
			__do --right-to-left "$@" 2> >(
				set +e
				tee -- >(
					set +e
					cat >&"$DO__arg_value"
					printf '%s' "$?" >"${DO__semaphores[0]}"
				) >&2
				printf '%s' "$?" >"${DO__semaphores[1]}"
			)

			# once completed, wait for and return the status of our process substitution
			__return $? -- __wait_for_and_return_semaphores "${DO__semaphores[@]}" || return
			return
			;;

		# no-op
		'')
			__do --right-to-left "$@"
			return
			;;

		# copy stderr to file target
		*)
			# prepare our semaphore file that will track the exit status of the process substitution
			local DO__semaphore DO__context="__do.copy-stderr-to-file.$RANDOM$RANDOM"
			DO__semaphore="$(__get_semaphore "$DO__context")" || return

			# execute, keeping stderr, copying to the value target, and tracking the exit status to our semaphore file
			__do --right-to-left "$@" 2> >(
				set +e
				tee -a -- "$DO__arg_value" >&2
				printf '%s' "$?" >"$DO__semaphore"
			)

			# once completed, wait for and return the status of our process substitution
			__return $? -- __wait_for_and_return_semaphores "$DO__semaphore" || return
			return
			;;

		# done with stderr copy
		esac
		;;

	--redirect-output=*)
		case "$DO__arg_value" in

		# redirect stderr to stdout
		1 | STDOUT | stdout | /dev/stdout)
			__do --right-to-left "$@" 2>&1
			return
			;;

		# redirect stdout to stderr
		2 | STDERR | stderr | /dev/stderr)
			__do --right-to-left "$@" >&2
			return
			;;

		# redirect stderr to stdout, then stdout to tty, as `&>>` is not supported in all bash versions
		TTY | tty | /dev/tty)
			__do --right-to-left "$@" >>/dev/tty 2>&1
			return
			;;

		# redirect output to null
		NULL | null | /dev/null | no)
			__do --right-to-left "$@" &>/dev/null
			return
			;;

		# redirect stderr to stdout, such that and then, both stdout and stderr are redirected to the fd target
		[0-9]*)
			__affirm_value_is_positive_integer "$DO__arg_value" 'file descriptor' || return
			__do --right-to-left "$@" 1>&"$DO__arg_value" 2>&1
			return
			;;

		# no-op
		'')
			__do --right-to-left "$@"
			return
			;;

		# redirect stderr to stdout, such that and then, both stdout and stderr are redirect to the file target
		*)
			__do --right-to-left "$@" >"$DO__arg_value" 2>&1
			return
			;;

		# done with output redirect
		esac
		;;

	# copy, output, to various targets
	--copy-output=*)
		case "$DO__arg_value" in

		# copy output to stdout, this behaviour is unspecified, as there is no way to send it back to output
		1 | STDOUT | stdout | /dev/stdout)
			# @todo implement this
			__print_lines "ERROR: ${FUNCNAME[0]}: A to be implemented flag was provided: $DO__arg" >&2 || :
			return 78 # NOSYS 78 Function not implemented
			;;

		# copy output to stderr, this behaviour is unspecified, as there is no way to send it back to output
		2 | STDERR | stderr | /dev/stderr)
			# @todo implement this
			__print_lines "ERROR: ${FUNCNAME[0]}: A to be implemented flag was provided: $DO__arg" >&2 || :
			return 78 # NOSYS 78 Function not implemented
			;;

		# copy output to tty, this behaviour is unspecified, as there is no way to send it back to output
		TTY | tty | /dev/tty)
			# @todo implement this
			__print_lines "ERROR: ${FUNCNAME[0]}: A to be implemented flag was provided: $DO__arg" >&2 || :
			return 78 # NOSYS 78 Function not implemented
			;;

		# copy stderr to null
		NULL | null | /dev/null)
			# no-op
			__do --right-to-left "$@"
			return
			;;

		# copy output to FD target, this behaviour is unspecified, as there is no way to send it back to output
		[0-9]*)
			__affirm_value_is_positive_integer "$DO__arg_value" 'file descriptor' || return
			# @todo implement this
			__print_lines "ERROR: ${FUNCNAME[0]}: A to be implemented flag was provided: $DO__arg" >&2 || :
			return 78 # NOSYS 78 Function not implemented
			;;

		# no-op
		'')
			__do --right-to-left "$@"
			return
			;;

		# copy output to file target, this behaviour is unspecified, as there is no way to send it back to output
		*)
			# @todo implement this
			__print_lines "ERROR: ${FUNCNAME[0]}: A to be implemented flag was provided: $DO__arg. You probably want [--copy-stdout+stderr=$DO__arg_value] or [--redirect-output=STDERR --copy-stderr=$DO__arg_value --redirect-output=TTY] instead." >&2 || :
			return 78 # NOSYS 78 Function not implemented
			;;

		# done with stderr copy
		esac
		;;

	# unknown arg
	*)
		__print_lines "ERROR: ${FUNCNAME[0]}: An unrecognised target was provided: $DO__arg" >&2 || :
		return 22 # EINVAL 22 Invalid argument
		;;

	# done with arg
	esac

	# it should never have reached here from the explicit returns
	__print_lines "ERROR: ${FUNCNAME[0]}: An unhandled argument provided: $DO__arg" >&2 || :
	return 29 # ESPIPE 29 Illegal seek
}

# debug helpers, that are overwritten within `dorothy-internals`
function dorothy_try__context_lines {
	:
}
function dorothy_try__dump_lines {
	:
}

# See `dorothy-internals` for details, this is `i6a` plus whatever modifications have come after
function dorothy_try__trap_outer {
	# do not use local, as this is not executed as a function
	DOROTHY_TRY__TRAP_STATUS=$?
	DOROTHY_TRY__TRAP_LOCATION="${BASH_SOURCE[0]-}:${LINENO}:${FUNCNAME-}:$DOROTHY_TRY__SUBSHELL:${BASH_SUBSHELL-}:$-:$BASH_VERSION"
	if [[ $DOROTHY_TRY__TRAP_STATUS -eq 1 && -f $DOROTHY_TRY__SEMAPHORE ]]; then
		# Bash versions 4.2 and 4.3 will change a caught but thrown or continued exit status to 1
		# So we have to restore our saved one from the throw-in-trap-subshell workaround
		DOROTHY_TRY__TRAP_STATUS="$(<"$DOROTHY_TRY__SEMAPHORE")"
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
		# using `__return ...` instead of `return ...` just causes the crash to occur

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
			# { __mkdirp "$DOROTHY_TRY__DIR" && __print_lines "$DOROTHY_TRY__TRAP_STATUS" >"$DOROTHY_TRY__SEMAPHORE"; } || :
			__print_lines "$DOROTHY_TRY__TRAP_STATUS" >"$DOROTHY_TRY__SEMAPHORE" || :
			# wait for semaphores if needed
			if [[ $BASH_VERSION_MAJOR -eq 4 && ($BASH_VERSION_MINOR -eq 2 || $BASH_VERSION_MINOR -eq 3) ]]; then
				__wait_for_semaphores "$DOROTHY_TRY__SEMAPHORE"
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
				return "$DOROTHY_TRY__TRAP_STATUS" # bash v3.2, 4.0 will turn this into `return 0`; bash v4.2, 4.3 will turn this into [return 1]
			elif [[ $DOROTHY_TRY__SUBSHELL != "${BASH_SUBSHELL-}" ]]; then
				# throw to any effective subshell
				dorothy_try__context_lines "THROW TO SUBSHELL OLD BASH: $DOROTHY_TRY__TRAP_STATUS" "LOCATION: $DOROTHY_TRY__TRAP_LOCATION" "FUNCNAME: ${FUNCNAME[*]}" || :
				# Bash 3.2, 4.0 will crash
				# Bash 4.2, 4.3 will be ok
			elif [[ "$(__get_index_of_parent_function 'dorothy_try__wrapper' '__do' '__try' || :)" -eq 1 ]]; then
				dorothy_try__context_lines "RETURN TO PARENT SUBSHELL OLD BASH: $DOROTHY_TRY__TRAP_STATUS" "LOCATION: $DOROTHY_TRY__TRAP_LOCATION" "FUNCNAME: ${FUNCNAME[*]}" || :
				return "$DOROTHY_TRY__TRAP_STATUS" # for some reason this changes to `return 0` even on 4.2 and 4.3, however this is going to one of our functions, which will load the STORE or SAVED value
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
# `__try {<status-var>} --` same as `__try {<status-var>} --`
# implement `__try --copy-status={<status-var>} --` such that it is applied and returned
# then you will discover that this then makes it seem that `__try --` returns/keeps the status, but it does not
# as such, trying for compat with `__do` is silly, as they are different
function __try {
	# declare local variables
	local DOROTHY_TRY__item DOROTHY_TRY__exit_status_reference=''
	# declare shared variables
	local DOROTHY_TRY__COMMAND=() DOROTHY_TRY__CONTEXT DOROTHY_TRY__SEMAPHORE DOROTHY_TRY__STATUS='' DOROTHY_TRY__SUBSHELL="${BASH_SUBSHELL-}"
	while [[ $# -ne 0 ]]; do
		DOROTHY_TRY__item="$1"
		shift
		case "$DOROTHY_TRY__item" in
		'--')
			DOROTHY_TRY__COMMAND+=("$@")
			shift $#
			break
			;;
		{*}) __dereference --origin="$DOROTHY_TRY__item" --name={DOROTHY_TRY__exit_status_reference} || return ;;
		*)
			__print_lines "ERROR: ${FUNCNAME[0]}: An unrecognised flag was provided: $DOROTHY_TRY__item" >&2 || :
			return 22 # EINVAL 22 Invalid argument
			;;
		esac
	done

	# update globals
	DOROTHY_TRY__COUNT="${DOROTHY_TRY__COUNT:-0}" # so we can remove our trap once all tries are finished

	# update shared variables
	DOROTHY_TRY__CONTEXT="$BASH_VERSION_CURRENT-$(__get_first_parent_that_is_not 'eval_capture' '__do' '__try' 'dorothy_try_wrapper' || :)-$RANDOM"
	DOROTHY_TRY__SEMAPHORE="$(__get_semaphore "__try.$DOROTHY_TRY__CONTEXT.status")"

	# execute the command within our wrapper, such that we can handle edge cases, and identify it inside our trap
	DOROTHY_TRY__COUNT="$((DOROTHY_TRY__COUNT + 1))" # increment the count
	dorothy_try__wrapper
	DOROTHY_TRY__COUNT="$((DOROTHY_TRY__COUNT - 1))"
	if [[ $DOROTHY_TRY__COUNT -eq 0 ]]; then
		# if all our tries have now finished, remove the lingering trap
		trap - ERR
	fi

	# load the exit status if necessary
	if [[ -f $DOROTHY_TRY__SEMAPHORE ]]; then
		local DOROTHY_TRY__loaded_status
		DOROTHY_TRY__loaded_status="$(<"$DOROTHY_TRY__SEMAPHORE")"
		if [[ $DOROTHY_TRY__loaded_status -ne $DOROTHY_TRY__STATUS ]]; then
			dorothy_try__context_lines "LOADED: $DOROTHY_TRY__loaded_status    PRIOR: $DOROTHY_TRY__STATUS    NEEDED" || :
		else
			dorothy_try__context_lines "LOADED: $DOROTHY_TRY__loaded_status    PRIOR: $DOROTHY_TRY__STATUS    SAME" || :
		fi
		DOROTHY_TRY__STATUS="$DOROTHY_TRY__loaded_status"
		rm -f -- "$DOROTHY_TRY__SEMAPHORE" || :
	fi

	# apply the exit status
	dorothy_try__context_lines "RESULT: ${DOROTHY_TRY__STATUS:-0}" || :
	if [[ -n $DOROTHY_TRY__exit_status_reference ]]; then
		eval "$DOROTHY_TRY__exit_status_reference=${DOROTHY_TRY__STATUS:-0}"
	fi

	# return success
	return 0
}

function eval_capture {
	local item cmd=() exit_status_variable='' stdout_variable='' stderr_variable='' output_variable='' stdout_target='/dev/stdout' stderr_target='/dev/stderr'
	if __command_exists -- dorothy-warnings; then
		dorothy-warnings add --code='eval_capture' --bold=' has been deprecated in favor of ' --code='__try' --bold=' and ' --code='__do' || :
	fi
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
			__print_lines "ERROR: ${FUNCNAME[0]}: An unrecognised flag was provided: $item" >&2 || :
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

# =============================================================================
# Extra Toolkit

# -------------------------------------
# User & Group Toolkit

# Bash automatically assigns variables that provide information about the current user (UID, EUID, and GROUPS), the current host (HOSTTYPE, OSTYPE, MACHTYPE, and HOSTNAME), and the instance of Bash that is running (BASH, BASH_VERSION, and BASH_VERSINFO). See Bash Variables, for details.
# once elevated with sudo:
# SUDO_GID=20
# SUDO_UID=501
# SUDO_USER=balupton
# USER=root
# before elevation:
# USER=balupton
# UID=501
# EID=
# in terms of terminology, there is uid, effective uid, real uid, and login uid: what their complete overlap is, I am unsure
# `whoami` is deprecated in favour of `id -u`
# `id` gives the current user and group
# `users` give the login user
# `groups` is an alias for `id -Gn` so it gives the current user's groups
# regarding macos and linux, -u works on both macos and linux, as macos lacks --user
function __prepare_login_user {
	if ! __is_var_set {LOGIN_USER}; then
		LOGIN_USER="${SUDO_USER-}"
		if [[ -z $LOGIN_USER ]]; then
			function __cut {
				# turn `balupton balupton ...` into `balupton`
				local first
				IFS=' ' read -r first _
				__print_lines "$first"
			}
			LOGIN_USER="$(users | __cut || :)"
			if [[ -z $LOGIN_USER ]]; then
				# if `users` didn't work (as is the case on CI) then get the current user instead
				__prepare_current_user || :
				LOGIN_USER="$CURRENT_USER"
				if [[ -z $LOGIN_USER ]]; then
					__print_lines "ERROR: ${FUNCNAME[0]}: Unable to fetch the username of the login user." >&2 || :
					return 1
				fi
			fi
		fi
	fi
}
function __prepare_login_uid {
	if ! __is_var_set {LOGIN_UID}; then
		LOGIN_UID="${SUDO_UID-}"
		if [[ -z $LOGIN_UID ]]; then
			__prepare_login_user || :
			LOGIN_UID="$(id -u "$LOGIN_USER" || :)"
			if [[ -z $LOGIN_UID ]]; then
				__print_lines "ERROR: ${FUNCNAME[0]}: Unable to fetch the user ID of the login user." >&2 || :
				return 1
			fi
		fi
	fi
}
function __prepare_login_group {
	if ! __is_var_set {LOGIN_GROUP}; then
		local
		__prepare_login_uid || :
		LOGIN_GROUP="$(id -gn "$LOGIN_UID" || :)"
		if [[ -z $LOGIN_GROUP ]]; then
			__print_lines "ERROR: ${FUNCNAME[0]}: Unable to fetch the group name of the login user." >&2 || :
			return 1
		fi
	fi
}
function __prepare_login_gid {
	if ! __is_var_set {LOGIN_GID}; then
		LOGIN_GID="${SUDO_GID-}"
		if [[ -z $LOGIN_GID ]]; then
			__prepare_login_uid || :
			LOGIN_GID="$(id -g "$LOGIN_UID" || :)"
			if [[ -z $LOGIN_GID ]]; then
				__print_lines "ERROR: ${FUNCNAME[0]}: Unable to fetch the group ID of the login user." >&2 || :
				return 1
			fi
		fi
	fi
}
function __prepare_login_groups {
	if ! __is_var_set {LOGIN_GROUPS}; then
		local groups
		__prepare_login_uid || :
		groups="$(id -Gn "$LOGIN_UID" || :)"
		__split --source={groups} --target={LOGIN_GROUPS} --delimiter=' ' --no-zero-length || :
		# trunk-ignore(shellcheck/SC2153)
		if [[ ${#LOGIN_GROUPS[@]} -eq 0 ]]; then
			__print_lines "ERROR: ${FUNCNAME[0]}: Unable to fetch the group names of the login user." >&2 || :
			return 1
		fi
	fi
}
function __prepare_login_gids {
	if ! __is_var_set {LOGIN_GIDS}; then
		local groups
		__prepare_login_uid || :
		groups="$(id -G "$LOGIN_UID" || :)"
		__split --source={groups} --target={LOGIN_GIDS} --delimiter=' ' --no-zero-length || :
		# trunk-ignore(shellcheck/SC2153)
		if [[ ${#LOGIN_GIDS[@]} -eq 0 ]]; then
			__print_lines "ERROR: ${FUNCNAME[0]}: Unable to fetch the groups IDs of the login user." >&2 || :
			return 1
		fi
	fi
}
function __prepare_current_user {
	if ! __is_var_set {CURRENT_USER}; then
		CURRENT_USER="${USER-}"
		if [[ -z $CURRENT_USER ]]; then
			# `whoami` is deprecated is replaced/delegates to `id -un`
			# note that `dorothy` sets `USER` to the parent of the Dorothy installation, which is appropriate for its `cron` use case
			CURRENT_USER="$(id -un || :)"
			if [[ -z $CURRENT_USER ]]; then
				__print_lines "ERROR: ${FUNCNAME[0]}: Unable to fetch the username of the current user." >&2 || :
				return 1
			fi
		fi
	fi
}
function __prepare_current_uid {
	if ! __is_var_set {CURRENT_UID}; then
		CURRENT_UID="${UID-}"
		if [[ -z $CURRENT_UID ]]; then
			CURRENT_UID="$(id -u || :)"
			if [[ -z $CURRENT_UID ]]; then
				__print_lines "ERROR: ${FUNCNAME[0]}: Unable to fetch the user ID of the current user." >&2 || :
				return 1
			fi
		fi
	fi
}
function __prepare_current_group {
	if ! __is_var_set {CURRENT_GROUP}; then
		CURRENT_GROUP="$(id -gn || :)"
		if [[ -z $CURRENT_GROUP ]]; then
			__print_lines "ERROR: ${FUNCNAME[0]}: Unable to fetch the group name of the current user." >&2 || :
			return 1
		fi
	fi
}
function __prepare_current_gid {
	if ! __is_var_set {CURRENT_GID}; then
		CURRENT_GID="$(id -g || :)"
		if [[ -z $CURRENT_GID ]]; then
			__print_lines "ERROR: ${FUNCNAME[0]}: Unable to fetch the group ID of the current user." >&2 || :
			return 1
		fi
	fi
}
function __prepare_current_groups {
	if ! __is_var_set {CURRENT_GROUPS}; then
		CURRENT_GROUPS=()
		if __is_var_set {GROUPS}; then
			CURRENT_GROUPS=("${GROUPS[@]}")
		fi
		if [[ ${#CURRENT_GROUPS[@]} -eq 0 ]]; then
			local groups
			groups="$(id -Gn || :)"
			__split --source={groups} --target={CURRENT_GROUPS} --delimiter=' ' --no-zero-length || :
			if [[ ${#CURRENT_GROUPS[@]} -eq 0 ]]; then
				__print_lines "ERROR: ${FUNCNAME[0]}: Unable to fetch the group names of the current user." >&2 || :
				return 1
			fi
		fi
	fi
}
function __prepare_current_gids {
	if ! __is_var_set {CURRENT_GIDS}; then
		local groups
		# trunk-ignore(shellcheck/SC2034)
		groups="$(id -G || :)"
		__split --source={groups} --target={CURRENT_GIDS} --delimiter=' ' --no-zero-length || :
		# trunk-ignore(shellcheck/SC2153)
		if [[ ${#CURRENT_GIDS[@]} -eq 0 ]]; then
			__print_lines "ERROR: ${FUNCNAME[0]}: Unable to fetch the groups IDs of the current user." >&2 || :
			return 1
		fi
	fi
}

# -------------------------------------
# Filesystem & Elevate Toolkit

# see `commands/eval-helper --elevate` for details
function __elevate {
	# trim -- prefix
	if [[ ${1-} == '--' ]]; then
		shift
	fi
	# forward to `eval-helper --elevate` if it exists, as it is more detailed
	if __command_exists -- eval-helper; then
		eval-helper --elevate -- "$@" || return
		return
	elif __command_exists -- sudo; then
		# check if password is required
		if ! sudo --non-interactive -- true &>/dev/null; then
			# password is required, let the user know what they are being prompted for
			__print_lines \
				'Your password is required to momentarily grant privileges to execute the command:' $'\n' \
				"sudo $*" >&2 || return
		fi
		sudo "$@" # eval
		return
	elif __command_exists -- doas; then
		if ! doas -n true &>/dev/null; then
			__print_lines \
				'Your password is required to momentarily grant privileges to execute the command:' $'\n' \
				"doas $*" >&2 || return
		fi
		doas "$@" # eval
		return
	else
		"$@" # eval
		return
	fi
}
# bc alias
function __try_sudo {
	if __command_exists -- dorothy-warnings; then
		dorothy-warnings add --code='__try_sudo' --bold=' has been deprecated in favor of ' --code='__elevate' || :
	fi
	__elevate "$@" || return
	return
}

# performantly make directories as many directories as possible without sudo
# this is beta, and may change later
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
# @todo replace this with fs-mkdir
# this is beta, and may change later
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
	if __command_exists -- dorothy-warnings; then
		dorothy-warnings add --code='__sudo_mkdirp' --bold=' has been deprecated in favor of ' --code='__elevate_mkdirp' || :
	fi
	__elevate_mkdirp "$@" || return
	return
}

# -------------------------------------
# ANSI Toolkit

# replace shapeshifting ANSI Escape Codes with newlines
# this is beta, and may change later
function __split_shapeshifting {
	# trim -- prefix
	if [[ ${1-} == '--' ]]; then
		shift
	fi
	# proceed
	# regexp should match `echo-clear-lines`, `echo-revolving-door`, `is-shapeshifter`
	# https://www.gnu.org/software/bash/manual/bash.html#Pattern-Matching
	local input
	for input in "$@"; do
		input="${input//[[:cntrl:]]\[*([\;\?0-9])[\][\^\`\~\\ABCDEFGHIJKLMNOPQSTUVWXYZabcdefghijklnosu]/$'\n'}"
		input="${input//[[:cntrl:]][\]\`\^\\78M]/$'\n'}" # save and restore cursor
		input="${input//[[:cntrl:]][bf]/$'\n'}"          # page-up, page-down
		input="${input//[$'\r'$'\177'$'\b']/$'\n'}"
		__print_lines "$input" || return
	done
}

# determine if the input contains shapeshifting ANSI Escape Codes
# this is beta, and may change later
function __is_shapeshifter {
	# trim -- prefix
	if [[ ${1-} == '--' ]]; then
		shift
	fi
	# proceed
	local input trimmed
	for input in "$@"; do
		trimmed="$(__split_shapeshifting -- "$input")" || return
		if [[ $input != "$trimmed" ]]; then
			return 0
		fi
	done
	return 1
}

# -------------------------------------
# File Descriptor Toolkit

# check if the input is a special target
# this is beta, and may change later
function __is_special_file {
	local target="$1"
	case "$target" in
	NULL | TTY | 1 | STDOUT | stdout | /dev/stdout | 2 | STDERR | stderr | /dev/stderr | tty | /dev/tty | null | /dev/null) return 0 ;; # is a special file
	'')
		__print_lines "ERROR: ${FUNCNAME[0]}: An unrecognised target was provided: $target" >&2 || :
		return 22 # EINVAL 22 Invalid argument
		;;
	*) __is_positive_integer "$target" || return 1 ;; # if it is a positive integer, it is a file descriptor
	esac
}

function __is_tty_special_file {
	local target="$1"
	case "$target" in
	TTY | tty | /dev/tty) return 0 ;; # is a special tty
	'')
		__print_lines "ERROR: ${FUNCNAME[0]}: An unrecognised target was provided: $target" >&2 || :
		return 22 # EINVAL 22 Invalid argument
		;;
	*) return 1 ;; # not a special tty
	esac
}

# Open a file descriptor in a cross-bash compatible way
# alternative implementations at https://stackoverflow.com/q/8297415/130638
# __open_fd ...<{file_descriptor_reference}> ...<file_descriptor_number> <mode> <target>
function __open_fd {
	local OPEN_FD__item OPEN_FD__numbers=() OPEN_FD__references=() OPEN_FD__mode='' OPEN_FD__target_number='' OPEN_FD__target_file=''
	while [[ $# -ne 0 ]]; do
		OPEN_FD__item="$1"
		shift
		if [[ -z $OPEN_FD__mode ]]; then
			case "$OPEN_FD__item" in
			# file descriptor
			{*}) __dereference --origin="$OPEN_FD__item" --name={OPEN_FD__references} || return ;;
			[0-9]*)
				__affirm_value_is_positive_integer "$OPEN_FD__item" 'file descriptor' || return
				OPEN_FD__numbers+=("$OPEN_FD__item")
				;;
			# mode
			'<' | --read) OPEN_FD__mode='<' ;;
			'>' | --overwrite | --write) OPEN_FD__mode='>' ;;
			'<>' | --read-write) OPEN_FD__mode='<>' ;;
			'>>' | --append) OPEN_FD__mode='>>' ;;
			*)
				__print_lines "ERROR: ${FUNCNAME[0]}: Invalid argument provided: $OPEN_FD__item" >&2 || :
				return 22 # EINVAL 22 Invalid argument
				;;
			esac
		elif __is_positive_integer "$OPEN_FD__item"; then
			OPEN_FD__target_number="$OPEN_FD__item"
			break
		else
			OPEN_FD__target_file="$OPEN_FD__item"
			break
		fi
	done
	# if extra arguments, there were too many
	if [[ $# -ne 0 ]]; then
		__print_lines "ERROR: ${FUNCNAME[0]}: Too many arguments provided, expected only a file descriptor number or reference, mode, and target." >&2 || :
		return 22 # EINVAL 22 Invalid argument
	fi
	# must have all the arguments
	local OPEN_FD__references_count OPEN_FD__reference OPEN_FD__number OPEN_FD__eval_statement_exec='' OPEN_FD__eval_statement_assignments=''
	OPEN_FD__references_count=${#OPEN_FD__references[@]}
	if [[ ($OPEN_FD__references_count -eq 0 && ${#OPEN_FD__numbers[@]} -eq 0) || (-z $OPEN_FD__target_number && -z $OPEN_FD__target_file) ]]; then
		__print_lines "ERROR: ${FUNCNAME[0]}: Invalid arguments provided, expected a file descriptor number or reference, mode, and target." >&2 || :
		return 22 # EINVAL 22 Invalid argument
	fi
	# open the references
	if [[ $OPEN_FD__references_count -ne 0 ]]; then
		# Bash >= 4.1
		if [[ $BASH_VERSION_MAJOR -ge 5 || ($BASH_VERSION_MAJOR -eq 4 && $BASH_VERSION_MINOR -ge 1) ]]; then
			if [[ -n $OPEN_FD__target_number ]]; then
				for OPEN_FD__reference in "${OPEN_FD__references[@]}"; do
					OPEN_FD__eval_statement_exec+="{$OPEN_FD__reference}$OPEN_FD__mode&$OPEN_FD__target_number "
				done
			else
				for OPEN_FD__reference in "${OPEN_FD__references[@]}"; do
					OPEN_FD__eval_statement_exec+="{$OPEN_FD__reference}$OPEN_FD__mode\"\${OPEN_FD__target_file}\" "
				done
			fi
		else
			# FD 3 and 4 are commonly used, so skip them amd start at 5
			local OPEN_FD__end OPEN_FD__references_index
			OPEN_FD__end="$(ulimit -n)" # this must be here, instead of in the for loop initialisation, as otherwise bash 4.3 and 4.4 will crash
			for ((OPEN_FD__number = 5, OPEN_FD__references_index = 0; OPEN_FD__number < OPEN_FD__end && OPEN_FD__references_index < OPEN_FD__references_count; OPEN_FD__number++)); do
				# test if the file descriptor is not available on both read and write, then it means it is available
				if ! eval ": <&$OPEN_FD__number" &>/dev/null && ! eval ": >&$OPEN_FD__number" &>/dev/null; then
					# it failed, so it is available
					OPEN_FD__numbers+=("$OPEN_FD__number")
					OPEN_FD__reference="${OPEN_FD__references[$OPEN_FD__references_index]}"
					OPEN_FD__references_index=$((OPEN_FD__references_index + 1))
					OPEN_FD__eval_statement_assignments+="$OPEN_FD__reference=$OPEN_FD__number; "
				fi
			done
		fi
	fi
	# open the numbers
	if [[ -n $OPEN_FD__target_number ]]; then
		for OPEN_FD__number in "${OPEN_FD__numbers[@]}"; do
			OPEN_FD__eval_statement_exec+="$OPEN_FD__number$OPEN_FD__mode&$OPEN_FD__target_number "
		done
	else
		for OPEN_FD__number in "${OPEN_FD__numbers[@]}"; do
			OPEN_FD__eval_statement_exec+="$OPEN_FD__number$OPEN_FD__mode\"\${OPEN_FD__target_file}\" "
		done
	fi
	# apply
	eval "exec $OPEN_FD__eval_statement_exec; $OPEN_FD__eval_statement_assignments" || return
}

# __close_fd ...<{file_descriptor_reference}> ...<file_descriptor_number>
function __close_fd {
	local CLOSE_FD__item CLOSE_FD__number CLOSE_FD__reference CLOSE_FD__eval_statement_exec=''
	__affirm_length_defined $# 'file descriptor reference or file descriptor number' || return
	for CLOSE_FD__item in "$@"; do
		if __is_positive_integer "$CLOSE_FD__item"; then
			CLOSE_FD__number="$CLOSE_FD__item"
		else
			if [[ $BASH_VERSION_MAJOR -ge 5 || ($BASH_VERSION_MAJOR -eq 4 && $BASH_VERSION_MINOR -ge 1) ]]; then
				# close via the file descriptor reference
				__dereference --origin="$CLOSE_FD__item" --name={CLOSE_FD__reference} || return
				CLOSE_FD__eval_statement_exec+="{$CLOSE_FD__reference}>&- "
				continue
			else
				# get the file descriptor directly
				__dereference --origin="$CLOSE_FD__item" --value={CLOSE_FD__number} || return
				if [[ -z $CLOSE_FD__number ]]; then
					__print_lines "ERROR: ${FUNCNAME[0]}: Invalid file descriptor reference provided: $CLOSE_FD__item" >&2 || :
					return 22 # EINVAL 22 Invalid argument
				fi
			fi
		fi
		# close the file descriptor number
		CLOSE_FD__eval_statement_exec+="$CLOSE_FD__number>&- "
	done
	eval "exec $CLOSE_FD__eval_statement_exec" || return
}

# -------------------------------------
# Semaphore Toolkit

function __get_semlock {
	local context_id="$1" dir="${XDG_CACHE_HOME:-"$HOME/.cache"}/dorothy/semlocks" semlock wait pid=$$
	__mkdirp "$dir" || return
	# the lock file contains the process id that has the lock
	semlock="$dir/$context_id.lock"
	# wait for a exclusive lock
	while :; do
		# don't bother with a [[ -s "$semlock" ]] before `cat` as the semlock could have been removed between
		wait="$(cat "$semlock" 2>/dev/null || :)"
		if [[ -z $wait ]]; then
			__print_string "$pid" >"$semlock" || return
		elif [[ $wait == "$pid" ]]; then
			break
		elif [[ "$(ps -p "$wait" &>/dev/null || __print_string dead)" == 'dead' ]]; then
			# the process is dead, it probably crashed, so failed to cleanup, so remove the lock file
			rm -f "$semlock" || return
		fi
		sleep "0.01$RANDOM"
	done
	__print_lines "$semlock" || return
}

# For semaphores, use $RANDOM$RANDOM as a single $RANDOM caused conflicts on Dorothy's CI tests when we didn't actually use semaphores, now that we use semaphores, we solve the underlying race conditions that caused the conflicts in the first place, however keep the double $RANDOM so it is enough entropy we don't have to bother for an existence check, here are the tests that had conflicts:
# https://github.com/bevry/dorothy/actions/runs/13038210988/job/36373738417#step:2:7505
# https://github.com/bevry/dorothy/actions/runs/13038210988/job/36373738417#step:2:12541
# as to why use `__get_semaphore` instead of `mktemp`, is that we want `dorothy test` to check if we cleaned everything up, furthermore, `mktemp` actually makes the files, so you have to do more expensive `-s` checks
function __get_semaphore {
	local context_id="${1:-"$RANDOM$RANDOM"}" dir="${XDG_CACHE_HOME:-"$HOME/.cache"}/dorothy/semaphores"
	__mkdirp "$dir" || return
	__print_lines "$dir/$context_id" || return
}

# adds/appends the semaphores to the target array variable
# __semaphores --target={<array-variable-reference>} -- ...<context-id>
function __semaphores {
	# process reference argument
	local SEMAPHORES__item SEMAPHORES__reference='' SEMAPHORES__context_ids=() SEMAPHORES__size=''
	while [[ $# -ne 0 ]]; do
		SEMAPHORES__item="$1"
		shift
		case "$SEMAPHORES__item" in
		--target={*})
			__affirm_value_is_undefined "$SEMAPHORES__reference" 'target reference' || return
			__dereference --origin="${SEMAPHORES__item#*=}" --name={SEMAPHORES__reference} || return
			;;
		--size=*)
			__affirm_value_is_undefined "$SEMAPHORES__size" 'size/count of semaphores' || return
			SEMAPHORES__size="${SEMAPHORES__item#*=}"
			;;
		--)
			SEMAPHORES__context_ids+=("$@")
			shift $#
			break
			;;
		--*) __unrecognised_flag "$TO__item" || return ;;
		*) __unrecognised_argument "$TO__item" || return ;;
		esac
	done
	# turn context ids into semaphores
	local SEMAPHORES__context_id SEMAPHORES__semaphores=() SEMAPHORES__index
	for SEMAPHORES__context_id in "${SEMAPHORES__context_ids[@]}"; do
		SEMAPHORES__semaphores+=("$(__get_semaphore "$SEMAPHORES__context_id")") || return
	done
	for ((SEMAPHORES__index = 0; SEMAPHORES__index < SEMAPHORES__size; SEMAPHORES__index++)); do
		SEMAPHORES__semaphores+=("$(__get_semaphore)") || return
	done
	# append the semaphores to the target
	eval "$SEMAPHORES__reference+=(\"\${SEMAPHORES__semaphores[@]}\")" || return
}

# As to why semaphores are even necessary,
# >( ... ) happens asynchronously, however the commands within >(...) happen synchronously, as such we can use this technique to know when they are done, otherwise on the very rare occasion the files may not exist or be incomplete by the time we get to to reading them: https://github.com/bevry/dorothy/issues/277
# Note that this waits forever on bash 4.1.0, as the `touch` commands that create our semaphore only execute after a `ctrl+c`, other older and newer versions are fine
function __wait_for_semaphores {
	# skip if empty
	if [[ $# -eq 0 ]]; then
		return 0
	fi
	# wait for each semaphore to exist
	local semaphore
	for semaphore in "$@"; do
		while [[ ! -f $semaphore ]]; do
			sleep 0.01
		done
	done
}
function __wait_for_and_remove_semaphores {
	# skip if empty
	if [[ $# -eq 0 ]]; then
		return 0
	fi
	# wait for each semaphore to exist, then remove them
	__wait_for_semaphores "$@" || return
	rm -f -- "$@" || return
}
function __wait_for_and_return_semaphores {
	# skip if empty
	if [[ $# -eq 0 ]]; then
		return 0
	fi
	# wait for each semaphore that represents an exit status to exist and to be written, then remove them
	local semaphore semaphore_status=0
	for semaphore in "$@"; do
		# needs -s as otherwise the file may exist but may not have finished writing, which would result in:
		# return: : numeric argument required
		while [[ ! -s $semaphore ]]; do
			sleep 0.01
		done
		# always return the failure
		if [[ $semaphore_status -eq 0 ]]; then
			semaphore_status="$(<"$semaphore")" || {
				__print_lines "ERROR: ${FUNCNAME[0]}: Failed to read semaphore file: $semaphore" >&2 || :
				return 5 # EIO 5 I/O error
			} || return
		fi
	done
	rm -f -- "$@" || :
	return "$semaphore_status"
}

# -------------------------------------
# Strings & Arrays Toolkit

# appends the size with optional fill values to the the target array variables
function __array {
	local ARRAY__item ARRAY__references=() ARRAY__size ARRAY__fill=''
	while [[ $# -ne 0 ]]; do
		ARRAY__item="$1"
		shift
		case "$ARRAY__item" in
		--target={*}) __dereference --origin="${ARRAY__item#*=}" --name={ARRAY__references} || return ;;
		--size=*)
			__affirm_value_is_undefined "${ARRAY__size-}" 'array size' || return
			ARRAY__size="${ARRAY__item#*=}"
			;;
		--fill=*)
			__affirm_value_is_undefined "$ARRAY__fill" 'array fill' || return
			# trunk-ignore(shellcheck/SC2034)
			ARRAY__fill="${ARRAY__item#*=}"
			;;
		--*) __unrecognised_flag "$ARRAY__item" || return ;;
		*) __unrecognised_argument "$ARRAY__item" || return ;;
		esac
	done
	__affirm_length_defined "${#ARRAY__references[@]}" 'variable reference' || return
	# generate the array values
	local ARRAY__index ARRAY__fills='' ARRAY__eval_statement='' ARRAY__reference
	for ((ARRAY__index = 0; ARRAY__index < ARRAY__size; ARRAY__index++)); do
		# the alternative would be using `{...@Q}` however that isn't available on all bash versions, but this is equally good, perhaps better
		ARRAY__fills+='"$ARRAY__fill" '
	done
	# apply the list to the target, while avoiding conflicts
	for ARRAY__reference in "${ARRAY__references[@]}"; do
		# apply the list to the target
		ARRAY__eval_statement+="$ARRAY__reference+=($ARRAY__fills); "
	done
	eval "$ARRAY__eval_statement" || return
}

# set the targets to the value(s) at the indices of the source reference
function __at {
	local AT__indices=()
	# <single-source helper arguments>
	local AT__item AT__source_reference='' AT__targets=() AT__mode='' AT__inputs AT__input
	while [[ $# -ne 0 ]]; do
		AT__item="$1"
		shift
		case "$AT__item" in
		--source={*})
			__affirm_value_is_undefined "$AT__source_reference" 'source reference' || return
			__dereference --origin="${AT__item#*=}" --name={AT__source_reference} || return
			;;
		--source+target={*})
			AT__item="${AT__item#*=}"
			AT__targets+=("$AT__item")
			__affirm_value_is_undefined "$AT__source_reference" 'source reference' || return
			__dereference --origin="$AT__item" --name={AT__source_reference} || return
			;;
		--targets=*) __dereference --origin="${AT__item#*=}" --value={AT__targets} || return ;;
		--target=*) AT__targets+=("${AT__item#*=}") ;;
		--mode=prepend | --mode=append | --mode=overwrite | --mode=)
			__affirm_value_is_undefined "$AT__mode" 'write mode' || return
			AT__mode="${AT__item#*=}"
			;;
		--append | --prepend | --overwrite)
			__affirm_value_is_undefined "$AT__mode" 'write mode' || return
			AT__mode="${AT__item:2}"
			;;
		--)
			if [[ -z $AT__source_reference ]]; then
				# they are inputs
				if [[ $# -eq 1 ]]; then
					# a string input
					# trunk-ignore(shellcheck/SC2034)
					AT__input="$1"
					AT__source_reference='AT__input'
				else
					# an array input
					AT__inputs+=("$@")
					AT__source_reference='AT__inputs'
				fi
			else
				# they are indices
				for AT__item in "$@"; do
					__affirm_value_is_integer "$AT__item" 'index' || return
				done
				AT__indices+=("$@")
			fi
			shift $#
			break
			;;
		# </single-source helper arguments>
		[0-9]* | -[0-9]*)
			__affirm_value_is_integer "$AT__item" 'index' || return
			AT__indices+=("$AT__item")
			;;
		--*) __unrecognised_flag "$AT__item" || return ;;
		*) __unrecognised_argument "$AT__item" || return ;;
		esac
	done
	__affirm_value_is_defined "$AT__source_reference" 'source variable reference' || return
	__affirm_value_is_valid_write_mode "$AT__mode" || return
	__affirm_length_defined "${#AT__indices[@]}" 'index' || return
	# action
	# trunk-ignore(shellcheck/SC2034)
	local AT__results=() AT__eval_segment AT__index
	if __is_array "$AT__source_reference"; then
		eval "AT__size=\${#${AT__source_reference}[@]}"
		AT__eval_segment="AT__results+=(\"\${${AT__source_reference}[\$AT__index]}\")"
	else
		# AT__index could be negative, so wrap it in () to avoid bash version inconsistencies
		eval "AT__size=\${#${AT__source_reference}}"
		AT__eval_segment="AT__results+=(\"\${${AT__source_reference}:(\$AT__index):1}\")"
	fi
	AT__negative_size="$((AT__size * -1))"
	for AT__index in "${AT__indices[@]}"; do
		# validate the index
		if [[ $AT__index == -0 ]]; then
			__print_lines "ERROR: ${FUNCNAME[0]}: The index -0 convention only makes sense when used as a length; for a starting index that fetches the last character, you want -1." >&2 || :
			return 33 # EDOM 33 Numerical argument out of domain
		elif [[ $AT__index -lt $AT__negative_size || $AT__index -ge $AT__size ]]; then
			__print_lines "ERROR: ${FUNCNAME[0]}: The index $AT__index was out of range $AT__negative_size (inclusive) to $AT__size (exclusive)." >&2 || :
			return 33 # EDOM 33 Numerical argument out of domain
		elif [[ $AT__index -lt 0 ]]; then
			AT__index="$((AT__size + AT__index))"
		fi
		eval "$AT__eval_segment" || return
	done
	__to --source={AT__results} --mode="$AT__mode" --targets={AT__targets} || return
}

# set the targets to the index/indices of the value(s) in the source reference
function __index {
	local INDEX__needles=() INDEX__direction='ascending' INDEX__seek_mode='first' INDEX__overlap='no'
	# <single-source helper arguments>
	local INDEX__item INDEX__source_reference='' INDEX__targets=() INDEX__mode='' INDEX__inputs INDEX__input
	while [[ $# -ne 0 ]]; do
		INDEX__item="$1"
		shift
		case "$INDEX__item" in
		--source={*})
			__affirm_value_is_undefined "$INDEX__source_reference" 'source reference' || return
			__dereference --origin="${INDEX__item#*=}" --name={INDEX__source_reference} || return
			;;
		--source+target={*})
			INDEX__item="${INDEX__item#*=}"
			INDEX__targets+=("$INDEX__item")
			__affirm_value_is_undefined "$INDEX__source_reference" 'source reference' || return
			__dereference --origin="$INDEX__item" --name={INDEX__source_reference} || return
			;;
		--targets=*) __dereference --origin="${INDEX__item#*=}" --value={INDEX__targets} || return ;;
		--target=*) INDEX__targets+=("${INDEX__item#*=}") ;;
		--mode=prepend | --mode=append | --mode=overwrite | --mode=)
			__affirm_value_is_undefined "$INDEX__mode" 'write mode' || return
			INDEX__mode="${INDEX__item#*=}"
			;;
		--append | --prepend | --overwrite)
			__affirm_value_is_undefined "$INDEX__mode" 'write mode' || return
			INDEX__mode="${INDEX__item:2}"
			;;
		--)
			if [[ -z $INDEX__source_reference ]]; then
				# they are inputs
				if [[ $# -eq 1 ]]; then
					# a string input
					# trunk-ignore(shellcheck/SC2034)
					INDEX__input="$1"
					INDEX__source_reference='INDEX__input'
				else
					# an array input
					INDEX__inputs+=("$@")
					INDEX__source_reference='INDEX__inputs'
				fi
			else
				# they are needles
				INDEX__needles+=("$@")
			fi
			shift $#
			break
			;;
		# </single-source helper arguments>
		--needle=*) INDEX__needles+=("${INDEX__item#*=}") ;;
		--reverse) INDEX__direction='descending' ;;
		--first) INDEX__seek_mode='first' ;;                # only the first match of any needle
		--single) INDEX__seek_mode='single' ;;              # only the first match of each needle
		--multiple) INDEX__seek_mode='multiple' ;;          # all matches of all needles
		--overlap | --overlap=yes) INDEX__overlap='yes' ;;  # for --multiple string matches, "aaaa" with needles "aa" and "a" will match "aa" thrice and "a" four times
		--no-overlap | --overlap=no) INDEX__overlap='no' ;; # for --multiple string matches, "aaaa" with needles "aa" and "a" will match "aa" twice and "a" zero times
		--*) __unrecognised_flag "$INDEX__item" || return ;;
		*) __unrecognised_argument "$INDEX__item" || return ;;
		esac
	done
	__affirm_value_is_defined "$INDEX__source_reference" 'source variable reference' || return
	__affirm_value_is_valid_write_mode "$INDEX__mode" || return
	__affirm_length_defined "${#INDEX__needles[@]}" 'needle' || return
	# process
	local -i INDEX__value_index INDEX__values_size INDEX__needles_size="${#INDEX__needles[@]}" INDEX__needle_size INDEX__last
	local INDEX__value INDEX__needle INDEX__results=() INDEX__intro_eval_segment INDEX__value_eval_segment INDEX__matched_eval_segment INDEX__for_segment INDEX__finale_eval_segment=
	if __is_array "$INDEX__source_reference"; then
		INDEX__intro_eval_segment="INDEX__values_size=\${#${INDEX__source_reference}[@]}" || return
		INDEX__value_eval_segment="INDEX__value=\"\${${INDEX__source_reference}[\$INDEX__value_index]}\""
	else
		INDEX__intro_eval_segment="INDEX__values_size=\${#${INDEX__source_reference}}" || return
		INDEX__value_eval_segment="INDEX__needle_size=\${#INDEX__needle}; INDEX__value=\"\${${INDEX__source_reference}:\$INDEX__value_index:\$INDEX__needle_size}\""
	fi
	if [[ $INDEX__direction == 'ascending' ]]; then
		INDEX__for_segment='INDEX__value_index = 0; INDEX__value_index < INDEX__values_size; ++INDEX__value_index'
	else
		# trunk-ignore(shellcheck/SC2034)
		INDEX__intro_eval_segment+='; INDEX__last="$((INDEX__values_size - 1))"'
		INDEX__for_segment='INDEX__value_index = INDEX__last; INDEX__value_index >= 0; --INDEX__value_index'
	fi
	if [[ $INDEX__seek_mode == 'multiple' ]]; then
		INDEX__matched_eval_segment='INDEX__results+=("$INDEX__value_index")'
		INDEX__finale_eval_segment='__to --source={INDEX__results} --mode="$INDEX__mode" --targets={INDEX__targets} || return'
	elif [[ $INDEX__seek_mode == 'single' ]]; then
		__array --size="$INDEX__needles_size" --target={INDEX__results} || return
		INDEX__matched_eval_segment='INDEX__results[INDEX__needle_index]="$INDEX__value_index"'
		INDEX__finale_eval_segment='__to --source={INDEX__results} --mode="$INDEX__mode" --targets={INDEX__targets} || return'
	else
		# first
		INDEX__matched_eval_segment='INDEX__results+=("$INDEX__value_index"); break 2'
		INDEX__finale_eval_segment='if [[ ${#INDEX__results[@]} -eq 0 ]]; then INDEX__results+=(""); fi; __to --source={INDEX__results\[0\]} --mode="$INDEX__mode" --targets={INDEX__targets} || return'
	fi
	if [[ $INDEX__seek_mode == 'single' || $INDEX__seek_mode == 'multiple' ]]; then
		if [[ $INDEX__overlap == 'no' ]]; then
			if [[ $INDEX__direction == 'ascending' ]]; then
				# -1 to offset the upcoming increment from the for loop
				INDEX__matched_eval_segment+='; INDEX__value_index=$((INDEX__value_index + INDEX__needle_size - 1)); break'
			else
				# +1 to offset the upcoming decrement from the for loop
				INDEX__matched_eval_segment+='; INDEX__value_index=$((INDEX__value_index - INDEX__needle_size + 1)); break'
			fi
		fi
	fi
	# process
	eval "
	$INDEX__intro_eval_segment
	for (($INDEX__for_segment)); do
		for ((INDEX__needle_index = 0; INDEX__needle_index < INDEX__needles_size; ++INDEX__needle_index)); do
			INDEX__needle=\"\${INDEX__needles[\$INDEX__needle_index]}\"
			$INDEX__value_eval_segment
			if [[ \$INDEX__value == "\$INDEX__needle" ]]; then
				$INDEX__matched_eval_segment
			fi
		done
	done
	$INDEX__finale_eval_segment" || return
}

# does the needle exist inside the string/array input?
# has needle / is needle
# __has {<array-var-name>} --- ...<needle>
# @todo support index checks for bash associative arrays
function __has {
	local HAS__needles=() HAS__seek_mode='first' HAS__ignore_case='no' HAS__overlap='no'
	# <only source helper arguments>
	local HAS__item HAS__source_reference='' HAS__inputs HAS__input
	while [[ $# -ne 0 ]]; do
		HAS__item="$1"
		shift
		case "$HAS__item" in
		{*})
			__affirm_value_is_undefined "$HAS__source_reference" 'source reference' || return
			__dereference --origin="${HAS__item#*=}" --name={HAS__source_reference} || return
			;;
		--)
			if [[ -z $HAS__source_reference ]]; then
				# they are inputs
				if [[ $# -eq 1 ]]; then
					# a string input
					# trunk-ignore(shellcheck/SC2034)
					HAS__input="$1"
					HAS__source_reference='HAS__input'
				else
					# an array input
					HAS__inputs+=("$@")
					HAS__source_reference='HAS__inputs'
				fi
			else
				# they are needles
				HAS__needles+=("$@")
			fi
			shift $#
			break
			;;
		# </only source helper arguments>
		--needle=*) HAS__needles+=("${HAS__item#*=}") ;;
		--first | --any) HAS__seek_mode='first' ;;
		--all) HAS__seek_mode='all' ;;
		--ignore-case | --case-insensitive) HAS__ignore_case='yes' ;;
		--overlap | --overlap=yes) HAS__overlap='yes' ;;  # for --all string matches, "aaaa" with needles "aa" and "a" will match "aa" thrice and "a" four times
		--no-overlap | --overlap=no) HAS__overlap='no' ;; # for --all string matches, "aaaa" with needles "aa" and "a" will match "aa" twice and "a" zero times
		--*) __unrecognised_flag "$HAS__item" || return ;;
		*) __unrecognised_argument "$HAS__item" || return ;;
		esac
	done
	__affirm_value_is_defined "$HAS__source_reference" 'source variable reference' || return
	__affirm_length_defined "${#HAS__needles[@]}" 'needle' || return
	# adjust
	# trunk-ignore(shellcheck/SC2034)
	local -i HAS__value_index HAS__needle_index HAS__values_size HAS__needle_size HAS__needles_size="${#HAS__needles[@]}"
	# trunk-ignore(shellcheck/SC2034)
	local HAS__needle HAS__value HAS__needles_found=() HAS__intro_eval_segment HAS__value_eval_segment HAS__matched_eval_segment HAS__finale_eval_segment
	if __is_array "$HAS__source_reference"; then
		HAS__intro_eval_segment="HAS__values_size=\${#${HAS__source_reference}[@]}" || return
		HAS__value_eval_segment="HAS__value=\"\${${HAS__source_reference}[\$HAS__value_index]}\""
	else
		HAS__intro_eval_segment="HAS__values_size=\${#${HAS__source_reference}}" || return
		HAS__value_eval_segment="HAS__needle_size=\${#HAS__needle}; HAS__value=\"\${${HAS__source_reference}:\$HAS__value_index:\$HAS__needle_size}\""
	fi
	if [[ $HAS__seek_mode == 'all' ]]; then
		__array --size="$HAS__needles_size" --fill='no' --target={HAS__needles_found} || return
		HAS__matched_eval_segment='HAS__needles_found[HAS__needle_index]=yes'
		if [[ $HAS__overlap == 'no' ]]; then
			# -1 to offset the upcoming increment from the for loop
			HAS__matched_eval_segment+='; HAS__value_index=$((HAS__value_index + HAS__needle_size - 1)); break'
		fi
		HAS__finale_eval_segment='if [[ ${HAS__needles_found[*]} == *no* ]]; then return 1; fi'
	else
		HAS__matched_eval_segment='return 0'
		HAS__finale_eval_segment="return 1"
	fi
	if [[ $HAS__ignore_case == 'yes' ]]; then
		# convert the needles to lowercase
		for HAS__needle_index in "${!HAS__needles[@]}"; do
			HAS__needle="${HAS__needles[$HAS__needle_index]}"
			HAS__needle="$(__get_lowercase_string "$HAS__needle")" || return
		done
		HAS__value_eval_segment+='; HAS__value="$(__get_lowercase_string "$HAS__value")"'
	fi
	# process
	eval "
	$HAS__intro_eval_segment
	for ((HAS__value_index = 0; HAS__value_index < HAS__values_size; ++HAS__value_index)); do
		for ((HAS__needle_index = 0; HAS__needle_index < HAS__needles_size; ++HAS__needle_index)); do
			HAS__needle=\"\${HAS__needles[\$HAS__needle_index]}\"
			$HAS__value_eval_segment
			if [[ \$HAS__value == "\$HAS__needle" ]]; then
				$HAS__matched_eval_segment
			fi
		done
	done
	$HAS__finale_eval_segment" || return
}

# set the targets to the slice between the start and length indices of the source reference
# negative starts and lengths will be counted from the end of the source reference
# out of bound indices will throw
function __slice {
	local SLICE__indices=() SLICE__keep_before_first=() SLICE__keep_before_last=() SLICE__keep_after_first=() SLICE__keep_after_last=()
	# <single-source helper arguments>
	local SLICE__item SLICE__source_reference='' SLICE__targets=() SLICE__mode='' SLICE__inputs SLICE__input
	while [[ $# -ne 0 ]]; do
		SLICE__item="$1"
		shift
		case "$SLICE__item" in
		--source={*})
			__affirm_value_is_undefined "$SLICE__source_reference" 'source reference' || return
			__dereference --origin="${SLICE__item#*=}" --name={SLICE__source_reference} || return
			;;
		--source+target={*})
			SLICE__item="${SLICE__item#*=}"
			SLICE__targets+=("$SLICE__item")
			__affirm_value_is_undefined "$SLICE__source_reference" 'source reference' || return
			__dereference --origin="$SLICE__item" --name={SLICE__source_reference} || return
			;;
		--targets=*) __dereference --origin="${SLICE__item#*=}" --value={SLICE__targets} || return ;;
		--target=*) SLICE__targets+=("${SLICE__item#*=}") ;;
		--mode=prepend | --mode=append | --mode=overwrite | --mode=)
			__affirm_value_is_undefined "$SLICE__mode" 'write mode' || return
			SLICE__mode="${SLICE__item#*=}"
			;;
		--append | --prepend | --overwrite)
			__affirm_value_is_undefined "$SLICE__mode" 'write mode' || return
			SLICE__mode="${SLICE__item:2}"
			;;
		--)
			if [[ -z $SLICE__source_reference ]]; then
				# they are inputs
				if [[ $# -eq 1 ]]; then
					# a string input
					# trunk-ignore(shellcheck/SC2034)
					SLICE__input="$1"
					SLICE__source_reference='SLICE__input'
				else
					# an array input
					SLICE__inputs+=("$@")
					SLICE__source_reference='SLICE__inputs'
				fi
			else
				# they are indices
				for SLICE__item in "$@"; do
					__affirm_value_is_integer "$SLICE__item" 'index' || return
				done
				SLICE__indices+=("$@")
			fi
			shift $#
			break
			;;
		# </single-source helper arguments>
		[0-9]* | -[0-9]*)
			__affirm_value_is_integer "$SLICE__item" 'index/length' || return
			SLICE__indices+=("$SLICE__item")
			;;
		--keep-before-first=*) SLICE__keep_before_first+=("${SLICE__item#*=}") ;;
		--keep-before-last=*) SLICE__keep_before_last+=("${SLICE__item#*=}") ;;
		--keep-after-first=*) SLICE__keep_after_first+=("${SLICE__item#*=}") ;;
		--keep-after-last=*) SLICE__keep_after_last+=("${SLICE__item#*=}") ;;
		--*) __unrecognised_flag "$SLICE__item" || return ;;
		*) __unrecognised_argument "$SLICE__item" || return ;;
		esac
	done
	# affirm
	__affirm_value_is_defined "$SLICE__source_reference" 'source variable reference' || return
	__affirm_value_is_valid_write_mode "$SLICE__mode" || return
	if __is_zero ${#SLICE__indices[@]} ${#SLICE__keep_before_first[@]} ${#SLICE__keep_before_last[@]} ${#SLICE__keep_after_first[@]} ${#SLICE__keep_after_last[@]}; then
		__print_lines "ERROR: ${FUNCNAME[0]}: No slice arguments provided, at least one of --index, --keep-before-first, --keep-before-last, --keep-after-first, --keep-after-last, must be provided." >&2 || :
		__dump SLICE__indices SLICE__keep_before_first SLICE__keep_before_last SLICE__keep_after_first SLICE__keep_after_last >&2 || :
		return 22 # EINVAL 22 Invalid argument
	fi
	# if indices is odd, then make it to the end
	if __is_odd "${#SLICE__indices[@]}"; then
		SLICE__indices+=(-0) # -0 means to the end
	fi
	# @todo optimise the below with direct substring options if substring
	# before first
	for SLICE__item in "${SLICE__keep_before_first[@]}"; do
		__index --source="{$SLICE__source_reference}" --needle="$SLICE__item" --target={SLICE__item} || return
		SLICE__indices+=(0 "$SLICE__item")
	done
	# before last
	for SLICE__item in "${SLICE__keep_before_last[@]}"; do
		__index --source="{$SLICE__source_reference}" --needle="$SLICE__item" --reverse --target={SLICE__item} || return
		SLICE__indices+=(0 "$SLICE__item")
	done
	# after first
	for SLICE__item in "${SLICE__keep_after_first[@]}"; do
		__index --source="{$SLICE__source_reference}" --needle="$SLICE__item" --target={SLICE__item} || return
		SLICE__indices+=("$((SLICE__item + 1))" -0)
	done
	# after last
	for SLICE__item in "${SLICE__keep_after_last[@]}"; do
		__index --source="{$SLICE__source_reference}" --needle="$SLICE__item" --reverse --target={SLICE__item} || return
		SLICE__indices+=("$((SLICE__item + 1))" -0)
	done
	# indices
	local -i SLICE__left SLICE__right SLICE__size
	# trunk-ignore(shellcheck/SC2034)
	local SLICE__results=() SLICE__eval_left_segment SLICE__eval_right_segment
	if __is_array "$SLICE__source_reference"; then
		eval "SLICE__size=\"\${#${SLICE__source_reference}[@]}\"" || return
		SLICE__eval_left_segment="SLICE__results+=(\"\${${SLICE__source_reference}[@]:SLICE__left}\")"
		SLICE__eval_right_segment="SLICE__results+=(\"\${${SLICE__source_reference}[@]:SLICE__left:SLICE__right}\")"
	else
		eval "SLICE__size=\"\${#${SLICE__source_reference}}\"" || return
		SLICE__eval_left_segment="SLICE__results+=(\"\${${SLICE__source_reference}:SLICE__left}\")"
		SLICE__eval_right_segment="SLICE__results+=(\"\${${SLICE__source_reference}:SLICE__left:SLICE__right}\")"
	fi
	SLICE__negative_size=$((SLICE__size * -1))
	# we guaranteed earlier we have even indices, and instead of for a loop, a shifting while loop is easiest
	set -- "${SLICE__indices[@]}"
	while [[ $# -ne 0 ]]; do
		SLICE__left="$1"
		shift
		SLICE__right="$1" # because we shifted above, it is now $1
		shift
		if [[ $SLICE__left == '-0' ]]; then
			continue # there is nothing to do
		elif [[ $SLICE__left -lt $SLICE__negative_size || $SLICE__left -ge $SLICE__size ]]; then
			__print_lines "ERROR: ${FUNCNAME[0]}: The index $SLICE__left was out of range $SLICE__negative_size (inclusive) to $SLICE__size (exclusive)." >&2 || :
			__dump "{$SLICE__source_reference}" {SLICE__indices} >&2 || :
			return 33 # EDOM 33 Numerical argument out of domain
		fi
		if [[ $SLICE__right == -0 ]]; then
			SLICE__right="$SLICE__size" # -0 means to the end, so we convert it to the size
		elif [[ $SLICE__right -lt 0 ]]; then
			SLICE__right="$((SLICE__size + SLICE__right - SLICE__left))"
		fi
		if [[ $SLICE__right -lt $SLICE__negative_size || $SLICE__right -gt $SLICE__size ]]; then
			__print_lines "ERROR: ${FUNCNAME[0]}: The length $SLICE__right was out of range $SLICE__negative_size (inclusive) to $SLICE__size (inclusive)." >&2 || :
		fi
		# add the results
		if [[ $SLICE__right -eq $SLICE__size ]]; then
			eval "$SLICE__eval_left_segment" || return
		else
			eval "$SLICE__eval_right_segment" || return
		fi
	done
	__to --source={SLICE__results} --mode="$SLICE__mode" --targets={SLICE__targets} || return
}

# split, unlike mapfile and readarray, supports multi-character delimiters, and multiple delimiters
# this is wrong:
# __split --target={arr} --no-zero-length < <(<output-command>)
# __split --target={arr} --no-zero-length <<< "$(<output-command>)"
# __split --target={arr} --no-zero-length < <(<output-command> | tr $'\t ,|' '\n')
# and this is right:
# fodder_to_respect_exit_status="$(<output-command>)"
# __split --target={arr} --no-zero-length --invoke -- <output-command> # this preserves trail
# __split --target={arr} --no-zero-length -- "$fodder_to_respect_exit_status"
# __split --target={arr} --no-zero-length -- "$fodder_to_respect_exit_status"
# __split --target={arr} --delimiters=$'\n\t ,|' --no-zero-length -- "$fodder_to_respect_exit_status"
# use --delimiter='<a multi character delimiter>' to specify a single multi-character delimiter
function __split {
	local SPLIT__character SPLIT__results=() SPLIT__window SPLIT__segment SPLIT__invoke='no' SPLIT__zero_length='yes' SPLIT__delimiters=() SPLIT__delimiter
	local -i SPLIT__last_slice_left_index SPLIT__string_length SPLIT__string_last SPLIT__delimiter_size SPLIT__window_size SPLIT__window_offset SPLIT__character_left_index
	# <single-source helper arguments>
	local SPLIT__item SPLIT__source_reference='' SPLIT__targets=() SPLIT__mode='' SPLIT__input
	while [[ $# -ne 0 ]]; do
		SPLIT__item="$1"
		shift
		case "$SPLIT__item" in
		--source={*})
			__affirm_value_is_undefined "$SPLIT__source_reference" 'source reference' || return
			__dereference --origin="${SPLIT__item#*=}" --name={SPLIT__source_reference} || return
			;;
		--source+target={*})
			SPLIT__item="${SPLIT__item#*=}"
			SPLIT__targets+=("$SPLIT__item")
			__affirm_value_is_undefined "$SPLIT__source_reference" 'source reference' || return
			__dereference --origin="$SPLIT__item" --name={SPLIT__source_reference} || return
			;;
		--targets=*) __dereference --origin="${SPLIT__item#*=}" --value={SPLIT__targets} || return ;;
		--target=*) SPLIT__targets+=("${SPLIT__item#*=}") ;;
		--mode=prepend | --mode=append | --mode=overwrite | --mode=)
			__affirm_value_is_undefined "$SPLIT__mode" 'write mode' || return
			SPLIT__mode="${SPLIT__item#*=}"
			;;
		--append | --prepend | --overwrite)
			__affirm_value_is_undefined "$SPLIT__mode" 'write mode' || return
			SPLIT__mode="${SPLIT__item:2}"
			;;
		--)
			if [[ $SPLIT__invoke == 'yes' ]]; then
				__affirm_value_is_undefined "$SPLIT__source_reference" 'source reference' || return
				local SPLIT__fodder_to_respect_exit_status
				__do --redirect-stdout={SPLIT__fodder_to_respect_exit_status} -- "$@"
				SPLIT__input="$SPLIT__fodder_to_respect_exit_status"
				SPLIT__source_reference='SPLIT__input'
			elif [[ $SPLIT__invoke == 'try' ]]; then
				__affirm_value_is_undefined "$SPLIT__source_reference" 'source reference' || return
				local SPLIT__fodder_to_respect_exit_status
				__do --discard-status --redirect-stdout={SPLIT__fodder_to_respect_exit_status} -- "$@"
				SPLIT__input="$SPLIT__fodder_to_respect_exit_status"
				SPLIT__source_reference='SPLIT__input'
			elif [[ -z $SPLIT__source_reference ]]; then
				# they are inputs
				if [[ $# -eq 1 ]]; then
					# a string input
					# trunk-ignore(shellcheck/SC2034)
					__affirm_value_is_undefined "$SPLIT__source_reference" 'source reference' || return
					SPLIT__input="$1"
					SPLIT__source_reference='SPLIT__input'
				else
					__print_lines "ERROR: ${FUNCNAME[0]}: Multiple inputs are not supported, as the source for __split must be a string." >&2 || :
					return 22 # EINVAL 22 Invalid argument
				fi
			else
				# they are delimiters
				SPLIT__delimiters+=("$@")
			fi
			shift $#
			break
			;;
		# </single-source helper arguments>
		'--no-zero-length') SPLIT__zero_length='no' ;;
		'--keep-zero-length') : ;; # no-op as already the case
		'--invoke=try') SPLIT__invoke='try' ;;
		'--invoke') SPLIT__invoke='yes' ;;
		'--delimiter='*) SPLIT__delimiters+=("${SPLIT__item#*=}") ;;
		'--delimiters='*)
			SPLIT__item="${SPLIT__item#*=}"
			for ((SPLIT__character_left_index = 0, SPLIT__string_length = "${#SPLIT__item}"; SPLIT__character_left_index < SPLIT__string_length; SPLIT__character_left_index++)); do
				SPLIT__character="${SPLIT__item:SPLIT__character_left_index:1}"
				SPLIT__delimiters+=("$SPLIT__character")
			done
			;;
		--*) __unrecognised_flag "$SPLIT__item" || return ;;
		*) __unrecognised_argument "$SPLIT__item" || return ;;
		esac
	done
	# read everything from stdin
	if [[ -z $SPLIT__source_reference ]]; then
		local SPLIT__stdin='' SPLIT__reply
		while LC_ALL=C IFS= read -rd '' SPLIT__reply || [[ -n $SPLIT__reply ]]; do
			if [[ -n $SPLIT__stdin ]]; then
				SPLIT__stdin+=$'\n'
			fi
			SPLIT__stdin+="$SPLIT__reply"
		done
		SPLIT__source_reference='SPLIT__stdin'
	fi
	# affirmations
	__affirm_value_is_defined "$SPLIT__source_reference" 'source variable reference to a string' || return
	__affirm_value_is_valid_write_mode "$SPLIT__mode" || return
	if [[ ${#SPLIT__delimiters[@]} -eq 0 ]]; then
		SPLIT__delimiters+=($'\n')
	fi
	# process
	eval "SPLIT__input=\"\${$SPLIT__source_reference}\"" || return
	# check if we even apply
	if [[ -z $SPLIT__input ]]; then
		# the item is empty, add it if desired
		if [[ $SPLIT__zero_length == 'yes' ]]; then
			__to --source={SPLIT__input} --mode="$SPLIT__mode" --targets={SPLIT__targets} || return
		fi
		# done
		return 0
	fi
	# reset the window for each argument
	SPLIT__window=''
	SPLIT__last_slice_left_index=-1
	SPLIT__string_length=${#SPLIT__input}
	SPLIT__string_last=$((SPLIT__string_length - 1))
	# process the argument
	for ((SPLIT__character_left_index = 0; SPLIT__character_left_index < SPLIT__string_length; SPLIT__character_left_index++)); do
		# add the character to the window, no need for string __slice as it is a simple slice
		SPLIT__character="${SPLIT__input:SPLIT__character_left_index:1}"
		SPLIT__window+="$SPLIT__character"
		# cycle through the delimiters
		for SPLIT__delimiter in "${SPLIT__delimiters[@]}"; do
			# does the window end with our delimiter?
			if [[ $SPLIT__window == *"$SPLIT__delimiter" ]]; then
				# remove the delimiter
				SPLIT__window_size=${#SPLIT__window}
				SPLIT__delimiter_size=${#SPLIT__delimiter}
				SPLIT__window_offset=$((SPLIT__window_size - SPLIT__delimiter_size))
				SPLIT__segment="${SPLIT__window:0:SPLIT__window_offset}"
				# do we want to add it?
				if [[ $SPLIT__zero_length == 'yes' || -n $SPLIT__segment ]]; then
					SPLIT__results+=("$SPLIT__segment")
				fi
				# reset the window so characters can be added back to it for the new slice
				SPLIT__window=''
				# note the last slice, as we know whether or not we need to add a trailing slice
				SPLIT__last_slice_left_index="$SPLIT__character_left_index"
			fi
		done
	done
	# check how to handle trailing slice
	if [[ $SPLIT__last_slice_left_index -eq -1 ]]; then
		# the delimiter was not found, so add the whole string
		if [[ $SPLIT__zero_length == 'yes' || -n $SPLIT__window ]]; then
			SPLIT__results+=("$SPLIT__input")
		fi
	elif [[ $SPLIT__last_slice_left_index -ne $SPLIT__string_last ]]; then
		# the delimiter was not the last character, so add the pending slice
		if [[ $SPLIT__zero_length == 'yes' || -n $SPLIT__window ]]; then
			SPLIT__results+=("$SPLIT__window")
		fi
	elif [[ $SPLIT__last_slice_left_index -eq $SPLIT__string_last ]]; then
		# delimiter was the last character, so add a right-side slice, if zero-length is allowed
		if [[ $SPLIT__zero_length == 'yes' ]]; then
			SPLIT__results+=('')
		fi
	fi
	__to --source={SPLIT__results} --mode="$SPLIT__mode" --targets={SPLIT__targets} || return
}

# __evict {source_and_target_array} -- ...<value-to-remove>
# __evict {source_array} {target_array} -- ...<value-to-remove>
function __evict {
	local EVICT__indices=() EVICT__values=() EVICT__prefixes=() EVICT__suffixes=() EVICT__patterns=() EVICT__globs=() EVICT__keep_before_first=() EVICT__keep_before_last=() EVICT__keep_after_first=() EVICT__keep_after_last=() EVICT__optional='no'
	# <single-source helper arguments>
	local EVICT__item EVICT__source_reference='' EVICT__targets=() EVICT__mode='' EVICT__inputs EVICT__input
	while [[ $# -ne 0 ]]; do
		EVICT__item="$1"
		shift
		case "$EVICT__item" in
		--source={*})
			__affirm_value_is_undefined "$EVICT__source_reference" 'source reference' || return
			__dereference --origin="${EVICT__item#*=}" --name={EVICT__source_reference} || return
			;;
		--source+target={*})
			EVICT__item="${EVICT__item#*=}"
			EVICT__targets+=("$EVICT__item")
			__affirm_value_is_undefined "$EVICT__source_reference" 'source reference' || return
			__dereference --origin="$EVICT__item" --name={EVICT__source_reference} || return
			;;
		--targets=*) __dereference --origin="${EVICT__item#*=}" --value={EVICT__targets} || return ;;
		--target=*) EVICT__targets+=("${EVICT__item#*=}") ;;
		--mode=prepend | --mode=append | --mode=overwrite | --mode=)
			__affirm_value_is_undefined "$EVICT__mode" 'write mode' || return
			EVICT__mode="${EVICT__item#*=}"
			;;
		--append | --prepend | --overwrite)
			__affirm_value_is_undefined "$EVICT__mode" 'write mode' || return
			EVICT__mode="${EVICT__item:2}"
			;;
		--)
			if [[ -z $EVICT__source_reference ]]; then
				# they are inputs
				if [[ $# -eq 1 ]]; then
					# a string input
					# trunk-ignore(shellcheck/SC2034)
					EVICT__input="$1"
					EVICT__source_reference='EVICT__input'
				else
					# an array input
					EVICT__inputs+=("$@")
					EVICT__source_reference='EVICT__inputs'
				fi
			else
				# they are values
				EVICT__values+=("$@")
			fi
			shift $#
			break
			;;
		# </single-source helper arguments>
		--index=*)
			EVICT__item="${EVICT__item#*=}"
			__affirm_value_is_integer "$EVICT__item" 'index/length' || return
			EVICT__indices+=("$EVICT__item")
			;;
		--value=*) EVICT__values+=("${EVICT__item#*=}") ;;
		--prefix=*) EVICT__prefixes+=("${EVICT__item#*=}") ;;
		--suffix=*) EVICT__suffixes+=("${EVICT__item#*=}") ;;
		--pattern=*) EVICT__patterns+=("${EVICT__item#*=}") ;;
		--glob=*) EVICT__globs+=("${EVICT__item#*=}") ;;
		--keep-before-first=*) EVICT__keep_before_first+=("${EVICT__item#*=}") ;;
		--keep-before-last=*) EVICT__keep_before_last+=("${EVICT__item#*=}") ;;
		--keep-after-first=*) EVICT__keep_after_first+=("${EVICT__item#*=}") ;;
		--keep-after-last=*) EVICT__keep_after_last+=("${EVICT__item#*=}") ;;
		--optional) EVICT__optional='yes' ;; # if there was no matches, then do not error
		--*) __unrecognised_flag "$EVICT__item" || return ;;
		*) __unrecognised_argument "$EVICT__item" || return ;;
		esac
	done
	# affirm
	__affirm_value_is_defined "$EVICT__source_reference" 'source variable reference' || return
	__affirm_value_is_valid_write_mode "$EVICT__mode" || return
	if __is_zero ${#EVICT__indices[@]} ${#EVICT__values[@]} ${#EVICT__prefixes[@]} ${#EVICT__suffixes[@]} ${#EVICT__patterns[@]} ${#EVICT__globs[@]} ${#EVICT__keep_before_first[@]} ${#EVICT__keep_before_last[@]} ${#EVICT__keep_after_first[@]} ${#EVICT__keep_after_last[@]}; then
		__print_lines "ERROR: ${FUNCNAME[0]}: No evict arguments provided, at least one of --index, --value, --prefix, --suffix, --pattern, --glob, --keep-before-first, --keep-before-last, --keep-after-first, --keep-after-last, must be provided." >&2 || :
		__dump EVICT__indices EVICT__values EVICT__prefixes EVICT__suffixes EVICT__patterns EVICT__keep_before_first EVICT__keep_before_last EVICT__keep_after_first EVICT__keep_after_last >&2 || :
		return 22 # EINVAL 22 Invalid argument
	fi
	# build our list of excluded indices
	if __is_array "$EVICT__source_reference"; then
		local EVICT__map=() EVICT__evicted='no'
		# indices
		for EVICT__item in "${EVICT__indices[@]}"; do
			EVICT__map[EVICT__item]='evict'
		done
		# values
		local EVICT__source_values EVICT__results=()
		local -i EVICT__source_index EVICT__source_size
		eval "EVICT__source_values=(\"\${${EVICT__source_reference}[@]}\")" || return
		EVICT__source_size=${#EVICT__source_values[@]}
		for ((EVICT__source_index = 0; EVICT__source_index < EVICT__source_size; ++EVICT__source_index)); do
			EVICT__source_value="${EVICT__source_values[EVICT__source_index]}"
			for EVICT__item in "${EVICT__values[@]}"; do
				if [[ $EVICT__source_value == "$EVICT__item" ]]; then
					EVICT__evicted=yes
					EVICT__map[EVICT__source_index]='evict'
				fi
			done
			for EVICT__item in "${EVICT__prefixes[@]}"; do
				if [[ $EVICT__source_value == "$EVICT__item"* ]]; then
					EVICT__evicted=yes
					EVICT__map[EVICT__source_index]='evict'
				fi
			done
			for EVICT__item in "${EVICT__suffixes[@]}"; do
				if [[ $EVICT__source_value == *"$EVICT__item" ]]; then
					EVICT__evicted=yes
					EVICT__map[EVICT__source_index]='evict'
				fi
			done
			for EVICT__item in "${EVICT__patterns[@]}"; do
				if [[ $EVICT__source_value =~ $EVICT__item ]]; then
					EVICT__evicted=yes
					EVICT__map[EVICT__source_index]='evict'
				fi
			done
			for EVICT__item in "${EVICT__globs[@]}"; do
				# trunk-ignore(shellcheck/SC2053)
				if [[ $EVICT__source_value == $EVICT__item ]]; then
					EVICT__evicted=yes
					EVICT__map[EVICT__source_index]='evict'
				fi
			done

		done
		# before first
		for EVICT__item in "${EVICT__keep_before_first[@]}"; do
			__index --source="{$EVICT__source_reference}" --needle="$EVICT__item" --target={EVICT__item} || return
			if [[ -n $EVICT__item ]]; then
				for ((EVICT__source_index = EVICT__item; EVICT__source_index < EVICT__source_size; ++EVICT__source_index)); do
					EVICT__evicted='yes'
					EVICT__map[EVICT__source_index]='evict'
				done
			fi
		done
		# before last
		for EVICT__item in "${EVICT__keep_before_last[@]}"; do
			__index --source="{$EVICT__source_reference}" --needle="$EVICT__item" --reverse --target={EVICT__item} || return
			if [[ -n $EVICT__item ]]; then
				for ((EVICT__source_index = EVICT__item; EVICT__source_index < EVICT__source_size; ++EVICT__source_index)); do
					EVICT__evicted='yes'
					EVICT__map[EVICT__source_index]='evict'
				done
			fi
		done
		# after first
		for EVICT__item in "${EVICT__keep_after_first[@]}"; do
			__index --source="{$EVICT__source_reference}" --needle="$EVICT__item" --target={EVICT__item} || return
			if [[ -n $EVICT__item ]]; then
				for ((EVICT__source_index = 0; EVICT__source_index <= EVICT__item; ++EVICT__source_index)); do
					EVICT__evicted='yes'
					EVICT__map[EVICT__source_index]='evict'
				done
			fi
		done
		# after last
		for EVICT__item in "${EVICT__keep_after_last[@]}"; do
			__index --source="{$EVICT__source_reference}" --needle="$EVICT__item" --reverse --target={EVICT__item} || return
			if [[ -n $EVICT__item ]]; then
				for ((EVICT__source_index = 0; EVICT__source_index <= EVICT__item; ++EVICT__source_index)); do
					EVICT__evicted='yes'
					EVICT__map[EVICT__source_index]='evict'
				done
			fi
		done
		# check
		if [[ $EVICT__evicted == 'no' && $EVICT__optional == 'no' ]]; then
			__print_lines "ERROR: ${FUNCNAME[0]}: No values were evicted from the source array." >&2 || :
			return 33 # EDOM 33 Numerical argument out of domain
		fi
		# compile result
		for ((EVICT__source_index = 0; EVICT__source_index < EVICT__source_size; ++EVICT__source_index)); do
			if [[ ${EVICT__map[$EVICT__source_index]-} != 'evict' ]]; then
				EVICT__results+=("${EVICT__source_values[$EVICT__source_index]}")
			fi
		done
		__to --source={EVICT__results} --mode="$EVICT__mode" --targets={EVICT__targets} || return
	else
		local EVICT__source_value EVICT__source_original
		eval "EVICT__source_value=\"\${${EVICT__source_reference}}\"" || return
		EVICT__source_original="$EVICT__source_value"
		if [[ ${#EVICT__indices[@]} -ne 0 ]]; then
			__print "ERROR: ${FUNCNAME[0]}: The source variable is not an array, so --index cannot be used." >&2 || :
			return 22 # EINVAL 22 Invalid argument
		fi
		for EVICT__item in "${EVICT__source_values[@]}"; do
			EVICT__source_value="${EVICT__source_value//"$EVICT__item"/}"
		done
		for EVICT__item in "${EVICT__prefixes[@]}"; do
			if [[ $EVICT__source_value == "$EVICT__item"* ]]; then
				EVICT__source_value="${EVICT__source_value#"$EVICT__item"}"
			fi
		done
		for EVICT__item in "${EVICT__suffixes[@]}"; do
			if [[ $EVICT__source_value == *"$EVICT__item" ]]; then
				EVICT__source_value="${EVICT__source_value%"$EVICT__item"}"
			fi
		done
		for EVICT__item in "${EVICT__patterns[@]}"; do
			EVICT__source_value="${EVICT__source_value//$EVICT__item/}"
		done
		if [[ ${#EVICT__globs[@]} -ne 0 ]]; then
			__print "ERROR: ${FUNCNAME[0]}: The source variable is not an array, so --glob cannot be used." >&2 || :
			return 22 # EINVAL 22 Invalid argument
		fi
		for EVICT__item in "${EVICT__keep_before_first[@]}"; do
			EVICT__source_value="${EVICT__source_value%%"$EVICT__item"*}"
		done
		for EVICT__item in "${EVICT__keep_before_last[@]}"; do
			EVICT__source_value="${EVICT__source_value%"$EVICT__item"*}"
		done
		for EVICT__item in "${EVICT__keep_after_first[@]}"; do
			EVICT__source_value="${EVICT__source_value#*"$EVICT__item"}"
		done
		for EVICT__item in "${EVICT__keep_after_last[@]}"; do
			EVICT__source_value="${EVICT__source_value##*"$EVICT__item"}"
		done
		if [[ $EVICT__optional == 'no' && $EVICT__source_value == "$EVICT__source_original" ]]; then
			__print_lines "ERROR: ${FUNCNAME[0]}: No values were evicted from the source variable." >&2 || :
			return 33 # EDOM 33 Numerical argument out of domain
		fi
		__to --source={EVICT__source_value} --mode="$EVICT__mode" --targets={EVICT__targets} || return
	fi
}

# __unique {<source-array-var-name>}
# __unique {...<source-array-var-name>} <target-array-var-name>
function __unique {
	# <multi-source helper arguments>
	local UNIQUE__item UNIQUE__sources=() UNIQUE__targets=() UNIQUE__mode='' UNIQUE__inputs
	while [[ $# -ne 0 ]]; do
		UNIQUE__item="$1"
		shift
		case "$UNIQUE__item" in
		--source={*})
			__dereference --origin="${UNIQUE__item#*=}" --name={UNIQUE__sources} || return
			;;
		--source+target={*})
			UNIQUE__item="${UNIQUE__item#*=}"
			UNIQUE__targets+=("$UNIQUE__item") # keep squigglies
			__dereference --origin="$UNIQUE__item" --name={UNIQUE__item} || return
			UNIQUE__sources+=("$UNIQUE__item")
			;;
		--targets=*) __dereference --origin="${UNIQUE__item#*=}" --value={UNIQUE__targets} || return ;;
		--target=*) UNIQUE__targets+=("${UNIQUE__item#*=}") ;;
		--mode=prepend | --mode=append | --mode=overwrite | --mode=)
			__affirm_value_is_undefined "$UNIQUE__mode" 'write mode' || return
			UNIQUE__mode="${UNIQUE__item#*=}"
			;;
		--append | --prepend | --overwrite)
			__affirm_value_is_undefined "$UNIQUE__mode" 'write mode' || return
			UNIQUE__mode="${UNIQUE__item:2}"
			;;
		--)
			# an array input
			UNIQUE__inputs+=("$@")
			UNIQUE__sources+=('UNIQUE__inputs')
			shift $#
			break
			;;
		# </multi-source helper arguments>
		--*) __unrecognised_flag "$UNIQUE__item" || return ;;
		*) __unrecognised_argument "$UNIQUE__item" || return ;;
		esac
	done
	__affirm_length_defined "${#UNIQUE__sources[@]}" 'source reference' || return
	__affirm_value_is_valid_write_mode "$UNIQUE__mode" || return
	# process
	local UNIQUE__source UNIQUE__values=() UNIQUE__value UNIQUE__results=()
	for UNIQUE__source in "${UNIQUE__sources[@]}"; do
		__affirm_variable_is_array "$UNIQUE__source" || return
		eval "UNIQUE__values=(\"\${${UNIQUE__source}[@]}\")" || return
		for UNIQUE__value in "${UNIQUE__values[@]}"; do
			# if the value already exists in the results, skip it
			if __has {UNIQUE__results} -- "$UNIQUE__value"; then
				continue
			fi
			# the value is new to the results, so add it
			UNIQUE__results+=("$UNIQUE__value")
		done
	done
	__to --source={UNIQUE__results} --mode="$UNIQUE__mode" --targets={UNIQUE__targets} || return
}

# join by the delimiter
# __join <delimiter> -- ...<element>
function __join {
	local JOIN__delimiter=$'\n'
	# <multi-source helper arguments>
	local JOIN__item JOIN__sources=() JOIN__targets=() JOIN__mode='' JOIN__inputs
	while [[ $# -ne 0 ]]; do
		JOIN__item="$1"
		shift
		case "$JOIN__item" in
		--source={*})
			__dereference --origin="${JOIN__item#*=}" --name={JOIN__sources} || return
			;;
		--source+target={*})
			JOIN__item="${JOIN__item#*=}"
			JOIN__targets+=("$JOIN__item")
			__dereference --origin="$JOIN__item" --name={JOIN__item} || return
			JOIN__sources+=("$JOIN__item")
			;;
		--targets=*) __dereference --origin="${JOIN__item#*=}" --value={JOIN__targets} || return ;;
		--target=*) JOIN__targets+=("${JOIN__item#*=}") ;;
		--mode=prepend | --mode=append | --mode=overwrite | --mode=)
			__affirm_value_is_undefined "$JOIN__mode" 'write mode' || return
			JOIN__mode="${JOIN__item#*=}"
			;;
		--append | --prepend | --overwrite)
			__affirm_value_is_undefined "$JOIN__mode" 'write mode' || return
			JOIN__mode="${JOIN__item:2}"
			;;
		--)
			# an array input
			JOIN__inputs+=("$@")
			JOIN__sources+=('JOIN__inputs')
			shift $#
			break
			;;
		# </multi-source helper arguments>
		--delimiter=*) JOIN__delimiter="${JOIN__item#*=}" ;;
		--*) __unrecognised_flag "$JOIN__item" || return ;;
		*) __unrecognised_argument "$JOIN__item" || return ;;
		esac
	done
	__affirm_length_defined "${#JOIN__sources[@]}" 'source reference' || return
	__affirm_value_is_valid_write_mode "$JOIN__mode" || return
	# process
	local JOIN__source JOIN__values=() JOIN__size JOIN__last JOIN__index JOIN__result=''
	for JOIN__source in "${JOIN__sources[@]}"; do
		__affirm_variable_is_array "$JOIN__source" || return
		eval "JOIN__values=(\"\${${JOIN__source}[@]}\")" || return
		JOIN__size=${#JOIN__values[@]}
		JOIN__last=$((JOIN__size - 1))
		for ((JOIN__index = 0; JOIN__index < JOIN__last; ++JOIN__index)); do
			JOIN__result+="${JOIN__values[JOIN__index]}$JOIN__delimiter"
		done
		JOIN__result+="${JOIN__values[JOIN__index]}"
	done
	__to --source={JOIN__result} --mode="$JOIN__mode" --targets={JOIN__targets} || return
}

# push: add the last elements
# function __append { ... }
# just do: array+=("$@")

# unshift: add the first elements
# function __prepend { ... }
# just do: array=("$@" "${array[@]}")

# pop: remove the last elements
# function __remove_last { ... }
# just do: __slice {array} 0 -1

# shift: remove the first elements
# function __remove_first { ... }
# just do: __slice {array} 1

# complement and intersect prototype also available at: https://gist.github.com/balupton/80d27cf1a9e193f8247ee4baa2ad8566

# __trim turns the following:
# ```
# # trim leading and trailing whitespace
# while [[ $test == ' '* ]]; do
# 	test="${test:1}"
# done
# while [[ $test == *' ' ]]; do
# 	__slice --source+target={test} -- 0 -1
# done
# ```
# ```
# # trim leading and trailing whitespace and quotes
# while [[ $value =~ ^[\ \'\"] ]]; do
# 	value="${value:1}"
# done
# while [[ $value =~ [\ \'\"]$ ]]; do
# 	__slice --source+target={value} -- -1 || return
# done
# ```
# into the following:
# ```
# __trim --source+target={test} --leading-delimiters=' ' --trailing-delimiters=' '
# ```
# ```
# __trim --source+target={value} --leading-delimiters=' \'\"' --trailing-delimiters=' \'\"'
# ```
