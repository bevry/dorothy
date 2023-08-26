#!/usr/bin/env bash
# trunk-ignore-all(shellcheck/SC2034)

# For bash version compatibility and changes, see:
# See <https://github.com/bevry/dorothy/blob/master/docs/bash/versions.md> for documentation about signficant changes between bash versions.
# See <https://github.com/bminor/bash/blob/master/CHANGES> for documentation on changes from bash v2 and above.

# For bash configuration options, see:
# https://www.gnu.org/software/bash/manual/bash.html#The-Set-Builtin
# https://www.gnu.org/software/bash/manual/bash.html#The-Shopt-Builtin

# Note that [&>] is available to all bash versions, however [&>>] is not, they are different.

# =============================================================================
# Helpers to work around bash pecularities.
#
# echo has a few flaws, notably if the string argument is actually a echo argument, then it will not be output, e.g. [echo '-n'] will not output [-n]
function print_string {
	if test "$#" -ne 0; then
		printf '%s' "$*"
	fi
}
function print_line {
	print_string "$@"
	printf '\n'
}

# =============================================================================
# Determine the bash version information, which is used to determine if we can use certain features or not.
#
# require_upgraded_bash -- BASH_VERSION_CURRENT != BASH_VERSION_LATEST, fail.
# BASH_VERSION_CURRENT -- 5.2.15(1)-release => 5.2.15
# BASH_VERSION_MAJOR -- 5
# BASH_VERSION_MINOR -- 2
# BASH_VERSION_PATCH -- 15
# BASH_VERSION_LATEST -- 5.2.15
# IS_BASH_VERSION_OUTDATED -- yes/no

if test -z "${BASH_VERSION_CURRENT-}"; then
	# 5.2.15(1)-release => 5.2.15
	IFS=. read -r BASH_VERSION_MAJOR BASH_VERSION_MINOR BASH_VERSION_PATCH <<<"${BASH_VERSION%%(*}"
	BASH_VERSION_CURRENT="${BASH_VERSION_MAJOR}.${BASH_VERSION_MINOR}.${BASH_VERSION_PATCH}"
	BASH_VERSION_LATEST='5.2.15'
	# any v5 version is supported by dorothy
	if test "$BASH_VERSION_MAJOR" -eq 5; then
		IS_BASH_VERSION_OUTDATED='no'
		function require_upgraded_bash {
			true
		}
	else
		IS_BASH_VERSION_OUTDATED='yes'
		function require_upgraded_bash {
			echo-style \
				--code="$0" ' ' --error='is incompatible with' ' ' --code="bash $BASH_VERSION" $'\n' \
				'Run ' --code='setup-util-bash' ' to upgrade capabilities, then run the prior command again.' >/dev/stderr
			return 45 # ENOTSUP 45 Operation not supported
		}
	fi
fi

# =============================================================================
# Configure bash for Dorothy best practices.
#
# require_lastpipe -- if lastpipe not supported, fail.
# eval_capture -- capture or ignore exit status, without disabling errexit, and without a subshell.
# require_globstar -- if globstar not supported, fail.
# require_extglob -- if extglob not supported, fail.

# Disable completion (not needed in scripts)
# bash v2: progcomp: If set, the programmable completion facilities (see Programmable Completion) are enabled. This option is enabled by default.
shopt -u progcomp

# Promote the cleanup of nested commands if its login shell terminates.
# bash v2: huponexit: If set, Bash will send SIGHUP to all jobs when an interactive login shell exits (see Signals).
shopt -s huponexit

# Enable [cmd | read -r var] usage.
# bash v4.2:    lastpipe    If set, and job control is not active, the shell runs the last command of a pipeline not executed in the background in the current shell environment.
if shopt -s lastpipe 2>/dev/null; then
	function require_lastpipe {
		true
	}
