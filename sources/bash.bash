#!/usr/bin/env bash

# For bash version compatibility and changes, see:
# See <https://github.com/bevry/dorothy/blob/master/docs/bash/versions.md> for documentation about significant changes between bash versions.
# See <https://git.savannah.gnu.org/cgit/bash.git/tree/CHANGES> <https://tiswww.case.edu/php/chet/bash/CHANGES> <https://github.com/bminor/bash/blob/master/CHANGES> for documentation on changes from bash v2 and above.

# For bash configuration options, see:
# https://www.gnu.org/software/bash/manual/bash.html#The-Set-Builtin
# https://www.gnu.org/software/bash/manual/bash.html#The-Shopt-Builtin

# Note that [&>] is available to all bash versions, however [&>>] is not, they are different.

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
		printf '\m'
	else
		printf '%s\n' "${values[@]}"
	fi
}

# =============================================================================
# Helpers for common tasks

# see [commands/is-brew] for details
# workaround for Dorothy's [brew] helper
function __is_brew {
	[[ -n ${HOMEBREW_PREFIX-} && -x "${HOMEBREW_PREFIX-}/bin/brew" ]]
	return
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

# see [commands/sudo-helper] for details
function __try_sudo {
	# trim -- prefix
	if [[ ${1-} == '--' ]]; then
		shift
	fi
	# forward to sudo-helper if it exists, as it is more detailed
	if __command_exists -- sudo-helper; then
		sudo-helper -- "$@"
		return
	elif __command_exists -- sudo; then
		# check if password is required
		if ! sudo --non-interactive true &>/dev/null; then
			# password is required, let the user know what they are being prompted for
			__print_lines 'Your sudo/root/login password is required to execute the command:' >/dev/stderr
			__print_lines "sudo $*" >/dev/stderr
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
		mkdir -p "${missing[@]}" || status=$?
	fi
	return "$status"
}

# performantly make directories with sudo
function __sudo_mkdirp {
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
		__try_sudo -- mkdir -p "${missing[@]}" || status=$?
	fi
	return "$status"
}

# bash < 4.2 doesn't support negative lengths, bash >= 4.2 supports negative start indexes however it requires a preceding space or wrapped parenthesis if done directly: ${var: -1} or ${var:(-1)}
# the bash >= 4.2 behaviour returns empty string if negative start index is out of bounds, rather than the entire string, which is unintuitive: v=12345; s=-6; echo "${v:s}"
# function __substr_native {
# 	local string="$1" start="${2:-0}" length="${3-}"
# 	if [[ -n "$length" ]]; then
# 		__print_lines "${string:start:length}"
# 	elif [[ -n "$start" ]]; then
# 		__print_lines "${string:start}"
# 	else
# 		__print_lines "$string"
# 	fi
# }
function __substr {
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

# replace shapeshifting ANSI Escape Codes with newlines
function __escape_shapeshifting {
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
		input="${input//[[:cntrl:]][\]\`\^\\78M]/$'\n'}"
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
		trimmed="$(__escape_shapeshifting -- "$input")"
		if [[ $input != "$trimmed" ]]; then
			return 0
		fi
	done
	return 1
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
	IFS=. read -r BASH_VERSION_MAJOR BASH_VERSION_MINOR BASH_VERSION_PATCH <<<"${BASH_VERSION%%(*}"
	BASH_VERSION_CURRENT="${BASH_VERSION_MAJOR}.${BASH_VERSION_MINOR}.${BASH_VERSION_PATCH}"
	# trunk-ignore(shellcheck/SC2034)
	BASH_VERSION_LATEST='5.2.37' # https://ftp.gnu.org/gnu/bash/?C=M;O=D
	# any v5 version is supported by dorothy
	if [[ $BASH_VERSION_MAJOR -eq 5 ]]; then
		IS_BASH_VERSION_OUTDATED='no'
		function __require_upgraded_bash {
			:
		}
	else
		IS_BASH_VERSION_OUTDATED='yes'
		function __require_upgraded_bash {
			echo-style \
				--code="$0" ' ' --error='is incompatible with' ' ' --code="bash $BASH_VERSION" $'\n' \
				'Run ' --code='setup-util-bash' ' to upgrade capabilities, then run the prior command again.' >/dev/stderr || return $?
			return 45 # ENOTSUP 45 Operation not supported
		}
	fi
fi

# =============================================================================
# Configure bash for Dorothy best practices.
#
# __require_lastpipe -- if lastpipe not supported, fail.
# eval_capture -- capture or ignore exit status, without disabling errexit, and without a subshell.
# __require_globstar -- if globstar not supported, fail.
# __require_extglob -- if extglob not supported, fail.

# Disable completion (not needed in scripts)
# bash v2: progcomp: If set, the programmable completion facilities (see Programmable Completion) are enabled. This option is enabled by default.
shopt -u progcomp

# Promote the cleanup of nested commands if its login shell terminates.
# bash v2: huponexit: If set, Bash will send SIGHUP to all jobs when an interactive login shell exits (see Signals).
shopt -s huponexit

# Enable [cmd | read -r var] usage.
# bash v4.2:    lastpipe    If set, and job control is not active, the shell runs the last command of a pipeline not executed in the background in the current shell environment.
if shopt -s lastpipe 2>/dev/null; then
	function __require_lastpipe {
		:
	}
else
	function __require_lastpipe {
		echo-style --error='Missing lastpipe support:' >/dev/stderr || return $?
		__require_upgraded_bash
	}
fi

# Disable functrace by default, as it causes unexpected behaviour when you know what you are doing.
# bash v3:  -T  functrace   DEBUG and RETURN traps get inherited to nested commands.
set +T

# Ensure errors can be captured.
# bash v3:  -E  errtrace    ERR traps get inherited to nested commands.us of the last command to exit with a non-zero status, or zero if no command exited with a non-zero status
# bash v1:  -e  errexit     Return failure immediately upon non-conditional commands.
# bash v1:  -u  nounset     Return failure immediately when accessing an unset variable.
# bash v3:  -o  pipefail    The return value of a pipeline is the stat
# bash v4.4: inherit_errexit: Subshells inherit errexit.
# Ensure subshells also get the settings
set -Eeuo pipefail
shopt -s inherit_errexit 2>/dev/null || :
function eval_capture {
	# @todo consider supporting this:
	# eval_capture --if command_exists grealpath --then gnu_realpath=grealpath --elif command_exists realpath --and is_linux --then gnu_realpath=realpath

	# Fetch (if supplied) the variables that will store the command exit status, the stdout output, the stderr output, and/or the stdout+stderr output
	# trunk-ignore(shellcheck/SC2034)
	local item cmd=() exit_status_local exit_status_variable='exit_status_local' stdout_variable='' stderr_variable='' output_variable='' stdout_pipe='/dev/stdout' stderr_pipe='/dev/stderr'
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
				Licensed under the CC BY-SA 4.0 (https://creativecommons.org/licenses/by-sa/4.0/)
				For more information: https://github.com/bevry/dorothy/blob/master/docs/bash/errors.md

				USAGE:
				local status=0 stdout='' stderr='' output=''
				eval_capture [--statusvar=status] [--stdoutvar=stdout] [--stderrvar=stderr] [--outputvar=output] [--stdoutpipe=/dev/stdout] [--stderrpipe=/dev/stderr] [--outputpipe=...] [--no-stdout] [--no-stderr] [--no-output] [--] cmd ...

				QUIRKS:
				Using --stdoutvar will set --stdoutpipe=/dev/null
				Using --stderrvar will set --stderrpipe=/dev/null
				Using --outputvar will set --stdoutpipe=/dev/null --stderrpipe=/dev/null

				WARNING:
				If [eval_capture] triggers something that still does function invocation via [if], [&&], [||], or [!], then errexit will still be disabled for that invocation.
				This is a limitation of bash, with no workaround (at least at the time of bash v5.2).
				Refer to https://github.com/bevry/dorothy/blob/master/docs/bash/errors.md for guidance.
			EOF
			return 22 # EINVAL 22 Invalid argument
			;;
		'--statusvar='* | '--status-var='*)
			exit_status_variable="${item#*=}"
			;;
		'--stdoutvar='* | '--stdout-var='*)
			stdout_variable="${item#*=}"
			stdout_pipe='/dev/null'
			;;
		'--stderrvar='* | '--stderr-var='*)
			stderr_variable="${item#*=}"
			stderr_pipe='/dev/null'
			;;
		'--outputvar='* | '--output-var='*)
			output_variable="${item#*=}"
			stdout_pipe='/dev/null'
			stderr_pipe='/dev/null'
			;;
		'--no-stdout' | '--ignore-stdout' | '--stdout=no')
			stdout_pipe='/dev/null'
			;;
		'--no-stderr' | '--ignore-stderr' | '--stderr=no')
			stderr_pipe='/dev/null'
			;;
		'--no-output' | '--ignore-output' | '--output=no')
			stdout_pipe='/dev/null'
			stderr_pipe='/dev/null'
			;;
		'--stdoutpipe='* | '--stdout-pipe='*)
			stdout_pipe="${item#*=}"
			;;
		'--stderrpipe='* | '--stderr-pipe='*)
			stderr_pipe="${item#*=}"
			;;
		'--outputpipe='* | '--output-pipe='*)
			stdout_pipe="${item#*=}"
			stderr_pipe="$stdout_pipe"
			;;
		'--')
			cmd+=("$@")
			shift $#
			break
			;;
		'-'*)
			# __print_line "ERROR: $0: ${FUNCNAME[0]}: $LINENO: An unrecognised flag was provided: $item" >/dev/stderr
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

	# prepare
	EVAL_CAPTURE_COUNT="${EVAL_CAPTURE_COUNT:-0}"
	local EVAL_CAPTURE_STATUS=
	local EVAL_CAPTURE_CONTEXT="$RANDOM"
	# local EVAL_CAPTURE_COMMAND="${cmd[*]}"
	local EVAL_CAPTURE_SUBSHELL="${BASH_SUBSHELL-}"
	local temp_directory="${XDG_CACHE_HOME:-"$HOME/.cache"}/dorothy/eval-capture" # mktemp requires -s checks, as it actually makes the files, this doesn't make the files
	local status_temp_file="$temp_directory/$EVAL_CAPTURE_CONTEXT.status" stderr_temp_file='' stdout_temp_file='' output_temp_file=''
	__mkdirp "$temp_directory"
	function eval_capture_wrapper_trap {
		# trunk-ignore(shellcheck/SC2034)
		local trap_status="$1" trap_fn="$2" trap_cmd="$3" trap_subshell="$4" trap_context="$5"
		# __print_lines "TRAP: [$trap_status] fn=[$trap_fn] cmd=[$trap_cmd] subshell=[$trap_subshell] context=[$trap_context]" >/dev/tty
		# __print_lines "TRAP: [$EVAL_CAPTURE_STATUS]/[$trap_status] -=[$-] fn=[$trap_fn] cmd=[$EVAL_CAPTURE_COMMAND]/[$trap_cmd] subshell=[$EVAL_CAPTURE_SUBSHELL]/[$trap_subshell] context=[$EVAL_CAPTURE_CONTEXT]/[$trap_context]" >/dev/tty
		if [[ $EVAL_CAPTURE_CONTEXT == "$trap_context" ]]; then
			if [[ $EVAL_CAPTURE_SUBSHELL == "$trap_subshell" || $trap_fn == 'eval_capture_wrapper' ]]; then
				# __print_lines "STORE" >/dev/tty
				EVAL_CAPTURE_STATUS="$trap_status"
				return 0
			elif [[ $IS_BASH_VERSION_OUTDATED == 'yes' ]]; then
				# __print_lines "SAVE" >/dev/tty
				# __print_lines "$trap_status" >"$status_temp_file"
				return "$trap_status"
			fi
		fi
		# __print_lines "ERR" >/dev/tty
		return "$trap_status"
	}

	# store preliminary values, and prep the temporary files
	if [[ -n $stdout_variable ]]; then
		eval "${stdout_variable}=''"
		stdout_temp_file="$temp_directory/$EVAL_CAPTURE_CONTEXT.stdout"
	fi
	if [[ -n $stderr_variable ]]; then
		eval "${stderr_variable}=''"
		stderr_temp_file="$temp_directory/$EVAL_CAPTURE_CONTEXT.stderr"
	fi
	if [[ -n $output_variable ]]; then
		eval "${output_variable}=''"
		output_temp_file="$temp_directory/$EVAL_CAPTURE_CONTEXT.output"
	fi

	# run the command and capture its exit status, and if applicable, capture its stdout
	# - if trapped an error inside this function, it will return this immediately
	# - if trapped an error inside a nested execution, it will run the trap inside that, allowing this function to continue
	# as such, we must cleanup inside the trap and after the trap, and cleanup must work in both contexts
	function eval_capture_wrapper {
		local subshell_status
		# __print_lines "PRE: [$EVAL_CAPTURE_STATUS] cmd=[$EVAL_CAPTURE_COMMAND] subshell=[$EVAL_CAPTURE_SUBSHELL] context=[$EVAL_CAPTURE_CONTEXT]" >/dev/tty
		EVAL_CAPTURE_COUNT="$((EVAL_CAPTURE_COUNT + 1))"
		# wrap if the $- check, as always returning causes +e to return when it shouldn't
		trap 'EVAL_CAPTURE_RETURN=$?; if [[ $- = *e* ]]; then eval_capture_wrapper_trap "$EVAL_CAPTURE_RETURN" "${FUNCNAME-}" "${cmd[*]}" "${BASH_SUBSHELL-}" "$EVAL_CAPTURE_CONTEXT"; return $?; fi' ERR
		# can't delegate this to a function (e.g. is_subshell_function), as the trap will go to the function
		if [[ $IS_BASH_VERSION_OUTDATED == 'yes' && $- == *e* && "$(declare -f "${cmd[0]}")" == "${cmd[0]}"$' () \n{ \n    ('* ]]; then
			# ALL SUBSHELLS SHOULD RE-ENABLE [set -e]
			# __print_lines "SUBSHELL $-" >/dev/tty
			set +e
			(
				set -e
				"${cmd[@]}"
			)
			subshell_status=$?
			set -e
		else
			"${cmd[@]}"
			subshell_status=$?
		fi
		# capture status in case of set +e
		if [[ $subshell_status -ne 0 ]]; then
			EVAL_CAPTURE_STATUS="$subshell_status"
		fi
		# we've stored the status, we return success
		return 0
	}
	if [[ -n $output_variable ]]; then
		if [[ -n $stdout_variable ]]; then
			if [[ -n $stderr_variable ]]; then
				eval_capture_wrapper > >(tee -a "$stdout_temp_file" "$output_temp_file" >"$stdout_pipe") 2> >(tee -a "$stderr_temp_file" "$output_temp_file" >"$stderr_pipe")
			else
				eval_capture_wrapper > >(tee -a "$stdout_temp_file" "$output_temp_file" >"$stdout_pipe") 2> >(tee -a "$output_temp_file" >"$stderr_pipe")
			fi
		else
			if [[ -n $stderr_variable ]]; then
				eval_capture_wrapper > >(tee -a "$output_temp_file" >"$stdout_pipe") 2> >(tee -a "$stderr_temp_file" "$output_temp_file" >"$stderr_pipe")
			else
				eval_capture_wrapper > >(tee -a "$output_temp_file" >"$stdout_pipe") 2> >(tee -a "$output_temp_file" >"$stderr_pipe")
			fi
		fi
	else
		if [[ -n $stdout_variable ]]; then
			if [[ -n $stderr_variable ]]; then
				eval_capture_wrapper > >(tee -a "$stdout_temp_file" >"$stdout_pipe") 2> >(tee -a "$stderr_temp_file" >"$stderr_pipe")
			else
				eval_capture_wrapper > >(tee -a "$stdout_temp_file" >"$stdout_pipe") 2>"$stderr_pipe"
			fi
		else
			if [[ -n $stderr_variable ]]; then
				eval_capture_wrapper >"$stdout_pipe" 2> >(tee -a "$stderr_temp_file" >"$stderr_pipe")
			else
				eval_capture_wrapper >"$stdout_pipe" 2>"$stderr_pipe"
			fi
		fi
	fi

	# remove the lingering trap
	EVAL_CAPTURE_COUNT="$((EVAL_CAPTURE_COUNT - 1))"
	# __print_lines "EVAL_CAPTURE_COUNT=[$EVAL_CAPTURE_COUNT]" >/dev/tty
	if [[ $EVAL_CAPTURE_COUNT -eq 0 ]]; then
		trap - ERR
	fi

	# save the exit status, and reset the global value
	# __print_lines "POST: [$EVAL_CAPTURE_STATUS] cmd=[$EVAL_CAPTURE_COMMAND] subshell=[$EVAL_CAPTURE_SUBSHELL] context=[$EVAL_CAPTURE_CONTEXT]" >/dev/tty
	if [[ $IS_BASH_VERSION_OUTDATED == 'yes' && -f $status_temp_file ]]; then # mktemp always creates the file, so need to use -s instead of -f
		EVAL_CAPTURE_STATUS="$(cat "$status_temp_file")"
		rm "$status_temp_file"
		# __print_lines "LOAD: [$EVAL_CAPTURE_STATUS] cmd=[$EVAL_CAPTURE_COMMAND] subshell=[$EVAL_CAPTURE_SUBSHELL] context=[$EVAL_CAPTURE_CONTEXT]" >/dev/tty
	fi
	eval "${exit_status_variable}=${EVAL_CAPTURE_STATUS:-0}"
	# unset -v EXIT_STATUS

	# save the stdout/stderr/output, and remove their temporary files
	if [[ -n $stdout_temp_file && -f $stdout_temp_file ]]; then
		eval "$stdout_variable"'="$(cat "$stdout_temp_file")"'
		rm "$stdout_temp_file"
		stdout_temp_file=''
	fi
	if [[ -n $stderr_temp_file && -f $stderr_temp_file ]]; then
		eval "$stderr_variable"'="$(cat "$stderr_temp_file")"'
		rm "$stderr_temp_file"
		stderr_temp_file=''
	fi
	if [[ -n $output_temp_file && -f $output_temp_file ]]; then
		eval "$output_variable"'="$(cat "$output_temp_file")"'
		rm "$output_temp_file"
		output_temp_file=''
	fi

	# return success
	return 0
}