else
	function require_lastpipe {
		echo-style --error='Missing lastpipe support:' >/dev/stderr
		require_upgraded_bash
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
# Ensure subshells that source this also get the trap
trap 'EXIT_STATUS=$?; if test "${FUNCNAME-}" = 'eval_capture_wrapper'; then return 0; elif test -n "${FUNCNAME-}"; then return "$EXIT_STATUS"; else exit "$EXIT_STATUS"; fi' ERR
function eval_capture {
	# Ensure subshells also get the settings
	set -Eeuo pipefail
	shopt -s inherit_errexit 2>/dev/null || :
	# Ensure subshells that call eval_capture also get the trap
	trap 'EXIT_STATUS=$?; if test "${FUNCNAME-}" = 'eval_capture_wrapper'; then return 0; elif test -n "${FUNCNAME-}"; then return "$EXIT_STATUS"; else exit "$EXIT_STATUS"; fi' ERR

	# fetch (if supplied) the variables that will store the command exit status, the stdout output, the stderr output, and/or the stdout+stderr output
	local item cmd=() exit_status_local exit_status_variable='exit_status_local' stdout_variable='' stdout_temp_file='' stderr_variable='' stderr_temp_file='' output_variable='' output_temp_file='' stdout_pipe='/dev/stdout' stderr_pipe='/dev/stderr'
	while test "$#" -ne 0; do
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
				For more information: https://gist.github.com/balupton/21ded5cefc26dc20833e6ed606209e1b

				USAGE:
				local status=0 stdout='' stderr='' output=''
				eval_capture [--statusvar=status] [--stdoutvar=stdout] [--stderrvar=stderr] [--outputvar=output] [--stdoutpipe=/dev/stdout] [--stderrpipe=/dev/stderr] [--outputpipe=...] [--no-stdout] [--no-stderr] [--no-output] [--] cmd ...

				EXAMPLE:
				status=0
				function testing_failure {
					echo 'start'
					false
					echo 'an undesired line should not be reached if errexit is still enabled'
				}

				# before
				status=0 && testing_failure || status=\$? # the undesired line will be output
				echo \$status # incorrectly outputs 0

				# after
				eval_capture --statusvar=status -- testing_failure # the undesired line is not output
				echo \$status # correctly outputs 1
				# correctly allows us to act upon the exit status
				if test \$status -eq 0; then
					echo ok
				else
					echo failure > /dev/stderr
				fi

				QUIRKS:
				Using --stdoutvar will set --stdoutpipe=/dev/null
				Using --stderrvar will set --stderrpipe=/dev/null
				Using --outputvar will set --stdoutpipe=/dev/null --stderrpipe=/dev/null

				WARNING:
				If [eval_capture] triggers something that still does an [if fn ...] or [... && fn || ...] or [! fn] then errexit will still be disabled for [fn]...
				...there exists no workaround for that unmodified code, as such you should always:
				* ensure that [fn] in such a case always has [... || return] on every line
				* never ever call functions under such conditions
				* rewrite such conditions with [eval_capture] as seen in the above example

				TODOS:
				Under bash v3, there is a failure when [config-helper --test] calls [config_helper] instead of [config-helper].
				EXIT_STATUS is being set correctly by the trap, but it is still zero when read to save to the variable.
				Changing [config_helper] to a squigly function instead of a subshell function fixes the issue.
			EOF
			return 22 # EINVAL 22 Invalid argument
			;;
		'--statusvar='*)
			exit_status_variable="${item#*--statusvar=}"
			;;
		'--stdoutvar='*)
			stdout_variable="${item#*--stdoutvar=}"
			stdout_pipe='/dev/null'
			;;
		'--stderrvar='*)
			stderr_variable="${item#*--stderrvar=}"
			stderr_pipe='/dev/null'
			;;
		'--outputvar='*)
			output_variable="${item#*--outputvar=}"
			stdout_pipe='/dev/null'
			stderr_pipe='/dev/null'
			;;
		'--no-stdout')
			stdout_pipe='/dev/null'
			;;
		'--no-stderr')
			stderr_pipe='/dev/null'
			;;
		'--no-output')
			stdout_pipe='/dev/null'
			stderr_pipe='/dev/null'
			;;
		'--stdoutpipe='*)
			stdout_pipe="${item#*--stdoutpipe=}"
			;;
		'--stderrpipe='*)
			stderr_pipe="${item#*--stderrpipe=}"
			;;
		'--outputpipe='*)
			stdout_pipe="${item#*--outputpipe=}"
			stderr_pipe="$stdout_pipe"
			;;
		'--')
			cmd+=("$@")
			shift $#
			break
			;;
		'-'*)
			print_line "ERROR: $0: ${FUNCNAME[0]}: $LINENO: An unrecognised flag was provided: $item" >/dev/stderr
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

	# store preliminary values, and prep the temporary files
	if test -n "$stdout_variable"; then
		eval "${stdout_variable}=''"
		stdout_temp_file="$(mktemp)"
	fi
	if test -n "$stderr_variable"; then
		eval "${stderr_variable}=''"
		stderr_temp_file="$(mktemp)"
	fi
	if test -n "$output_variable"; then
		eval "${output_variable}=''"
		output_temp_file="$(mktemp)"
	fi

	# run the command and capture its exit status, and if applicable, capture its stdout
	# - if trapped an error inside this function, it will return this immediately
	# - if trapped an error inside a nested execution, it will run the trap inside that, allowing this function to continue
	# as such, we must cleanup inside the trap and after the trap, and cleanup must work in both contexts
	function eval_capture_wrapper {
		# set +e
		# EXIT_STATUS=0
		"${cmd[@]}"
		# print_line "${cmd[*]} => $EXIT_STATUS" >/dev/tty
		# set -e
	}
	if test -n "$output_variable"; then
		if test -n "$stdout_variable"; then
			if test -n "$stderr_variable"; then
				eval_capture_wrapper > >(tee -a "$stdout_temp_file" "$output_temp_file" >"$stdout_pipe") 2> >(tee -a "$stderr_temp_file" "$output_temp_file" >"$stderr_pipe")
			else
				eval_capture_wrapper > >(tee -a "$stdout_temp_file" "$output_temp_file" >"$stdout_pipe") 2> >(tee -a "$output_temp_file" >"$stderr_pipe")
			fi
		else
			if test -n "$stderr_variable"; then
				eval_capture_wrapper > >(tee -a "$output_temp_file" >"$stdout_pipe") 2> >(tee -a "$stderr_temp_file" "$output_temp_file" >"$stderr_pipe")
			else
				eval_capture_wrapper > >(tee -a "$output_temp_file" >"$stdout_pipe") 2> >(tee -a "$output_temp_file" >"$stderr_pipe")
			fi
		fi
	else
		if test -n "$stdout_variable"; then
			if test -n "$stderr_variable"; then
				eval_capture_wrapper > >(tee -a "$stdout_temp_file" >"$stdout_pipe") 2> >(tee -a "$stderr_temp_file" >"$stderr_pipe")
			else
				eval_capture_wrapper > >(tee -a "$stdout_temp_file" >"$stdout_pipe") 2>"$stderr_pipe"
			fi
		else
			if test -n "$stderr_variable"; then
				eval_capture_wrapper >"$stdout_pipe" 2> >(tee -a "$stderr_temp_file" >"$stderr_pipe")
			else
				eval_capture_wrapper >"$stdout_pipe" 2>"$stderr_pipe"
			fi
		fi
	fi

	# save the exit status, and reset the global value
	eval "${exit_status_variable}=${EXIT_STATUS:-0}"
	unset -v EXIT_STATUS

	# save the stdout/stderr/output, and remove their temporary files
	if test -n "$stdout_temp_file" -a -f "$stdout_temp_file"; then
		eval "${stdout_variable}=\"\$(cat $stdout_temp_file)\""
		rm "$stdout_temp_file"
		stdout_temp_file=''
	fi
	if test -n "$stderr_temp_file" -a -f "$stderr_temp_file"; then
		eval "${stderr_variable}=\"\$(cat $stderr_temp_file)\""
		rm "$stderr_temp_file"
		stderr_temp_file=''
	fi
	if test -n "$output_temp_file" -a -f "$output_temp_file"; then
		eval "${output_variable}=\"\$(cat $output_temp_file)\""
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
	function require_globstar {
		true
	}
else
	function require_globstar {
		echo-style --error='Missing globstar support:' >/dev/stderr
		require_upgraded_bash
	}
fi

# bash v5: extglob: If set, the extended pattern matching features described above (see Pattern Matching) are enabled.
if shopt -s extglob 2>/dev/null; then
	function require_extglob {
		true
	}
else
	function require_extglob {
		echo-style --error='Missing extglob support:' >/dev/stderr
		require_upgraded_bash
	}
fi

# CONSIDER
# bash v5: localvar_inherit: If set, local variables inherit the value and attributes of a variable of the same name that exists at a previous scope before any new value is assigned. The nameref attribute is not inherited.
# shopt -s localvar_inherit 2>/dev/null || :

# basg v1?: localvar_unset: If set, calling unset on local variables in previous function scopes marks them so subsequent lookups find them unset until that function returns. This is identical to the behavior of unsetting local variables at the current function scope.
# shopt -s localvar_unset 2>/dev/null || :

# =============================================================================
# Shim bash functionality that is inconsistent between bash versions.

# Shim Read Timeout
# Bash versions prior to 4, will error with "invalid timeout specification" on decimal timeouts
if test "$BASH_VERSION_MAJOR" -ge 4; then
	function get_read_decimal_timeout {
		print_line "$1"
	}