# disable failglob (nullglob is better)
# bash v3: failglob: If set, patterns which fail to match filenames during filename expansion result in an expansion error.
shopt -u failglob

# bash v1?: nullglob: If set, Bash allows filename patterns which match no files to expand to a null string, rather than themselves.
shopt -s nullglob

# bash v4: globstar: If set, the pattern ‘**’ used in a filename expansion context will match all files and zero or more directories and subdirectories. If the pattern is followed by a ‘/’, only directories and subdirectories match.
if shopt -s globstar 2>/dev/null; then
	function __require_globstar {
		:
	}
else
	function __require_globstar {
		echo-style --error='Missing globstar support:' >/dev/stderr || return $?
		__require_upgraded_bash
	}
fi

# bash v5: extglob: If set, the extended pattern matching features described above (see Pattern Matching) are enabled.
if shopt -s extglob 2>/dev/null; then
	function __require_extglob {
		:
	}
else
	function __require_extglob {
		echo-style --error='Missing extglob support:' >/dev/stderr || return $?
		__require_upgraded_bash
	}
fi

# CONSIDER
# bash v5: localvar_inherit: If set, local variables inherit the value and attributes of a variable of the same name that exists at a previous scope before any new value is assigned. The nameref attribute is not inherited.
# shopt -s localvar_inherit 2>/dev/null || :

# bash v1?: localvar_unset: If set, calling unset on local variables in previous function scopes marks them so subsequent lookups find them unset until that function returns. This is identical to the behavior of unsetting local variables at the current function scope.
# shopt -s localvar_unset 2>/dev/null || :

# =============================================================================
# Shim bash functionality that is inconsistent between bash versions.

# Bash >= 4, < 4
if [[ $BASH_VERSION_MAJOR -ge 4 ]]; then
	# bash >= 4
	function __can_read_decimal_timeout {
		return 0
	}
	function __get_read_decimal_timeout {
		__print_lines "$1"
	}
else
	# bash < 4
	# Bash versions prior to 4, will error with "invalid timeout specification" on decimal timeouts
	function __can_read_decimal_timeout {
		return 1
	}
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
		function __lowercase_string {
			# trim -- prefix
			if [[ ${1-} == '--' ]]; then
				shift
			fi
			# proceed
			tr '[:upper:]' '[:lower:]' <<<"$1"
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
		test -v "$1"
		return
	}
else
	# bash < 4.2
	function __is_var_set {
		[[ -n ${!1-} ]]
		return
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

function __has_array_capability {
	for arg in "$@"; do
		if [[ $BASH_ARRAY_CAPABILITIES != *" $arg"* ]]; then
			return 1
		fi
	done
}

function __require_array {
	if ! __has_array_capability "$@"; then
		echo-style --error='Array support insufficient, required:' ' ' --code="$*" >/dev/stderr || return $?
		__require_upgraded_bash
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
	function mapfile {
		# Copyright 2021+ Benjamin Lupton <b@lupton.cc> (https://balupton.com)
		# Written for Dorothy (https://github.com/bevry/dorothy)
		# Licensed under the CC BY-SA 4.0 (https://creativecommons.org/licenses/by-sa/4.0/)
		local delim=$'\n' item
		if [[ $1 == '-t' ]]; then
			shift
		elif [[ $1 == '-td' ]]; then
			shift
			delim="$1"
			shift
		fi
		eval "$1=()"
		while IFS= read -rd "$delim" item || [[ -n $item ]]; do
			eval "$1+=($(printf '%q\n' "$item"))"
		done
	}
fi
BASH_ARRAY_CAPABILITIES+=' '