else
	function get_read_decimal_timeout {
		print_line 1
	}
fi

# Shim Paramater Expansions
# https://www.gnu.org/software/bash/manual/bash.html#Shell-Parameter-Expansion
#
# uppercase_first_letter
# lowercase_string
if test "$BASH_VERSION_MAJOR" -eq 5 -a "$BASH_VERSION_MINOR" -ge 1; then
	# >= bash v5.1
	function uppercase_first_letter {
		print_line "${1@u}"
	}
	function lowercase_string {
		print_line "${1@L}"
	}
elif test "$BASH_VERSION_MAJOR" -eq 4; then
	# >= bash v4.0
	function uppercase_first_letter {
		print_line "${1^}"
	}
	function lowercase_string {
		print_line "${1,,}"
	}
else
	# < bash v4.0
	function uppercase_first_letter {
		print_line "$1" # not important, implement later
	}
	function lowercase_string {
		print_line "$1" # not important, implement later
	}
fi

# Shim Conditional Expressions
# -v varname: True if the shell variable varname is set (has been assigned a value).
# https://www.gnu.org/software/bash/manual/bash.html#Bash-Conditional-Expressions
#
# is_var_set
if test "$BASH_VERSION_MAJOR" -ge 5 || test "$BASH_VERSION_MAJOR" -eq 4 -a "$BASH_VERSION_MINOR" -ge 2; then
	# >= bash v4.2
	function is_var_set {
		test -v "$1"
	}
else
	# < bash v4.2
	function is_var_set {
		test -n "${!1-}"
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
#     - use: `test "${#array[@]}" -ne 0 && for ...`
#     - or if you don't care for empty elements, use: `test -n "$arr" && for ...`
#
# BASH_ARRAY_CAPABILITIES -- string that stores the various capaibilities: mapfile[native] mapfile[shim] readarray[native] empty[native] empty[shim] associative
# has_array_capability -- check if a capability is provided by the current bash version
# require_array -- require a capability to be provided by the current bash version, otherwise fail
# mapfile -- shim [mapfile] for bash versions that do not have it

function has_array_capability {
	for arg in "$@"; do
		if [[ $BASH_ARRAY_CAPABILITIES != *" $arg"* ]]; then
			return 1
		fi
	done
}

function require_array {
	if ! has_array_capability "$@"; then
		echo-style --error='Array support insufficient, required:' ' ' --code="$*" >/dev/stderr
		require_upgraded_bash
	fi
}

BASH_ARRAY_CAPABILITIES=''
if test "$BASH_VERSION_MAJOR" -ge '5'; then
	BASH_ARRAY_CAPABILITIES+=' mapfile[native] readarray[native] empty[native]'
	if test "$BASH_VERSION_MINOR" -ge '1'; then
		BASH_ARRAY_CAPABILITIES+=' associative'
	fi
elif test "$BASH_VERSION_MAJOR" -ge '4'; then
	BASH_ARRAY_CAPABILITIES+=' mapfile[native] readarray[native]'
	if test "$BASH_VERSION_MINOR" -ge '4'; then
		BASH_ARRAY_CAPABILITIES+=' empty[native]'
	else
		BASH_ARRAY_CAPABILITIES+=' empty[shim]'
		set +u # disable nounset to prevent crashes on empty arrays
	fi
elif test "$BASH_VERSION_MAJOR" -ge '3'; then
	BASH_ARRAY_CAPABILITIES+=' mapfile[shim] empty[shim]'
	set +u # disable nounset to prevent crashes on empty arrays
	function mapfile {
		# Copyright 2021+ Benjamin Lupton <b@lupton.cc> (https://balupton.com)
		# Written for Dorothy (https://github.com/bevry/dorothy)
		# Licensed under the CC BY-SA 4.0 (https://creativecommons.org/licenses/by-sa/4.0/)
		local delim=$'\n' item
		if test "$1" = '-t'; then
			shift
		elif test "$1" = '-td'; then
			shift
			delim="$1"
			shift
		fi
		eval "$1=()"
		while IFS= read -rd "$delim" item || test -n "$item"; do
			eval "$1+=($(echo-quote "$item"))"
		done
	}
fi
BASH_ARRAY_CAPABILITIES+=' '
