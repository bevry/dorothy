#!/usr/bin/env bash
# `bash.bash` is a source file from the Dorothy dotfile ecosystem: https://dorothy.bevry.me
# To use it standalone in your non-Dorothy projects, you can:
# ``` bash
# eval "$(curl -fsSL 'https://raw.githubusercontent.com/bevry/dorothy/HEAD/sources/bash.bash')"
# ```
# Or, with complete command conventions, you can:
# ``` bash
# #!/usr/bin/env bash
# function my_command() (
#   eval "$(curl -fsSL 'https://raw.githubusercontent.com/bevry/dorothy/HEAD/sources/bash.bash')"
#   # ... your code here ...
# )
# # fire if invoked standalone
# if [[ $0 == "${BASH_SOURCE[0]}" ]]; then
#   my_command "$@"
# fi
# ```
# Replace `HEAD` with the latest commit hash to protect against breaking changes.
# Regardless of how you use `bash.bash`, it, like Dorothy, is RPL-1.5 licensed:
# https://github.com/bevry/dorothy/blob/HEAD/LICENSE.md

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

# disable tracing of this while it loads as it is too large
PAUSE_RESTORE_TRACING_X=''
PAUSE_RESTORE_TRACING_V=''
function __pause_tracing {
	if [[ $- == *x* ]]; then
		set +x
		PAUSE_RESTORE_TRACING_X+='1'
	else
		PAUSE_RESTORE_TRACING_X+='0'
	fi

	if [[ $- == *v* ]]; then
		set +v
		PAUSE_RESTORE_TRACING_V+='1'
	else
		PAUSE_RESTORE_TRACING_V+='0'
	fi
}
function __restore_tracing {
	if [[ -n $PAUSE_RESTORE_TRACING_X ]]; then
		if [[ ${PAUSE_RESTORE_TRACING_X: -1} == '1' ]]; then
			set -x
		fi
		PAUSE_RESTORE_TRACING_X="${PAUSE_RESTORE_TRACING_X:0:${#PAUSE_RESTORE_TRACING_X} - 1}"
	fi
	if [[ -n $PAUSE_RESTORE_TRACING_V ]]; then
		if [[ ${PAUSE_RESTORE_TRACING_V: -1} == '1' ]]; then
			set -v
		fi
		PAUSE_RESTORE_TRACING_V="${PAUSE_RESTORE_TRACING_V:0:${#PAUSE_RESTORE_TRACING_V} - 1}"
	fi
}
__pause_tracing

# =============================================================================
# Essential Toolkit

# Used to load functions from dependency source files
function __invoke_function_from_source {
	local file="$1"
	shift
	if [[ -n ${DOROTHY-} ]]; then
		# function romeo { function romeo { echo replaced; }; romeo; }; romeo; romeo
		# $'replaced\nreplaced'
		source "$DOROTHY/sources/${file}" || return $?
		"${FUNCNAME[1]}" "$@" || return $?
	else
		printf '%s\n' "${FUNCNAME[1]} requires Dorothy <https://dorothy.bevry.me> to be installed, or for <https://dorothy.bevry.me/sources/${file}> to be sourced." >&2 || :
		return 6 # ENXIO 6 Device not configured
	fi
}

# -------------------------------------
# Environment Toolkit & Print Toolkit Dependencies

# cache `uname -r` to prevent slow invocations
function __prepare_uname_r {
	if [[ -z ${UNAME_R-} ]]; then
		export UNAME_R
		UNAME_R="$(uname -r)" || return 46 # EPFNOSUPPORT 46 Protocol family not supported
	fi
}
# cache `uname -v` to prevent slow invocations
function __prepare_uname_v {
	if [[ -z ${UNAME_V-} ]]; then
		export UNAME_V
		UNAME_V="$(uname -v)" || return 46 # EPFNOSUPPORT 46 Protocol family not supported
	fi
}

# see `commands/get-arch` for details
function __get_arch {
	local arch="$HOSTTYPE"
	if [[ $arch == 'aarch64' || $arch == 'arm64' ]]; then
		printf '%s' 'a64' # Raspberry Pi, Apple Silicon
	elif [[ $arch == x86_64* ]]; then
		# Is this Apple Silicon running via `arch -x86_64 <command>`?
		# if it is, then `$HOSTTYPE` and `uname -m` is `x86_64`:
		# so on macOS/Darwin, we can must fallback to a `uname -v` check
		if [[ $OSTYPE == darwin* ]] && __prepare_uname_v && [[ "$UNAME_V" == *ARM64* ]]; then
			printf '%s' 'a64' # Apple Silicon running via `arch -x86_64 <command>`
		else
			printf '%s' 'x64'
		fi
	elif [[ $arch == i*86 ]]; then
		printf '%s' 'x32'
	elif [[ $arch == arm* ]]; then
		printf '%s' 'a32'
	elif [[ $arch == 'riscv64' ]]; then
		printf '%s' 'r64'
	else
		return 46 # EPFNOSUPPORT 46 Protocol family not supported
	fi
}

function __is_macos {
	[[ $OSTYPE == darwin* ]] || return $?
}

# this will/should pass on WSL on Windows
function __is_linux {
	# `OSTYPE` = `linux-gnu` (on everything, sans exceptions)
	# `OSTYPE` = `linux` (opensuse)
	# `uname -o` = `GNU/Linux`
	# `uname -s` = `Linux`
	[[ $OSTYPE == linux* ]] || return $?
}

function __is_wsl {
	# `HOSTTYPE` = `x86_64`
	# `OSTYPE` = `linux-gnu`
	# `MACHTYPE` = `x86_64-pc-linux-gnu`
	# `uname -r` = `6.6.87.2-microsoft-standard-WSL2`
	__prepare_uname_r || return $?
	[[ $UNAME_R == *-WSL2* ]] || return $?
}

function __is_windows {
	__prepare_uname_r || return $?
	[[ $UNAME_R =~ MINGW64_NT|-WSL ]] || return $?
}

function __is_brew {
	[[ -n ${HOMEBREW_PREFIX-} && -x "${HOMEBREW_PREFIX-}/bin/brew" ]] || return $?
}

# handle JQ built for windows inserting carriage returns on windows
# `printf '{"key": "value"}' | jq.exe -r '.key' | cat -v` results in `value^M`
# gh, even with `--jq <filter>` does not inject such carriage returns (this could be however gh built for linux, instead of built for windows)
if __is_windows; then
	function __strip_carriage_returns_if_windows {
		sed 's/\r//g'
	}
	function __jq {
		jq "$@" | __strip_carriage_returns_if_windows
	}
else
	function __strip_carriage_returns_if_windows {
		cat
	}
	function __jq {
		jq "$@"
	}
fi

# see `commands/command-missing` for details
# returns `0` if ANY command is missing
# returns `1` if ALL commands were present
function __command_missing {
	# trim -- prefix
	if [[ ${1-} == '--' ]]; then
		shift
	fi
	__affirm_length_defined $# 'command' || return $?
	# proceed
	local COMMAND_MISSING__command
	for COMMAND_MISSING__command in "$@"; do
		if type -P "$COMMAND_MISSING__command" &>/dev/null; then
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
	__affirm_length_defined $# 'command' || return $?
	# proceed
	local COMMAND_EXISTS__command
	for COMMAND_EXISTS__command in "$@"; do
		if type -P "$COMMAND_EXISTS__command" &>/dev/null; then
			continue
		else
			return 1 # a command is missing
		fi
	done
	return 0 # all commands are present
}

# command existence and installation
# __command_required [--print] [--no-install] [--] ...<command>
# --print: print the command that was found or installed
# if multiple commands are provided, the first one found is used, if not found, the first one installed is used
function __command_required {
	# verbose
	local COMMAND_REQUIRED__item COMMAND_REQUIRED__print='no' COMMAND_REQUIRED__install='yes' COMMAND_REQUIRED__commands=()
	while [[ $# -ne 0 ]]; do
		COMMAND_REQUIRED__item="$1"
		shift
		case "$COMMAND_REQUIRED__item" in
		'--no-print'* | '--print'*) __flag --source={COMMAND_REQUIRED__item} --target={COMMAND_REQUIRED__print} --affirmative --coerce || return $? ;;
		'--no-install'* | '--install'*) __flag --source={COMMAND_REQUIRED__item} --target={COMMAND_REQUIRED__install} --affirmative --coerce || return $? ;;
		'--')
			COMMAND_REQUIRED__commands+=("$@")
			shift $#
			break
			;;
		*) COMMAND_REQUIRED__commands+=("$COMMAND_REQUIRED__item") ;;
		esac
	done
	__affirm_length_defined "${#COMMAND_REQUIRED__commands[@]}" '<command>' || return $?
	# proceed
	local COMMAND_REQUIRED__command
	for COMMAND_REQUIRED__command in "${COMMAND_REQUIRED__commands[@]}"; do
		if __command_exists -- "$COMMAND_REQUIRED__command"; then
			if [[ $COMMAND_REQUIRED__print == 'yes' ]]; then
				__print_string "$COMMAND_REQUIRED__command" || return $?
			fi
			return 0
		fi
	done
	# if any were found, we would have already returned
	if [[ $COMMAND_REQUIRED__install == 'no' ]]; then
		return 6 # ENXIO 6 Device not configured
	fi
	# @todo update this to be inlined into `setup-util` to make implementing the `--(fallback|deps|slim)` options easier
	get-installer --first-success --invoke --quiet -- "${COMMAND_REQUIRED__commands[@]}" || return $?
	# verify installation
	for COMMAND_REQUIRED__command in "${COMMAND_REQUIRED__commands[@]}"; do
		if __command_exists -- "$COMMAND_REQUIRED__command"; then
			if [[ $COMMAND_REQUIRED__print == 'yes' ]]; then
				__print_string "$COMMAND_REQUIRED__command" || return $?
			fi
			return 0
		fi
	done
	# if nothing was installed, then get-installer did not return failure
	return 104 # ENOTRECOVERABLE 104 State not recoverable
}

# for __tool see later

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
		printf '%s' "$@" || return $?
	fi
}
function __print_strings { # b/c alias for __print_strings_or_nothing
	if [[ $# -ne 0 ]]; then
		printf '%s' "$@" || return $?
	fi
}
function __print_strings_or_nothing {
	if [[ $# -ne 0 ]]; then
		printf '%s' "$@" || return $?
	fi
}

# print a newline
function __print_line {
	printf '\n' || return $?
}

# print each argument on its own line, if no arguments, print a line
function __print_lines_or_line {
	# equivalent to `printf '\n'` if no arguments
	printf '%s\n' "$@" || return $?
}

# print each argument on its own line, if no arguments, do nothing
function __print_lines { # b/c alias for __print_lines_or_nothing
	if [[ $# -ne 0 ]]; then
		printf '%s\n' "$@" || return $?
	fi
}
function __print_lines_or_nothing {
	if [[ $# -ne 0 ]]; then
		printf '%s\n' "$@" || return $?
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
		printf '%s' "${values[@]}" || return $?
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
		printf '%s\n' "${values[@]}" || return $?
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
		printf '\n' || return $?
	else
		printf '%s\n' "${values[@]}" || return $?
	fi
}

export DOROTHY_DEBUG
DOROTHY_DEBUG="${DOROTHY_DEBUG:-"no"}"
function __get_terminal_color_support {
	__invoke_function_from_source 'styles.bash' "$@" || return $?
}
function __load_styles {
	__invoke_function_from_source 'styles.bash' "$@" || return $?
}
function __print_style {
	__invoke_function_from_source 'styles.bash' "$@" || return $?
}
function __print_help {
	__invoke_function_from_source 'styles.bash' "$@" || return $?
}
function __print_error {
	__print_style --stderr --error='ERROR:' ' ' "$@" || return $?
}

function __dump {
	if [[ $# -eq 0 ]]; then
		return 0
	fi
	local DUMP__item DUMP__color='' DUMP__variable_name DUMP__show_name='yes' DUMP__name DUMP__indices=no DUMP__value DUMP__log=()
	while [[ $# -ne 0 ]]; do
		DUMP__item="$1"
		DUMP__show_name='yes'
		shift
		case "$DUMP__item" in
		'--debug')
			if [[ $DOROTHY_DEBUG != 'yes' ]]; then
				return 0
			fi
			DUMP__log+=("$DUMP__item")
			continue
			;;
		'--no-style' | '--no-color')
			DUMP__color=no
			continue
			;;
		'--indices')
			DUMP__indices=yes
			continue
			;;
		'--value='*)
			DUMP__value="${DUMP__item#*=}"
			if [[ -z $DUMP__value ]]; then
				DUMP__log+=(--commentary-empty='' --newline)
			else
				DUMP__log+=(--invert="$DUMP__value" --newline)
			fi
			continue
			;;
		'--variable-value='*)
			DUMP__show_name='no'
			DUMP__item="${DUMP__item#*=}"
			;;
		'--variable='*)
			DUMP__item="${DUMP__item#*=}"
			;;
		'--'*)
			DUMP__log+=("$DUMP__item")
			continue
			;;
		esac
		__dereference --source="$DUMP__item" --name={DUMP__variable_name} || return $?
		if [[ $DUMP__show_name == 'yes' ]]; then
			DUMP__name="$DUMP__variable_name"
		else
			DUMP__name=''
		fi
		# @todo support associative arrays
		if ! __is_var_declared "$DUMP__variable_name"; then
			if [[ $DUMP__show_name == 'yes' ]]; then
				DUMP__log+=(--bold="$DUMP__variable_name" ' = ' --commentary-undeclared='' --newline)
			else
				DUMP__log+=(--commentary-undeclared='')
			fi
			continue
		fi
		if __is_array "$DUMP__variable_name"; then
			# As commented at `__is_array`, the above condition is always true, with `echo "$DUMP__variable_name IS ARRAY $?" >&2` always firing with `0`, unless `|| return N` or `|| return $?` was used inside `__is_array`
			if ! __is_var_defined "$DUMP__variable_name"; then
				if [[ $DUMP__show_name == 'yes' ]]; then
					DUMP__log+=(--bold="${DUMP__variable_name}[@]" ' = ' --commentary-undefined='' --newline)
				else
					DUMP__log+=(--commentary-undefined='')
				fi
				continue
			fi
			local -i DUMP__index DUMP__total DUMP__char_index DUMP__char_total
			eval "DUMP__total=\${#${DUMP__variable_name}[@]}"
			if [[ $DUMP__total == 0 ]]; then
				if [[ $DUMP__show_name == 'yes' ]]; then
					DUMP__log+=(--bold="${DUMP__variable_name}[@]" ' = ' --commentary-empty='' --newline)
				else
					DUMP__log+=(--commentary-empty='')
				fi
			else
				# for ((DUMP__index = 0; DUMP__index < DUMP__total; ++DUMP__index)); do <-- can't do this, as it doesn't support this sparse arrays, e.g.: arr=(); arr[5]='...'; __dump {arr};
				local DUMP__reference_indices=()
				eval "DUMP__reference_indices=(\"\${!${DUMP__variable_name}[@]}\")"
				for DUMP__index in "${DUMP__reference_indices[@]}"; do
					eval "DUMP__value=\"\${${DUMP__variable_name}[DUMP__index]}\""
					if [[ $DUMP__indices == 'yes' ]]; then
						# obviously this will be broken if the array is sparse, however that is up the caller
						DUMP__log+=(--bold="${DUMP__name}[ ${DUMP__index} | $(((DUMP__total - DUMP__index) * -1)) ]" ' = ')
					else
						DUMP__log+=(--bold="${DUMP__name}[${DUMP__index}]" ' = ')
					fi
					if [[ -z $DUMP__value ]]; then
						DUMP__log+=(--commentary-empty='' --newline)
					else
						DUMP__log+=(--invert="$DUMP__value" --newline)
					fi
				done
			fi
		else
			if ! __is_var_defined "$DUMP__variable_name"; then
				if [[ $DUMP__show_name == 'yes' ]]; then
					DUMP__log+=(--bold="$DUMP__name" ' = ' --commentary-undefined='' --newline)
				else
					DUMP__log+=(--commentary-undefined='')
				fi
				continue
			fi
			DUMP__value="${!DUMP__variable_name}"
			if [[ -z $DUMP__value ]]; then
				if [[ $DUMP__show_name == 'yes' ]]; then
					DUMP__log+=(--bold="$DUMP__name" ' = ' --commentary-empty='' --newline)
				else
					DUMP__log+=(--commentary-empty='')
				fi
			else
				if [[ $DUMP__show_name == 'yes' ]]; then
					DUMP__log+=(--bold="$DUMP__name" ' = ' --invert="$DUMP__value" --newline)
				else
					DUMP__log+=(--invert="$DUMP__value")
				fi
			fi
			# for non-arrays, if indices, then we output the string as already done above, then we also output the indices of the string
			if [[ $DUMP__indices == 'yes' ]]; then
				DUMP__char_total="${#DUMP__value}"
				for ((DUMP__char_index = 0; DUMP__char_index < DUMP__char_total; ++DUMP__char_index)); do
					if [[ $DUMP__indices == 'yes' ]]; then
						DUMP__log+=(--bold="${DUMP__name}[ ${DUMP__char_index} | $(((DUMP__char_total - DUMP__char_index) * -1)) ]" ' = ')
					else
						DUMP__log+=(--bold="${DUMP__name}[${DUMP__char_index}]" ' = ')
					fi
					if [[ -z $DUMP__value ]]; then
						DUMP__log+=(--commentary-empty='' --newline)
					else
						DUMP__log+=(--invert="${DUMP__value:DUMP__char_index:1}" --newline)
					fi
				done
			fi
		fi
	done
	__print_style --colors="$DUMP__color" --no-trail "${DUMP__log[@]}" || return $?
}

# not actually used anywhere
function __stack {
	local index size=${#FUNCNAME[@]}
	for ((index = 0; index < size; ++index)); do
		printf '%s\n' "${BASH_SOURCE[index]}:${BASH_LINENO[index]} ${FUNCNAME[index]}"
	done
	__dump {BASH_SOURCE} {LINENO} {FUNCNAME} {BASH_LINENO} {BASH_SUBSHELL} || return $?
	caller
}

# =============================================================================
# Bash Versions & Configuration & Capability Detection, Including Shims/Polyfills
# Place changelog entries in `versions.md`
# Distribution of bash versions: <https://repology.org/project/bash/versions>
# Listing of bash releases: <https://ftp.gnu.org/gnu/bash/?C=M;O=D>

# convert a version (short and full) into its corresponding latest downloadable version identifier
function __get_coerced_bash_version {
	local input="$1" result
	case "$input" in
	'3.0'*) result='3.0.16' ;;
	'3.1'*) result='3.1' ;;
	'3' | '3.' | '3.2'*) result='3.2.57' ;;
	'4.0'*) result='4.0' ;;
	'4.1'*) result='4.1' ;;
	'4.2'*) result='4.2.53' ;;
	'4.3'*) result='4.3.30' ;;
	'4' | '4.' | '4.4'*) result='4.4.18' ;;
	'5.0'*) result='5.0' ;;
	'5.1'*) result='5.1.16' ;;
	'5.2'*) result='5.2.37' ;;
	'' | '5' | '5.' | '5.3'*) result='5.3' ;;
	*)
		__print_lines "ERROR: The bash version $(__dump --value="$input" || :) is not supported by Dorothy." >&2 || :
		return 75 # EPROGMISMATCH 75 Program version wrong
		;;
	esac
	printf '%s' "$result" || return $?
}

# Determine the bash version information, which is used to determine if we can use certain features or not.
	# e.g. 5.2.15(1)-release => 5.2.15
	# https://www.gnu.org/software/bash/manual/bash.html#index-BASH_005fVERSINFO
	# `read` technique not needed as `BASH_VERSINFO` exists in all versions:
	# IFS=. read -r BASH_VERSION_MAJOR BASH_VERSION_MINOR BASH_VERSION_PATCH <<<"${BASH_VERSION%%(*}"
	BASH_VERSION_MAJOR="${BASH_VERSINFO[0]}"                                                 # 5
	BASH_VERSION_MINOR="${BASH_VERSINFO[1]}"                                                 # 2
	BASH_VERSION_PATCH="${BASH_VERSINFO[2]}"                                                 # 15
	BASH_VERSION_CURRENT="${BASH_VERSION_MAJOR}.${BASH_VERSION_MINOR}.${BASH_VERSION_PATCH}" # 5.2.15(1)-release => 5.2.15
	# trunk-ignore(shellcheck/SC2034)
	BASH_VERSION_LATEST='5.3' # https://ftp.gnu.org/gnu/bash/?C=M;O=D
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
		__require_upgraded_bash 'missing globstar support' || return $?
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
		__require_upgraded_bash 'missing extglob support' || return $?
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
		__require_upgraded_bash 'missing lastpipe support' || return $?
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
	[[ $- == *e* ]] || return $? # explicit `|| return` required to prevent ERR trap from firing, which is important here as it is used within our ERR trap
}
function __is_not_errexit {
	[[ $- != *e* ]] || return $? # explicit `|| return` required to prevent ERR trap from firing, which is important here as it is used within our ERR trap
}

# Detect nounset
function __is_nounset {
	[[ $- == *u* ]] || return $? # explicit `|| return` required to prevent ERR trap from firing, which is important here as it is used within our ERR trap
}
function __is_not_nounset {
	[[ $- != *u* ]] || return $? # explicit `|| return` required to prevent ERR trap from firing, which is important here as it is used within our ERR trap
}

# Whether the terminal supports the `/dev/tty` device file
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
	# - `ssh -T execution: ssh -T localhost <cmd>`
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
if [[ ${CI-} =~ ^(yes|YES|true|TRUE|1)$ ]]; then
	CI='yes'
else
	CI=''
fi
if [[ -n $CI ]]; then
	ALTERNATIVE_SCREEN_BUFFER_SUPPORTED='no'
else
	# trunk-ignore(shellcheck/SC2034)
	ALTERNATIVE_SCREEN_BUFFER_SUPPORTED='yes'
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

# all bash versions above 4.1 can open an available file descriptor to a reference:
# debug-bash --continue --all-bash-versions --code='echo "$BASH_VERSION"; exec {my_fd}> >(cat)'
if [[ $BASH_VERSION_MAJOR -ge 5 || ($BASH_VERSION_MAJOR -eq 4 && $BASH_VERSION_MINOR -ge 1) ]]; then
	BASH_CAN_OPEN_AVAILABLE_FILE_DESCRIPTOR_TO_REFERENCE=yes
else
	BASH_CAN_OPEN_AVAILABLE_FILE_DESCRIPTOR_TO_REFERENCE=no
fi

if [[ $BASH_VERSION_MAJOR -eq 4 && $BASH_VERSION_MINOR -eq 2 ]]; then
	BASH_CLOSURE_OF_FILE_DESCRIPTOR_CLOSES_THE_STDIN_OF_ITS_PROCESS_SUBSTITUTION=no
else
	# trunk-ignore(shellcheck/SC2034)
	BASH_CLOSURE_OF_FILE_DESCRIPTOR_CLOSES_THE_STDIN_OF_ITS_PROCESS_SUBSTITUTION=yes
fi

# all bash versions support a negative start index for arrays and strings:
# debug-bash --all-bash-versions --code='echo "$BASH_VERSION"; arr=(aa bb cc); echo "${arr[@]:(-1)}"; str=abc; echo "${str:(-1)}"'
# all bash versions fail with a negative array length:
# debug-bash --continue --all-bash-versions --code='echo "$BASH_VERSION"; arr=(a b c); echo "${arr[@]:0:(-1)}"'
# bash versions prior to 4.2 fail with a negative strength length:
# debug-bash --continue --all-bash-versions --code='echo "$BASH_VERSION"; str=abc; echo "${str:0:(-1)}"'
if [[ $BASH_VERSION_MAJOR -gt 4 || ($BASH_VERSION_MAJOR -eq 4 && $BASH_VERSION_MINOR -ge 2) ]]; then
	BASH_CAN_USE_A_NEGATIVE_LENGTH=yes
	BASH_CAN_PRINTF_DATEFMT='yes'
else
	BASH_CAN_USE_A_NEGATIVE_LENGTH=no
	BASH_CAN_PRINTF_DATEFMT='no'
fi

# `__get_date '+YEAR: %Y'` == `__get_date 'YEAR: %Y' == `__get_date --format='YEAR: %Y'` (uses `printf` if supported)
# `__get_date %Y` == `__get_date +%Y` == `__get_date --format=%Y` (uses `printf` if supported)
# `__get_date -v +1y` (uses `date`, as `printf` does not support arguments)
# `__get_date -u +%Y` == `__get_date -u %Y` == `__get_date -u --format=%Y` (uses `date`, as `printf` does not support arguments)
function __get_date {
	local GET_DATE__date_args=() GET_DATE__item
	if [[ $# -eq 0 ]]; then
		__affirm_length_defined $# 'input' || return $?
	elif [[ $# -eq 1 ]]; then
		# to `date` or `printf`
		local GET_DATE__format=''
		while [[ $# -ne 0 ]]; do
			GET_DATE__item="$1"
			shift
			case "$GET_DATE__item" in
			'--format='*) GET_DATE__format="${GET_DATE__item#*=}" ;;
			'-'*) GET_DATE__date_args+=("$GET_DATE__item") ;;
			'+'*) GET_DATE__format="${GET_DATE__item:1}" ;; # this is constrained to $#==1 because of (-v +1y) combo
			'%'*) GET_DATE__format="$GET_DATE__item" ;;
			*) GET_DATE__format="$GET_DATE__item" ;; # the only single argument that `date` supports is setting the system clock, e.g. `date 0613162785` and `date 1432`, which is not what this function is for, so assume it is not that, and instead is a format
			esac
		done
		if [[ ${#GET_DATE__date_args[@]} -ne 0 || $BASH_CAN_PRINTF_DATEFMT == 'no' ]]; then
			if [[ -n $GET_DATE__format ]]; then
				GET_DATE__date_args+=("+$GET_DATE__format")
			fi
			date "${GET_DATE__date_args[@]}" || return $?
		elif [[ -n $GET_DATE__format ]]; then
			printf "%($GET_DATE__format)T\n" || return $? # \n to match `date` behaviour
		else
			__affirm_value_is_defined "$GET_DATE__format" 'date format' || return $?
		fi
	else
		# forward to `date` but repair missing + on format
		while [[ $# -ne 0 ]]; do
			GET_DATE__item="$1"
			shift
			case "$GET_DATE__item" in
			'--format='*) GET_DATE__date_args+=("+${GET_DATE__item#*=}") ;;
			'-'*) GET_DATE__date_args+=("$GET_DATE__item") ;;
			'+'*) GET_DATE__date_args+=("$GET_DATE__item") ;;
			'%'*) GET_DATE__date_args+=("+$GET_DATE__item") ;;
			*) GET_DATE__date_args+=("$GET_DATE__item") ;;
			esac
		done
		date "${GET_DATE__date_args[@]}" || return $?
	fi
}

if [[ $BASH_VERSION_MAJOR -ge 5 ]]; then
	# Bash >= 5
	# `EPOCHSECONDS` expands to the time in seconds since the Unix epoch.
	# `EPOCHREALTIME` expands to the time in seconds since the Unix epoch with microsecond granularity.
	function __get_epoch_seconds { printf '%s' "$EPOCHSECONDS" || return $?; }
	function __get_epoch_time { printf '%s' "$EPOCHREALTIME" || return $?; }
else
	# Bash < 5
	EPOCH_TIME_FUNCTION=''
	function __get_epoch_seconds { date +%s || return $?; }
	function __get_epoch_time_via_date {
		local time=''
		time="$(date +%s.%N 2>/dev/null)" || return 19 # ENODEV 19 Operation not supported by device
		if [[ -z $time || $time =~ [^.0-9] ]]; then
			# if subseconds is not supported, will output non numeric characters: 1756379172.N
			return 19 # ENODEV 19 Operation not supported by device
		fi
		EPOCH_TIME_FUNCTION='__get_epoch_time_via_date'
		printf '%s' "$time" || return $?
	}
	function __get_epoch_time_via_gdate {
		local time=''
		time="$(gdate +%s.%N 2>/dev/null)" || return 19 # ENODEV 19 Operation not supported by device
		if [[ -z $time || $time =~ [^.0-9] ]]; then
			# if subseconds is not supported, will output non numeric characters: 1756379172.N
			return 19 # ENODEV 19 Operation not supported by device
		fi
		EPOCH_TIME_FUNCTION='__get_epoch_time_via_gdate'
		printf '%s' "$time" || return $?
	}
	function __get_epoch_time_via_perl {
		local time=''
		time="$(perl -MTime::HiRes=time -e 'printf "%.6f\n", time' 2>/dev/null)" || return 19 # ENODEV 19 Operation not supported by device
		if [[ -z $time || $time =~ [^.0-9] ]]; then
			return 19 # ENODEV 19 Operation not supported by device
		fi
		EPOCH_TIME_FUNCTION='__get_epoch_time_via_perl'
		printf '%s' "$time" || return $?
	}
	function __get_epoch_time {
		local time=''
		# fetch
		if [[ -z $EPOCH_TIME_FUNCTION ]]; then
			time="$(__get_epoch_time_via_date || __get_epoch_time_via_gdate || __get_epoch_time_via_perl || :)"
		else
			time="$("$EPOCH_TIME_FUNCTION" || :)"
		fi
		# check
		if [[ -z $time || $time =~ [^.0-9] ]]; then
			__require_upgraded_bash 'missing epoch time support' || return $?
		fi
		# the fallback techniques are not that precise, so they leave multiple trailing zeroes, trim the trailing zeroes
		local -i size
		while [[ $time == *.*0 ]]; do
			size="${#time}"
			time="${time:0:size-1}"
		done
		# return $?
		printf '%s' "$time" || return $?
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
		printf '%s' "$1" || return $?
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
			printf '%s' 1 || return $?
		else
			printf '%s' "$1" || return $?
		fi
	}
fi

# Bash >= 5.3
# Evidently, on CI, some bash 5.3 binaries still don't have fltexpr, as such, don't do a version number check, furthermore, the `enable fltexpr` call is instantaneous anyway, so there is no hit to doing this
if enable fltexpr &>/dev/null; then
	BASH_NATIVE_FLOATING_POINT='yes'
else
	# trunk-ignore(shellcheck/SC2034)
	BASH_NATIVE_FLOATING_POINT='no'
fi
if [[ $BASH_VERSION_MAJOR -eq 5 && $BASH_VERSION_MINOR -ge 3 ]]; then
	BASH_COMMAND_SUBSTITUTION='yes'
else
	BASH_COMMAND_SUBSTITUTION='no'
fi

# Bash >= 5.1, >= 4, < 4
if [[ $BASH_VERSION_MAJOR -eq 5 && $BASH_VERSION_MINOR -ge 1 ]]; then
	# bash >= 5.1
	BASH_NATIVE_UPPERCASE_SUFFIX='@U'
	BASH_NATIVE_LOWERCASE_SUFFIX='@L'
	function __get_uppercase_first_letter {
		# trim -- prefix
		if [[ ${1-} == '--' ]]; then
			shift
		fi
		# proceed
		printf '%s' "${@@u}" || return $?
	}
	function __get_uppercase_string {
		# trim -- prefix
		if [[ ${1-} == '--' ]]; then
			shift
		fi
		# proceed
		printf '%s' "${@@U}" || return $?
	}
	function __get_lowercase_string {
		# trim -- prefix
		if [[ ${1-} == '--' ]]; then
			shift
		fi
		# proceed
		printf '%s' "${@@L}" || return $?
	}
	function __case_insensitive_compare {
		[[ ${1@L} == "${2@L}" ]] || return $?
	}
	function __case_insensitive_compare_pattern {
		# trunk-ignore(shellcheck/SC2053)
		[[ ${1@L} =~ ${2@L} ]] || return $?
	}
	function __case_insensitive_compare_glob {
		# trunk-ignore(shellcheck/SC2053)
		[[ ${1@L} == ${2@L} ]] || return $?
	}
	# Don't shim escaping/quoting as their native behaviour is divergent to intuition.
	# `${var@Q}` is available, but it is strange, `Ben's World` becomes `'Ben'\''s World'`
	# If you want `"Ben's World"`, use `echo-quote` instead.
	# `printf '%q' "$var"` escapes bash-style, e.g. `hello world` => `Ben\'s\ World`
else
	# bash < 5.1
	# @Q is no longer available, however it is strange, so don't shim
	if [[ $BASH_VERSION_MAJOR -eq 4 ]]; then
		BASH_NATIVE_UPPERCASE_SUFFIX='^^'
		BASH_NATIVE_LOWERCASE_SUFFIX=',,'
		# bash >= 4
		function __get_uppercase_first_letter {
			# trim -- prefix
			if [[ ${1-} == '--' ]]; then
				shift
			fi
			# proceed
			printf '%s' "${@^}" || return $?
		}
		function __get_uppercase_string {
			# trim -- prefix
			if [[ ${1-} == '--' ]]; then
				shift
			fi
			# proceed
			printf '%s' "${@^^}" || return $?
		}
		function __get_lowercase_string {
			# trim -- prefix
			if [[ ${1-} == '--' ]]; then
				shift
			fi
			# proceed
			printf '%s' "${@,,}" || return $?
		}
		function __case_insensitive_compare {
			[[ ${1,,} == "${2,,}" ]] || return $?
		}
		function __case_insensitive_compare_pattern {
		# trunk-ignore(shellcheck/SC2053)
			[[ ${1,,} =~ ${2,,} ]] || return $?
		}
		function __case_insensitive_compare_glob {
		# trunk-ignore(shellcheck/SC2053)
			[[ ${1,,} == ${2,,} ]] || return $?
		}
	else
		# bash < 4
		BASH_NATIVE_UPPERCASE_SUFFIX=''
		BASH_NATIVE_LOWERCASE_SUFFIX=''
		# bash versions prior to v4 also do not have:
		# `declare -u`: -u	to convert NAMEs to upper case on assignment
		# `declare -l`: -l	to convert NAMEs to lower case on assignment
		function __get_uppercase_first_letter {
			# trim -- prefix
			if [[ ${1-} == '--' ]]; then
				shift
			fi
			# proceed
			while [[ $# -ne 0 ]]; do
				local input="$1"
				local first_char="${input:0:1}" rest="${input:1}" result
				first_char="$(tr '[:lower:]' '[:upper:]' <<<"$first_char")" || return $?
				printf '%s' "$first_char$rest" || return $?
				shift
			done
		}
		function __get_uppercase_string {
			# trim -- prefix
			if [[ ${1-} == '--' ]]; then
				shift
			fi
			# proceed
			while [[ $# -ne 0 ]]; do
				printf '%s' "$1" | tr '[:lower:]' '[:upper:]' || return $?
				shift
			done
		}
		function __get_lowercase_string {
			# trim -- prefix
			if [[ ${1-} == '--' ]]; then
				shift
			fi
			# proceed
			while [[ $# -ne 0 ]]; do
				printf '%s' "$1" | tr '[:upper:]' '[:lower:]' || return $?
				shift
			done
		}
		function __case_insensitive_compare () (
			shopt -s nocasematch
			[[ $1 == "$2" ]] || return $?
		)
		function __case_insensitive_compare_pattern () (
			shopt -s nocasematch
			# trunk-ignore(shellcheck/SC2053)
			[[ $1 =~ $2 ]] || return $?
		)
		function __case_insensitive_compare_glob () (
			shopt -s nocasematch
			# trunk-ignore(shellcheck/SC2053)
			[[ $1 == $2 ]] || return $?
		)
	fi
fi

# bash >= 4.2
# p.  Negative subscripts to indexed arrays, previously errors, now are treated
#     as offsets from the maximum assigned index + 1.
# q.  Negative length specifications in the `${var:offset:length}` expansion,
#     previously errors, are now treated as offsets from the variable.'s end
# `[[ -v varname ]]` (introduced bash 4.2) is not used as its behaviour is inconsistent to expectations and across versions <-- how is it inconsistent? perhaps we can workaround it?
# bash 3.2, 4.0, 4.1 will have `local z; declare -p z` will result in `declare -- z=""`, this is because on these bash versions, `local z` is actually `local z=` so the var is actually set
# bash 4.2 will have `local z; declare -p z` will result in `declare: z: not found`
# bash 4.4+ will have `local z; declare -p z` will result in `declare -- z`
# `set -u` has no effect
if [[ $BASH_VERSION_MAJOR -lt 4 || ($BASH_VERSION_MAJOR -eq 4 && $BASH_VERSION_MINOR -le 1) ]]; then
	BASH_DECLARED_VARS_ARE_ALWAYS_DEFINED='yes'
else
	# trunk-ignore(shellcheck/SC2034)
	BASH_DECLARED_VARS_ARE_ALWAYS_DEFINED='no'
fi
if [[ $BASH_VERSION_MAJOR -lt 4 || ($BASH_VERSION_MAJOR -eq 4 && $BASH_VERSION_MINOR -lt 4) ]]; then
	BASH_DECLARED_ARRAYS_ARE_ALWAYS_DEFINED='yes'
else
	# trunk-ignore(shellcheck/SC2034)
	BASH_DECLARED_ARRAYS_ARE_ALWAYS_DEFINED='no'
fi
if [[ $BASH_VERSION_MAJOR -gt 4 || ($BASH_VERSION_MAJOR -eq 4 && $BASH_VERSION_MINOR -ge 3) ]]; then
	# bash 4.3 and above
	# > This document details the changes between this version, `bash-4.3-alpha`, and the previous version, `bash-4.2-release`.
	# > ddddd. Fixed a bug that caused `printf`'s `%q` format specifier not to quote a tilde even if it appeared in a location where it would be subject to tilde expansion.
	BASH_PRINTF_Q_ESCAPES_TILDE='yes'
else
	# trunk-ignore(shellcheck/SC2034)
	BASH_PRINTF_Q_ESCAPES_TILDE='no'
fi
if [[ $BASH_VERSION_MAJOR -eq 4 && $BASH_VERSION_MINOR -eq 3 ]]; then
	# function fn { local var; local -a arr; declare -p var arr || :; __get_var_declaration var arr a; }; fn
	# bash 4.3:
	# bash-4.3.30: declare: var: not found
	# bash-4.3.30: declare: arr: not found
	# declare -- var
	# declare -a arr=...
	BASH_CAN_DECLARE_P_VAR='no'
	function __get_var_declaration {
		# process
		local GET_VAR_DECLARATION__fodder GET_VAR_DECLARATION__declaration GET_VAR_DECLARATION__missing=()
		GET_VAR_DECLARATION__fodder="$(declare -p)"
		while [[ $# -ne 0 ]]; do
			if [[ $GET_VAR_DECLARATION__fodder =~ declare\ (-[a-zA-Z]*|--)\ $1(=|$'\n'|$) ]]; then
				GET_VAR_DECLARATION__declaration="${BASH_REMATCH[0]}"
				if [[ $GET_VAR_DECLARATION__declaration == *= ]]; then
					GET_VAR_DECLARATION__declaration+='…' # as we cannot get a multiline value, or a value that includes declare, just be simple, which is good enough for our use cases
				fi
				printf '%s\n' "$GET_VAR_DECLARATION__declaration" || return $?
			else
				GET_VAR_DECLARATION__missing+=("$1")
			fi
			shift
		done
		if [[ ${#GET_VAR_DECLARATION__missing[@]} -ne 0 ]]; then
			local GET_VAR_DECLARATION__item
			for GET_VAR_DECLARATION__item in "${GET_VAR_DECLARATION__missing[@]}"; do
				printf '%s: declare: %s: not found\n' "$0" "$GET_VAR_DECLARATION__item" >&2 || :
			done
			return 1 # declare -p returns 1 so do the same
		fi
	}
	function __is_var_defined__internal {
		[[ "$(__get_var_declaration "$1" 2>/dev/null)" == *'='* ]] || return 1
	}
	function __is_array__internal {
		[[ "$(__get_var_declaration "$1" 2>/dev/null)" == 'declare -a '* ]] || return 1
	}
else
	# function fn { local var; local -a arr; declare -p var arr || :; __get_var_declaration var arr a; }; fn
	# bash 4.4:
	# declare -- var
	# declare -a arr
	# declare -- var
	# declare -a arr
	# bash 4.2:
	# declare -- var
	# declare -a arr='()'
	# declare -- var
	# declare -a arr='()'
	# bash 4.0:
	# declare -- var=""
	# declare -a arr='()'
	# declare -- var=""
	# declare -a arr='()'
	# trunk-ignore(shellcheck/SC2034)
	BASH_CAN_DECLARE_P_VAR='yes'
	function __get_var_declaration {
		declare -p "$@" || return $?
	}
	if [[ $BASH_COMMAND_SUBSTITUTION == 'yes' ]]; then
		function __is_var_defined__internal {
			# trunk-ignore(shfmt/parse)
			[[ "${ declare -p "$1" 2>/dev/null || return $?; }" == *'='* ]] || return 1
		}
		function __is_array__internal {
			[[ "${ declare -p "$1" 2>/dev/null || return $?; }" == 'declare -a '* ]] || return 1
		}
	else
		function __is_var_defined__internal {
			[[ "$(declare -p "$1" 2>/dev/null)" == *'='* ]] || return 1
		}
		function __is_array__internal {
			[[ "$(declare -p "$1" 2>/dev/null)" == 'declare -a '* ]] || return 1
		}
	fi
fi
if [[ $BASH_COMMAND_SUBSTITUTION == 'yes' ]]; then
	function __is_function_defined__internal {
		[[ "${ type -t "$1" || return $?; }" == 'function' ]] || return 1
	}
	function __is_subshell_function__internal {
		[[ "${ declare -f "$1" || return $?; }" == "$1"$' () \n{ \n    ('* ]] || return 1
	}
else
	function __is_function_defined__internal {
		[[ "$(type -t "$1")" == 'function' ]] || return 1
	}
	function __is_subshell_function__internal {
		# surprisingly despite the `declare -p <var>` bug in bash 4.3, `declare -f <fn>` works fine
		# don't assign $1 to a variable, as then that means the variable name could conflict with the evaluation from the declare
		# test "$(declare -f "$1")" == "$1"$' () \n{ \n    ('
		[[ "$(declare -f "$1")" == "$1"$' () \n{ \n    ('* ]] || return 1 # explicit `|| return` required to prevent ERR trap from firing, which is important here as it is used within our ERR trap
	}
fi

function __is_var_declared {
	__affirm_length_defined $# 'variable name' || return $?
	while [[ $# -ne 0 ]]; do
		__affirm_variable_name "$1" || return $?
		[[ -n ${!1-} ]] || __get_var_declaration "$1" &>/dev/null || return $? # do a performant initial check for typical use cases, falling back to a comprehensive but slower check for all use cases
		shift
	done
	return 0
}
function __is_var_defined {
	__affirm_length_defined $# 'variable name' || return $?
	while [[ $# -ne 0 ]]; do
		__affirm_variable_name "$1" || return $?
		[[ -n ${!1-} ]] || __is_var_defined__internal "$1" || return $? # do a performant initial check for typical use cases, falling back to a comprehensive but slower check for all use cases
		shift
	done
	return 0
}
function __is_var_set { # b/c alias
	__is_var_defined "$@" || return $?
}

function __is_function_defined {
	__affirm_length_defined $# 'function name' || return $?
	while [[ $# -ne 0 ]]; do
		__affirm_variable_name "$1" 'function name' || return $?
		__is_function_defined__internal "$1" || return $?
		shift
	done
	return 0
}

function __is_subshell_function {
	__affirm_length_defined $# 'function name' || return $?
	while [[ $# -ne 0 ]]; do
		__affirm_variable_name "$1" 'function name' || return $?
		__is_subshell_function__internal "$1" || return $?
		shift
	done
	return 0
}

# NOTE:
# if you do `local arr=(); a='string'` then `declare -p arr` will report `arr` as an array with a single element
# to avoid that, you must do `local arr; a='string'` as such, never mangling types; or use separate variables (safe and explicit)
function __is_array {
	__affirm_length_defined $# 'variable name' || return $?
	while [[ $# -ne 0 ]]; do
		__affirm_variable_name "$1" || return $?
		__is_array__internal "$1" || return $?
		shift
	done
	return 0
}
# This `__is_array` function is where the 5.1.16(1)-release (x86_64-pc-linux-gnu) return insanity started...
# just doing `|| return` would result in the `__dump` `if __is_array ...; then` call always having exit status of `0`, however an explicit return number or using `return $?` resolves it

function __is_sparse_array {
	__affirm_length_defined $# 'variable reference' || return $?
	# no conflict checks here, but should be fine, whatever
	local IS_SPARSE_ARRAY__indices=()
	local -i IS_SPARSE_ARRAY__size IS_SPARSE_ARRAY__last_index IS_SPARSE_ARRAY__size_minus_one
	while [[ $# -ne 0 ]]; do
		__is_array "$1" || return $? # do not do affirm, as that ruins so many downstream outputs
		# now that we know it is an array, verify the last index is the index count minus one
		eval 'IS_SPARSE_ARRAY__indices=("${!'"$1"'[@]}")' || return 1
		# remove $1
		shift
		# now detect if it is a sparse array or not
		IS_SPARSE_ARRAY__size="${#IS_SPARSE_ARRAY__indices[@]}"
		if [[ $IS_SPARSE_ARRAY__size -eq 0 ]]; then
			# empty array is not sparse
			return 1
		fi
		IS_SPARSE_ARRAY__last_index="${IS_SPARSE_ARRAY__indices[IS_SPARSE_ARRAY__size - 1]}"
		IS_SPARSE_ARRAY__size_minus_one=$((IS_SPARSE_ARRAY__size - 1))
		if [[ $IS_SPARSE_ARRAY__last_index -eq $IS_SPARSE_ARRAY__size_minus_one ]]; then
			# if the last index is the size minus one, then it is not sparse
			return 1
		fi
		# it is actually sparse, as it is an non-zero-length array, and the last index is not the size minus one
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

# has_array_capability -- check if all capability is provided by the current bash version
# EPROTONOSUPPORT 43 Protocol not supported
function __has_array_capability {
	local HAS_ARRAY_CAPABILITY__item
	for HAS_ARRAY_CAPABILITY__item in "$@"; do
		case "$HAS_ARRAY_CAPABILITY__item" in
		'--') : ;; # ignore
		'associative'*) [[ $BASH_HAS_NATIVE_ASSOCIATIVE_ARRAY == 'yes' ]] || return 43 ;;
		'mapfile'*) [[ $BASH_HAS_NATIVE_MAPFILE == 'yes' ]] || return 43 ;;
		'readarray'*) [[ $BASH_HAS_NATIVE_READARRAY == 'yes' ]] || return 43 ;;
		'empty'*) [[ $BASH_HAS_NATIVE_EMPTY_ARRAY_ACCESS == 'yes' ]] || return 43 ;;
		*) __unrecognised_flag "$HAS_ARRAY_CAPABILITY__item" || return $? ;;
		esac
	done
}

# __require_array -- require a capability to be provided by the current bash version, otherwise fail
function __require_array {
	if ! __has_array_capability "$@"; then
		__require_upgraded_bash "missing array $* support" || return $?
	fi
}

if [[ $BASH_VERSION_MAJOR -ge 5 ]]; then
	# bash >= 5
	BASH_HAS_NATIVE_EMPTY_ARRAY_ACCESS=yes
	BASH_HAS_NATIVE_READARRAY=yes
	BASH_HAS_NATIVE_MAPFILE=yes
	if [[ $BASH_VERSION_MINOR -ge 1 ]]; then
		# bash >= 5.1
		BASH_HAS_NATIVE_ASSOCIATIVE_ARRAY=yes
	else
		# bash 5.0
		BASH_HAS_NATIVE_ASSOCIATIVE_ARRAY=no
	fi
elif [[ $BASH_VERSION_MAJOR -ge 4 ]]; then
	# note that these versions do not support `-d <delim>` or `-t` options with mapfile
	# bash >= 4
	BASH_HAS_NATIVE_READARRAY=yes
	BASH_HAS_NATIVE_MAPFILE=yes
	BASH_HAS_NATIVE_ASSOCIATIVE_ARRAY=no
	if [[ $BASH_VERSION_MINOR -ge 4 ]]; then
		# bash >= 4.4
		# finally supports nounset without crashing on defined empty arrays
		BASH_HAS_NATIVE_EMPTY_ARRAY_ACCESS=yes
	else
		# bash 4.0, 4.1, 4.2, 4.3
		BASH_HAS_NATIVE_EMPTY_ARRAY_ACCESS=no
		set +u # disable nounset to prevent crashes on empty arrays
	fi
elif [[ $BASH_VERSION_MAJOR -ge 3 ]]; then
	# bash >= 3
	BASH_HAS_NATIVE_EMPTY_ARRAY_ACCESS=no
	BASH_HAS_NATIVE_READARRAY=no
	BASH_HAS_NATIVE_MAPFILE=no
	BASH_HAS_NATIVE_ASSOCIATIVE_ARRAY=no
	set +u # disable nounset to prevent crashes on empty arrays
	# @todo implement support for all options
	function mapfile {
		if __command_exists -- dorothy-warnings; then
			dorothy-warnings add --code='mapfile' --bold=' has been deprecated in favor of ' --code='__split' || :
		fi
		local MAPFILE__delim=$'\n' MAPFILE__t='no' MAPFILE__variable_name='' MAPFILE__reply
		while :; do
			case "$1" in
			'-t')
				MAPFILE__t='yes'
				shift # trim -t
				;;
			'-td')
				MAPFILE__t='yes'
				shift # trim -td
				MAPFILE__delim="$1"
				shift # trim delim
				;;
			'-d')
				shift # trim -d
				MAPFILE__delim="$1"
				shift # trim delim
				;;
			'-'*)
				__print_lines \
					"mapfile[shim]: $1: invalid option" \
					'mapfile[shim]: usage: mapfile -t [-d delim] <array>' >&2 || :
				return 2 # that's what native mapfile returns
				;;
			*)
				if [[ -z $MAPFILE__variable_name ]]; then
					# support with and without squigglies for these references
					__dereference --source="$1" --name={MAPFILE__variable_name} || return $?
				else
					__print_lines \
						"mapfile[shim]: unknown argument: $1" \
						'mapfile[shim]: usage: mapfile -t [-d delim] <array>' >&2 || :
					return 2 # that's what native mapfile returns
				fi
				;;
			esac
		done
		if [[ -z $MAPFILE__variable_name ]]; then
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
		eval "$MAPFILE__variable_name=()" || return 104 # ENOTRECOVERABLE 104 State not recoverable
		while IFS= read -rd "$MAPFILE__delim" MAPFILE__reply || [[ -n $MAPFILE__reply ]]; do
			eval "${MAPFILE__variable_name}+=(\"\${MAPFILE__reply}\")" || return 104 # ENOTRECOVERABLE 104 State not recoverable
		done
	}
fi

# =============================================================================
# Bash Essential Toolkit

# -------------------------------------
# Errors Toolkit

function __unrecognised_flag {
	if [[ $# -ne 1 ]]; then
		__print_lines "ERROR: ${FUNCNAME[0]}: Expected a single argument, but $(__dump --value=$# || :) were provided." >&2 || :
		return 22
	fi
	__print_lines "ERROR: ${FUNCNAME[1]}: An unrecognised flag was provided: $1" >&2 || :
	return 22 # EINVAL 22 Invalid argument
}

function __unrecognised_argument {
	if [[ $# -ne 1 ]]; then
		__print_lines "ERROR: ${FUNCNAME[0]}: Expected a single argument, but $(__dump --value=$# || :) were provided." >&2 || :
		return 22
	fi
	__print_lines "ERROR: ${FUNCNAME[1]}: An unrecognised argument was provided: $1" >&2 || :
	return 22 # EINVAL 22 Invalid argument
}

function __unrecognised_arguments {
	if [[ $# -ne 0 ]]; then
		__print_lines "ERROR: ${FUNCNAME[1]}: Unrecognised arguments ere provided: $*" >&2 || :
		return 22 # EINVAL 22 Invalid argument
	fi
}

# affirm the mode value is a valid mode
# __affirm_value_is_valid_write_mode <mode-value>
function __affirm_value_is_valid_write_mode {
	if [[ $# -ne 1 ]]; then
		__print_lines "ERROR: ${FUNCNAME[0]}: Expected a single argument, but $(__dump --value=$# || :) were provided." >&2 || :
		return 22
	fi
	case "$1" in
	'' | 'prepend' | 'append' | 'overwrite') return 0 ;; # valid modes
	*)
		__print_lines "ERROR: ${FUNCNAME[1]}: An invalid mode was provided: $1" >&2 || :
		return 22 # EINVAL 22 Invalid argument
		;;
	esac
}

# affirm the value is defined
# __affirm_value_is_defined <value> <description>
function __affirm_value_is_defined {
	if [[ $# -ne 1 && $# -ne 2 ]]; then
		__print_lines "ERROR: ${FUNCNAME[0]}: Expected one or two arguments, but $(__dump --value=$# || :) were provided." >&2 || :
		return 22
	fi
	if [[ -z $1 ]]; then
		__print_lines "ERROR: ${FUNCNAME[1]}: A ${2:-"value"} must be provided." >&2 || :
		return 22 # EINVAL 22 Invalid argument
	fi
}

# affirm the value is undefined
# __affirm_value_is_undefined <value> <description>
function __affirm_value_is_undefined {
	if [[ $# -ne 1 && $# -ne 2 ]]; then
		__print_lines "ERROR: ${FUNCNAME[0]}: Expected one or two arguments, but $(__dump --value=$# || :) were provided." >&2 || :
		return 22
	fi
	if [[ -n $1 ]]; then
		__print_lines "ERROR: ${FUNCNAME[1]}: A ${2:-"value"} must not be already defined, it was: $(__dump --value="$1" || :)" >&2 || :
		return 22 # EINVAL 22 Invalid argument
	fi
}

# affirm the value is a version number
# __affirm_value_is_version_number <value> <description>
function __affirm_value_is_version_number {
	if [[ $# -ne 1 && $# -ne 2 ]]; then
		__print_lines "ERROR: ${FUNCNAME[0]}: Expected one or two arguments, but $(__dump --value=$# || :) were provided." >&2 || :
		return 22
	fi
	if ! __is_version_number "$1"; then
		__print_lines "ERROR: ${FUNCNAME[1]}: The ${2:-"value"} must be a version number, it was: $(__dump --value="$1" || :)" >&2 || :
		return 22 # EINVAL 22 Invalid argument
	fi
}

# affirm the value is an integer
# __affirm_value_is_integer <value> <description>
function __affirm_value_is_integer {
	if [[ $# -ne 1 && $# -ne 2 ]]; then
		__print_lines "ERROR: ${FUNCNAME[0]}: Expected one or two arguments, but $(__dump --value=$# || :) were provided." >&2 || :
		return 22
	fi
	if ! __is_integer "$1"; then
		__print_lines "ERROR: ${FUNCNAME[1]}: The ${2:-"value"} must be an integer, it was: $(__dump --value="$1" || :)" >&2 || :
		return 22 # EINVAL 22 Invalid argument
	fi
}

# affirm the value is a positive integer
# __affirm_value_is_positive_integer <value> <description>
function __affirm_value_is_positive_integer {
	if [[ $# -ne 1 && $# -ne 2 ]]; then
		__print_lines "ERROR: ${FUNCNAME[0]}: Expected one or two arguments, but $(__dump --value=$# || :) were provided." >&2 || :
		return 22
	fi
	if ! __is_positive_integer "$1"; then
		__print_lines "ERROR: ${FUNCNAME[1]}: The ${2:-"value"} must be a positive integer, it was: $(__dump --value="$1" || :)" >&2 || :
		return 22 # EINVAL 22 Invalid argument
	fi
}

# affirm value is greater than one
# __affirm_length_defined <value> <description>
function __affirm_length_defined {
	if [[ $# -ne 1 && $# -ne 2 ]]; then
		__print_lines "ERROR: ${FUNCNAME[0]}: Expected one or two arguments, but $(__dump --value=$# || :) were provided." >&2 || :
		return 22
	fi
	# don't bother with positive integer check, as that is too strict for this, as this only ever, and should only ever receive $# computations
	# if ! [[ $1 =~ ^[0-9]+$ ]]; then
	# 	__print_lines "ERROR: ${FUNCNAME[1]}: The length of ${2:-"value"} must be a positive integer, it was: $(__dump --value="$1" || :)" >&2 || :
	# 	return 22 # EINVAL 22 Invalid argument
	# fi
	if [[ $1 -eq 0 ]]; then # `'' -eq 0` is true
		__print_lines "ERROR: ${FUNCNAME[1]}: At least one ${2:-"value"} must be provided, none were." >&2 || :
		__stack >&2 || :
		return 22 # EINVAL 22 Invalid argument
	fi
}

# affirm variable is defined
# __affirm_variable_is_defined <variable-name>
function __affirm_variable_is_defined {
	if [[ $# -ne 1 && $# -ne 2 ]]; then
		__print_lines "ERROR: ${FUNCNAME[0]}: Expected one or two arguments, but $(__dump --value=$# || :) were provided." >&2 || :
		return 22
	fi
	if [[ -z $1 ]]; then
		__print_lines "ERROR: ${FUNCNAME[1]}: A ${2:-"variable name"} must be provided." >&2 || :
		return 22 # EINVAL 22 Invalid argument
	fi
	if ! __is_var_defined "$1"; then
		__print_lines "ERROR: ${FUNCNAME[1]}: The ${2:-"variable name"} $1 must be defined." >&2 || :
		return 22 # EINVAL 22 Invalid argument
	fi
}

# affirm function is defined
# __affirm_function_is_defined <function-name>
function __affirm_function_is_defined {
	if [[ $# -ne 1 && $# -ne 2 ]]; then
		__print_lines "ERROR: ${FUNCNAME[0]}: Expected one or two arguments, but $(__dump --value=$# || :) were provided." >&2 || :
		return 22
	fi
	if [[ -z $1 ]]; then
		__print_lines "ERROR: ${FUNCNAME[1]}: A ${2:-"function name"} must be provided." >&2 || :
		return 22 # EINVAL 22 Invalid argument
	fi
	if ! __is_function_defined "$1"; then
		__print_lines "ERROR: ${FUNCNAME[1]}: The ${2:-"function name"} $1 must be defined." >&2 || :
		return 78 # ENOSYS 78 Function not implemented
	fi
}

# affirm variable is an array
# __affirm_variable_is_array <variable-name>
function __affirm_variable_is_array {
	if [[ $# -ne 1 && $# -ne 2 ]]; then
		__print_lines "ERROR: ${FUNCNAME[0]}: Expected one or two arguments, but $(__dump --value=$# || :) were provided." >&2 || :
		return 22
	fi
	if [[ -z $1 ]]; then
		__print_lines "ERROR: ${FUNCNAME[1]}: A ${2:-"variable name"} must be provided." >&2 || :
		return 22 # EINVAL 22 Invalid argument
	fi
	if ! __is_array "$1"; then # ignore positive integer check, as that is too strict for this
		__print_lines "ERROR: ${FUNCNAME[1]}: The ${2:-"variable name"} $1 must be an array." >&2 || :
		return 22 # EINVAL 22 Invalid argument
	fi
}

# affirm <variable-name> is a valid variable name, not a reference (a variable named wrapped in squigglies), nor an invalid pattern
# __affirm_variable_name <variable-name>
function __affirm_variable_name {
	if [[ $# -ne 1 && $# -ne 2 ]]; then
		__print_lines "ERROR: ${FUNCNAME[0]}: Expected one or two arguments, but $(__dump --value=$# || :) were provided." >&2 || :
		return 22
	fi
	if [[ -z $1 ]]; then
		__print_lines "ERROR: ${FUNCNAME[1]}: A ${2:-"variable name"} must be provided." >&2 || :
		return 22 # EINVAL 22 Invalid argument
	fi
	if ! [[ $1 =~ ^[_a-zA-Z0-9]+$ ]]; then
		if [[ ${1:0:1} == '{' ]]; then
			__print_lines "ERROR: ${FUNCNAME[1]}: Invalid ${2:-"variable name"}, remove the squigglies: $1" >&2 || :
			return 22 # EINVAL 22 Invalid argument
		fi
		# even though : and - can be literals, they are not valid as variable names
		# don't accept array keys/indexes, as this will end up with invalid logic somewhere down the line, instead pass it over as an input like so:
		# before: __fn --source={arr[0]}
		# after:  __fn -- "${arr[0]}"
		__print_lines "ERROR: ${FUNCNAME[1]}: Invalid ${2:-"variable name"}: $1" >&2 || :
		return 22 # EINVAL 22 Invalid argument
	fi
}

# affirm the array is defined
# __affirm_array_is_defined <array> <description>
# function __affirm_array_is_defined {
# 	local AFFIRM_ARRAY_IS_DEFINED__item="$1" AFFIRM_ARRAY_IS_DEFINED__reference
# 	__dereference --source="$AFFIRM_ARRAY_IS_DEFINED__item" --name={AFFIRM_ARRAY_IS_DEFINED__reference} || return $?
# 	if ! __is_array "$AFFIRM_ARRAY_IS_DEFINED__reference" || eval "[[ \${#${AFFIRM_ARRAY_IS_DEFINED__reference}[@]} -eq 0 ]]"; then
# 		__print_lines "ERROR: ${FUNCNAME[1]}: At least one ${2:-"value"} must be provided." >&2 || :
# 		return 22 # EINVAL 22 Invalid argument
# 	fi
# }

# use this to ensure that the prior command's exit status bubbles a failure, regardless of whether errexit is on or off:
# __return $? || return $?
# in your `__*` functions instead of this mess:
# status=$?; if [[ $status -ne 0 ]]; then return $status; fi
# this is all necessary as just doing this disables errexit in `__fn`:
# __fn || return $?
#
# use this to ensure the touch always functions and the failure status is persisted:
# >(tee -a -- "${samasama[@]}" 2>&1; __return $? -- touch "$semaphore")
# instead of this mess:
# >(if tee -a -- "${samasama[@]}" 2>&1; then touch "$semaphore"; else status=$?; touch "$semaphore"; return "$status"; fi)
# note that this disabled errexit on the eval'd code
function __return {
	# `__return`
	local -i RETURN__original_exit_status="$?"
	if [[ $# -eq 0 ]]; then
		return "$RETURN__original_exit_status"
	fi

	# `__return <positive-integer>`
	if [[ $# -eq 1 ]]; then
		return "$1"
	fi

	# `__return [...<exit-status>] [-- <...command>`
	local RETURN__item RETURN__status=0 RETURN__invoke_only_on_failure=no RETURN__invoke_command=()
	while [[ $# -ne 0 ]]; do
		RETURN__item="$1"
		shift
		case "$RETURN__item" in
		'--invoke-only-on-failure') RETURN__invoke_only_on_failure=yes ;;
		'--')
			RETURN__invoke_command+=("$@")
			shift $#
			break
			;;
		[0-9]*)
			__affirm_value_is_positive_integer "$RETURN__item" 'exit status' || return $?
			# it is an exit status, update our result exit status if it is still zero
			if [[ $RETURN__status -eq 0 ]]; then
				RETURN__status="$RETURN__item"
			fi
			;;
		'--'*) __unrecognised_flag "$RETURN__item" || return $? ;;
		*) __unrecognised_argument "$RETURN__item" || return $? ;;
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
			return $?
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
	local -i actual_status="$?" ignore_status
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
	__ignore_exit_status 141 || return $?
}

# exit on a specific exit status
function __exit_on_exit_status {
	local -i status="$?"
	local item
	for item in "$@"; do
		if [[ $status -eq $item ]]; then
			exit 0
		fi
	done
	return 0
}

# -------------------------------------
# Value Toolkit

function __is_positive_integer {
	__affirm_length_defined $# 'input' || return $?
	while [[ $# -ne 0 ]]; do
		[[ $1 =~ ^[+]?[0-9]+$ ]] || return $?
		shift
	done
}

# or you if you already know it is an integer, you can just do: [[ $1 -lt 0 ]]
function __is_negative_integer {
	__affirm_length_defined $# 'input' || return $?
	while [[ $# -ne 0 ]]; do
		[[ $1 =~ ^-[0-9]+$ ]] || return $?
		shift
	done
}

function __is_integer {
	__affirm_length_defined $# 'input' || return $?
	while [[ $# -ne 0 ]]; do
		[[ $1 =~ ^[+-]?[0-9]+$ ]] || return $?
		shift
	done
}

function __is_digit {
	__affirm_length_defined $# 'input' || return $?
	while [[ $# -ne 0 ]]; do
		[[ $1 =~ ^[0-9]$ ]] || return $?
		shift
	done
}

function __is_number {
	__affirm_length_defined $# 'input' || return $?
	while [[ $# -ne 0 ]]; do
		[[ $1 =~ ^[-]?[0-9]+(\.[0-9]+)?$ ]] || return $?
		shift
	done
}

function __is_version_number {
	__affirm_length_defined $# 'input' || return $?
	while [[ $# -ne 0 ]]; do
		[[ $1 =~ ^[.0-9]+$ ]] || return $?
		shift
	done
}

function __is_even {
	__affirm_length_defined $# 'input' || return $?
	local input
	while [[ $# -ne 0 ]]; do
		input="$1"
		shift
		__affirm_value_is_integer "$input" 'input' || return $?
		[[ $((input % 2)) -eq 0 ]] || return $?
	done
}

function __is_odd {
	__affirm_length_defined $# 'input' || return $?
	local input
	while [[ $# -ne 0 ]]; do
		input="$1"
		shift
		__affirm_value_is_integer "$input" 'input' || return $?
		[[ $((input % 2)) -ne 0 ]] || return $?
	done
}

function __is_zero {
	__affirm_length_defined $# 'input' || return $?
	local input
	while [[ $# -ne 0 ]]; do
		input="$1"
		shift
		__affirm_value_is_integer "$input" 'input' || return $?
		[[ $input -eq 0 ]] || return $?
	done
}

# Checks that ALL <input>s are of the desired affirmation (affirmative/non-affirmative)
# __is_affirmative [--ignore-empty] [--affirmation=[non-]affirmative] -- ...<input>
function __is_affirmative {
	local IS_AFFIRMATIVE__item IS_AFFIRMATIVE__inputs=() IS_AFFIRMATIVE__ignore_empty='no' IS_AFFIRMATIVE__affirmation='affirmative'
	while [[ $# -ne 0 ]]; do
		IS_AFFIRMATIVE__item="$1"
		shift
		case "$IS_AFFIRMATIVE__item" in
		'--no-ignore-empty'* | '--ignore-empty'*) __flag --source={IS_AFFIRMATIVE__item} --target={IS_AFFIRMATIVE__ignore_empty} --affirmative --coerce || return $? ;;
		'--affirmation=affirmative' | '--affirmation=non-affirmative') IS_AFFIRMATIVE__affirmation="${IS_AFFIRMATIVE__item#*=}" ;;
		'--')
			IS_AFFIRMATIVE__inputs+=("$@")
			shift "$#"
			break
			;;
		'--'*) __unrecognised_flag "$IS_AFFIRMATIVE__item" || return $? ;;
		*) IS_AFFIRMATIVE__inputs+=("$IS_AFFIRMATIVE__item") ;;
		esac
	done
	local IS_AFFIRMATIVE__input IS_AFFIRMATIVE__affirmed='no'
	for IS_AFFIRMATIVE__input in "${IS_AFFIRMATIVE__inputs[@]}"; do
		case "$IS_AFFIRMATIVE__input" in
		'yes' | 'y' | 'true' | 'Y' | 'YES' | 'TRUE')
			if [[ $IS_AFFIRMATIVE__affirmation == 'non-affirmative' ]]; then
				return 1
			fi
			IS_AFFIRMATIVE__affirmed='yes'
			;;
		'no' | 'n' | 'false' | 'N' | 'NO' | 'FALSE')
			if [[ $IS_AFFIRMATIVE__affirmation == 'affirmative' ]]; then
				return 1
			fi
			IS_AFFIRMATIVE__affirmed='yes'
			;;
		'')
			if [[ $IS_AFFIRMATIVE__ignore_empty == 'yes' ]]; then
				continue
			else
				return 91 # ENOMSG 91 No message of desired type
			fi
			;;
		*)
			return 91 # ENOMSG 91 No message of desired type
			;;
		esac
	done
	if [[ $IS_AFFIRMATIVE__affirmed == 'no' ]]; then
		return 91 # ENOMSG 91 No message of desired type
	else
		return 0
	fi
}

# Alias for `__is_affirmative --non-affirmative`
function __is_non_affirmative {
	__is_affirmative --affirmation=non-affirmative "$@" || return $?
}

# check if the input is a special target
# this is beta, and may change later
function __is_special_file {
	local IS_SPECIAL_FILE__target="$1"
	case "$IS_SPECIAL_FILE__target" in
	'0' | 'STDIN' | 'stdin' | '/dev/stdin' | '1' | 'STDOUT' | 'stdout' | '/dev/stdout' | '2' | 'STDERR' | 'stderr' | '/dev/stderr' | 'TTY' | 'tty' | '/dev/tty' | 'NULL' | 'null' | '/dev/null') return 0 ;; # is a special file
	'')
		__print_lines "ERROR: ${FUNCNAME[0]}: An unrecognised target was provided: $IS_SPECIAL_FILE__target" >&2 || :
		return 22 # EINVAL 22 Invalid argument
		;;
	*) __is_positive_integer "$IS_SPECIAL_FILE__target" || return 1 ;; # if it is a positive integer, it is a file descriptor which is a special file, otherwise it's a file target
	esac
}

# this is beta, and may change later
# function __is_stdin_special_file {
# 	local target="$1"
# 	case "$target" in
# 	0 | STDIN | stdin | /dev/stdin) return 0 ;; # is a stdin target
# 	'')
# 		__print_lines "ERROR: ${FUNCNAME[0]}: An unrecognised target was provided: $target" >&2 || :
# 		return 22 # EINVAL 22 Invalid argument
# 		;;
# 	*) return 1 ;; # not a stdin target
# 	esac
# }

# this is beta, and may change later
function __is_tty_special_file {
	case "$1" in
	'TTY' | 'tty' | '/dev/tty') return 0 ;; # is a tty target
	'')
		__print_lines "ERROR: ${FUNCNAME[0]}: An unrecognised target was provided: $1" >&2 || :
		return 22 # EINVAL 22 Invalid argument
		;;
	*) return 1 ;; # not a tty target
	esac
}

# -------------------------------------
# Reference Toolkit

# check if the value is a reference, i.e. starts with `{` and ends with `}`, e.g. `{var_name}`.
function __is_reference {
	__affirm_length_defined $# 'input' || return $?
	while [[ $# -ne 0 ]]; do
		[[ $1 == '{'*'}' && $1 != '{}' ]] || return $?
		shift
	done
}

# @todo consider using this in `__to` and `__do`
# __string_to_variable <string-value> <target-variable-name> [<mode:prepend|append|overwrite>]
function __string_to_variable {
	# trunk-ignore(shellcheck/SC2034)
	local STRING_TO_VARIABLE__value="$1" STRING_TO_VARIABLE__target_variable_name="$2" STRING_TO_VARIABLE__mode="${3-}"
	if __is_array "$STRING_TO_VARIABLE__target_variable_name"; then
		case "$STRING_TO_VARIABLE__mode" in
		'prepend') eval "$STRING_TO_VARIABLE__target_variable_name=(\"\${STRING_TO_VARIABLE__value}\" \"\${${STRING_TO_VARIABLE__target_variable_name}[@]}\")" || return 104 ;; # ENOTRECOVERABLE 104 State not recoverable
		'append') eval "$STRING_TO_VARIABLE__target_variable_name+=(\"\${STRING_TO_VARIABLE__value}\")" || return 104 ;; # ENOTRECOVERABLE 104 State not recoverable
		*) eval "$STRING_TO_VARIABLE__target_variable_name=(\"\${STRING_TO_VARIABLE__value}\")" || return 104 ;; # ENOTRECOVERABLE 104 State not recoverable
		esac
	else
		case "$STRING_TO_VARIABLE__mode" in
		'prepend') eval "$STRING_TO_VARIABLE__target_variable_name=\"\${STRING_TO_VARIABLE__value}\${${STRING_TO_VARIABLE__target_variable_name}}\"" || return 104 ;; # ENOTRECOVERABLE 104 State not recoverable
		'append') eval "$STRING_TO_VARIABLE__target_variable_name+=\"\${STRING_TO_VARIABLE__value}\"" || return 104 ;; # ENOTRECOVERABLE 104 State not recoverable
		*) eval "$STRING_TO_VARIABLE__target_variable_name=\"\${STRING_TO_VARIABLE__value}\"" || return 104 ;; # ENOTRECOVERABLE 104 State not recoverable
		esac
	fi
}

# @todo consider using this in `__to` and `__do`
# __variable_to_variable <source-variable-name> <target-variable-name> [<mode:prepend|append|overwrite>]
function __variable_to_variable {
	local VARIABLE_TO_VARIABLE__source_variable_name="$1" VARIABLE_TO_VARIABLE__target_variable_name="$2" VARIABLE_TO_VARIABLE__mode="${3-}"
	if __is_array "$VARIABLE_TO_VARIABLE__target_variable_name"; then
		if __is_array "$VARIABLE_TO_VARIABLE__source_variable_name"; then
			case "$VARIABLE_TO_VARIABLE__mode" in
			'prepend') eval "$VARIABLE_TO_VARIABLE__target_variable_name=(\"\${${VARIABLE_TO_VARIABLE__source_variable_name}[@]}\" \"\${${VARIABLE_TO_VARIABLE__target_variable_name}[@]}\")" || return 104 ;; # ENOTRECOVERABLE 104 State not recoverable
			'append') eval "$VARIABLE_TO_VARIABLE__target_variable_name+=(\"\${${VARIABLE_TO_VARIABLE__source_variable_name}[@]}\")" || return 104 ;; # ENOTRECOVERABLE 104 State not recoverable
			*) eval "$VARIABLE_TO_VARIABLE__target_variable_name=(\"\${${VARIABLE_TO_VARIABLE__source_variable_name}[@]}\")" || return 104 ;; # ENOTRECOVERABLE 104 State not recoverable
			esac
		else
			case "$VARIABLE_TO_VARIABLE__mode" in
			'prepend') eval "$VARIABLE_TO_VARIABLE__target_variable_name=(\"\${${VARIABLE_TO_VARIABLE__source_variable_name}}\" \"\${${VARIABLE_TO_VARIABLE__target_variable_name}[@]}\")" || return 104 ;; # ENOTRECOVERABLE 104 State not recoverable
			'append') eval "$VARIABLE_TO_VARIABLE__target_variable_name+=(\"\${${VARIABLE_TO_VARIABLE__source_variable_name}}\")" || return 104 ;; # ENOTRECOVERABLE 104 State not recoverable
			*) eval "$VARIABLE_TO_VARIABLE__target_variable_name=(\"\${${VARIABLE_TO_VARIABLE__source_variable_name}}\")" || return 104 ;; # ENOTRECOVERABLE 104 State not recoverable
			esac
		fi
	else
		if __is_array "$VARIABLE_TO_VARIABLE__source_variable_name"; then
			# so far this is only used in __dereference so show __dereference as the name instead
			__print_lines "ERROR: ${FUNCNAME[1]}: Cannot apply an array source $(__dump --value="$VARIABLE_TO_VARIABLE__source_variable_name" || :) to a non-array target $(__dump --value="$VARIABLE_TO_VARIABLE__target_variable_name" || :)." >&2 || :
			return 22 # EINVAL 22 Invalid argument
		else
			case "$VARIABLE_TO_VARIABLE__mode" in
			'prepend') eval "$VARIABLE_TO_VARIABLE__target_variable_name=\"\${${VARIABLE_TO_VARIABLE__source_variable_name}}\${${VARIABLE_TO_VARIABLE__target_variable_name}}\"" || return 104 ;; # ENOTRECOVERABLE 104 State not recoverable
			'append') eval "$VARIABLE_TO_VARIABLE__target_variable_name+=\"\${${VARIABLE_TO_VARIABLE__source_variable_name}}\"" || return 104 ;; # ENOTRECOVERABLE 104 State not recoverable
			*) eval "$VARIABLE_TO_VARIABLE__target_variable_name=\"\${${VARIABLE_TO_VARIABLE__source_variable_name}}\"" || return 104 ;; # ENOTRECOVERABLE 104 State not recoverable
			esac
		fi
	fi
}

function __affirm_empty_mode {
	local AFFIRM_EMPTY_MODE__mode="$1" AFFIRM_EMPTY_MODE__target="$2"
	if [[ -n $AFFIRM_EMPTY_MODE__mode ]]; then
		__print_lines "ERROR: ${FUNCNAME[1]}: The target $(__dump --value="$AFFIRM_EMPTY_MODE__target" || :) is not a variable reference nor file target, so it cannot be used with the mode $(__dump --value="$AFFIRM_EMPTY_MODE__mode" || :)." >&2 || :
		return 22 # EINVAL 22 Invalid argument
	fi
}

function __value_to_tty {
	local VALUE_TO_TTY__value="$1"
	# handle TTY redirects
	if ! __is_tty_special_file "$TERMINAL_OUTPUT_TARGET"; then
		__value_to_target "$VALUE_TO_TTY__value" "$TERMINAL_OUTPUT_TARGET" || return $?
		return 0
	fi
	# TTY is not redirected
	printf '%s' "$VALUE_TO_TTY__value" >>/dev/tty || return $?
}

function __value_to_target {
	local VALUE_TO_TARGET__value="$1" VALUE_TO_TARGET__target="$2" VALUE_TO_TARGET__mode="${3-}"
	# process
	case "$VALUE_TO_TARGET__target" in
	# stdout
	'1' | 'STDOUT' | 'stdout' | '/dev/stdout' | '')
		__affirm_empty_mode "$VALUE_TO_TARGET__mode" "$VALUE_TO_TARGET__target" || return $?
		printf '%s' "$VALUE_TO_TARGET__value" || return $?
		;;
	# stderr
	'2' | 'STDERR' | 'stderr' | '/dev/stderr')
		__affirm_empty_mode "$VALUE_TO_TARGET__mode" "$VALUE_TO_TARGET__target" || return $?
		printf '%s' "$VALUE_TO_TARGET__value" >&2 || return $?
		;;
	# tty
	'TTY' | 'tty' | '/dev/tty')
		# handle TTY redirects
		if ! __is_tty_special_file "$TERMINAL_OUTPUT_TARGET"; then
			__value_to_target "$VALUE_TO_TARGET__value" "$TERMINAL_OUTPUT_TARGET" "$VALUE_TO_TARGET__mode" || return $?
			return 0
		fi
		# TTY is not redirected
		__affirm_empty_mode "$VALUE_TO_TARGET__mode" "$VALUE_TO_TARGET__target" || return $?
		printf '%s' "$VALUE_TO_TARGET__value" >>/dev/tty || return $?
		;;
	# null
	'NULL' | 'null' | '/dev/null') : ;;
	# file descriptor
	[0-9]*)
		__affirm_value_is_positive_integer "$VALUE_TO_TARGET__target" 'file descriptor' || return $?
		__affirm_empty_mode "$VALUE_TO_TARGET__mode" "$VALUE_TO_TARGET__target" || return $?
		printf '%s' "$VALUE_TO_TARGET__value" >&"$VALUE_TO_TARGET__target" || return $?
		;;
	# file target
	*)
		case "$VALUE_TO_TARGET__mode" in
		'prepend')
			local REPLY
			__read_whole <"$VALUE_TO_TARGET__target" || return $?
			printf '%s' "$VALUE_TO_TARGET__value$REPLY" >"$VALUE_TO_TARGET__target" || return $?
			;;
		'append')
			printf '%s' "$VALUE_TO_TARGET__value" >>"$VALUE_TO_TARGET__target" || return $?
			;;
		'' | 'overwrite')
			printf '%s' "$VALUE_TO_TARGET__value" >"$VALUE_TO_TARGET__target" || return $?
			;;
		esac
		;;
	esac
}

# with the reference, trim its squigglies to get its variable name, and apply it to the variable name reference, and affirm there won't be a conflict
# e.g. `my_result=hello; MY_CONTEXT__item={my_result}; __dereference --source="$MY_CONTEXT__item" --name={MY_CONTEXT__reference}; MY_CONTEXT__reference=my_result`
# e.g. `my_result=hello; MY_CONTEXT__item='{my_result}'; __dereference --source="$MY_CONTEXT__item"--value={MY_CONTEXT__value}; MY_CONTEXT__value=hello`
function __dereference {
	local DEREFERENCE__item DEREFERENCE__source_variable_name='' DEREFERENCE__target_name_variable_name='' DEREFERENCE__target_value_variable_name='' DEREFERENCE__size DEREFERENCE__source_prefix='' DEREFERENCE__internal_prefix='' DEREFERENCE__mode=''
	while [[ $# -ne 0 ]]; do
		DEREFERENCE__item="$1"
		shift
		case "$DEREFERENCE__item" in
		'--source={'*'}')
			DEREFERENCE__item="${DEREFERENCE__item#*=}"
			DEREFERENCE__size="${#DEREFERENCE__item}"
			DEREFERENCE__source_variable_name="${DEREFERENCE__item:1:DEREFERENCE__size-2}" # trim starting and trailing squigglies
			DEREFERENCE__source_prefix="${DEREFERENCE__source_variable_name%%__*}__"
			;;
		'--source='*)
			DEREFERENCE__source_variable_name="${DEREFERENCE__item#*=}"
			DEREFERENCE__source_prefix="${DEREFERENCE__source_variable_name%%__*}__"
			;;
		'--name={'*'}')
			DEREFERENCE__item="${DEREFERENCE__item#*=}"
			DEREFERENCE__size="${#DEREFERENCE__item}"
			DEREFERENCE__target_name_variable_name="${DEREFERENCE__item:1:DEREFERENCE__size-2}" # trim starting and trailing squigglies
			DEREFERENCE__internal_prefix="${DEREFERENCE__target_name_variable_name%%__*}__"
			;;
		'--value={'*'}')
			DEREFERENCE__item="${DEREFERENCE__item#*=}"
			DEREFERENCE__size="${#DEREFERENCE__item}"
			DEREFERENCE__target_value_variable_name="${DEREFERENCE__item:1:DEREFERENCE__size-2}" # trim starting and trailing squigglies
			DEREFERENCE__internal_prefix="${DEREFERENCE__target_value_variable_name%%__*}__"
			;;
		'--mode=prepend' | '--mode=append' | '--mode=overwrite' | '--mode=')
			__affirm_value_is_undefined "$DEREFERENCE__mode" 'write mode' || return $?
			DEREFERENCE__mode="${DEREFERENCE__item#*=}"
			;;
		'--append' | '--prepend' | '--overwrite')
			__affirm_value_is_undefined "$DEREFERENCE__mode" 'write mode' || return $?
			DEREFERENCE__mode="${DEREFERENCE__item:2}"
			;;
		'--'*) __unrecognised_flag "$DEREFERENCE__item" || return $? ;;
		*) __unrecognised_argument "$DEREFERENCE__item" || return $? ;;
		esac
	done
	if [[ -z $DEREFERENCE__source_variable_name ]]; then
		__print_lines "ERROR: ${FUNCNAME[0]}: The source variable reference is required." >&2 || :
		return 22 # EINVAL 22 Invalid argument
	fi
	# validate the source reference is valid
	__affirm_variable_name "$DEREFERENCE__source_variable_name" 'source variable reference' || return $?
	__affirm_value_is_valid_write_mode "$DEREFERENCE__mode" || return $?
	# validate that the reference does not use our variable name prefix
	if [[ -n $DEREFERENCE__source_prefix && -n $DEREFERENCE__internal_prefix && $DEREFERENCE__source_prefix == "$DEREFERENCE__internal_prefix" ]]; then
		__print_lines "ERROR: ${FUNCNAME[0]}: To avoid conflicts, the source variable reference [$DEREFERENCE__source_variable_name] must not use the prefix [$DEREFERENCE__internal_prefix]." >&2 || :
		return 22 # EINVAL 22 Invalid argument
	fi
	if [[ -n $DEREFERENCE__target_name_variable_name ]]; then
		__string_to_variable "$DEREFERENCE__source_variable_name" "$DEREFERENCE__target_name_variable_name" "$DEREFERENCE__mode" || return $?
	fi
	if [[ -n $DEREFERENCE__target_value_variable_name ]]; then
		__variable_to_variable "$DEREFERENCE__source_variable_name" "$DEREFERENCE__target_value_variable_name" "$DEREFERENCE__mode" || return $?
	fi
	return 0
}

# -------------------------------------
# Function Toolkit

function __get_function_inner {
	local GET_FUNCTION_INNER__function_code GET_FUNCTION_INNER__left=$'{ \n' GET_FUNCTION_INNER__right=$'\n}'
	GET_FUNCTION_INNER__function_code="$(declare -f "$1")" || return $?
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
	printf '%s' "$GET_FUNCTION_INNER__function_code" || return $?
}

function __get_index_of_parent_function {
	# if it is only this helper function then skip
	if [[ ${#FUNCNAME[@]} -le 1 ]]; then
		return 1
	fi
	local -i index
	local until fns=()
	# skip __has_subshell_function_until which will be index [0]
	fns=("${FUNCNAME[@]:1}")

	# find a match
	for index in "${!fns[@]}"; do
		for until in "$@"; do
			if [[ ${fns[index]} == "$until" ]]; then
				printf '%s' "$index" || return $?
				return 0
			fi
		done
	done
	return 1
}

# `__get_first_parent_that_is_not` and `__get_all_parents_that_are_not` located at https://gist.github.com/balupton/1882c4a9a5d7c535bfe17ff7030c8764

# if this changes, you also need to update `eval-capture`
function __get_context_id {
	# This can get really long, so we need to make it smaller:
	# trunk-ignore(cspell/error)
	# /Users/balupton/.local/share/dorothy/sources/bash.bash: line 2620: /var/folders/3v/fjmy4fyx1p9c28v31vzm8j9r0000gn/T/dorothy/semaphores/[5.3.3] [main][setup_mac_brew][uninstall_encoding][brew_uninstall][clean_brew][eval_helper][run_args_with_optional_elevation][run_args][__refresh_terminal_size][__split] [__do][data-to-reference][--redirect-stdout][SPLIT__fodder_with_discard_exit_status] [19657]: File name too long
	# trunk-ignore(cspell/error)
	# 331 characters: /var/folders/3v/fjmy4fyx1p9c28v31vzm8j9r0000gn/T/dorothy/semaphores/[5.3.3] [main][setup_mac_brew][uninstall_encoding][brew_uninstall][clean_brew][eval_helper][run_args_with_optional_elevation][run_args][__refresh_terminal_size][__split] [__do][data-to-reference][--redirect-stdout][SPLIT__fodder_with_discard_exit_status] [19657]
	# 263 characters: [5.3.3] [main][setup_mac_brew][uninstall_encoding][brew_uninstall][clean_brew][eval_helper][run_args_with_optional_elevation][run_args][__refresh_terminal_size][__split] [__do][data-to-reference][--redirect-stdout][SPLIT__fodder_with_discard_exit_status] [19657]
	# <255 characters: 19657 5.3.3 setup_mac_brew uninstall_encoding brew_uninstall clean_brew eval_helper run_args_with_optional_elevation run_args refresh_terminal_size split do data-to-reference redirect-stdout SPLIT fodder_with_discard_exit_status
	local exclude='[main][__get_context_id][eval_capture][__do][__try][dorothy_try__wrapper]' contexts=() context fn exclude
	for fn in "${FUNCNAME[@]:1}"; do
		if [[ $exclude == *"[$fn]"* ]]; then
			continue
		fi
		contexts=("$fn" "${contexts[@]}") # prepend
	done
	context="$(__get_epoch_seconds || :) $RANDOM $BASH_VERSION_CURRENT ${contexts[*]}"
	if [[ $# -ne 0 ]]; then
		context+=" $*"
	fi
	if [[ ${#context} -gt 255 ]]; then
		context="${context:0:255}"
	fi
	printf '%s' "$context" || return $?
}

# =============================================================================
# Redirection & Error Handling Toolkit

# send the source to the targets, respecting the mode
function __to {
	local TO__item TO__source='' TO__targets=() TO__mode='' TO__coerce='yes'
	while [[ $# -ne 0 ]]; do
		TO__item="$1"
		shift
		case "$TO__item" in
		'--source={'*'}')
			__affirm_value_is_undefined "$TO__source" 'source variable reference' || return $?
			__dereference --source="${TO__item#*=}" --name={TO__source} || return $?
			;;
		'--targets='*) __dereference --source="${TO__item#*=}" --append --value={TO__targets} || return $? ;;
		'--target='*) TO__targets+=("${TO__item#*=}") ;;
		# can't use `__flag` as `__flag` uses `__to`, so the wrong variables will be set due to recursion
		'--no-coerce' | '--coerce=no' | '--no-coerce=yes') TO__coerce=no ;;
		'--coerce' | '--coerce=yes' | '--no-coerce=no') TO__coerce=yes ;;
		'--mode=prepend' | '--mode=append' | '--mode=overwrite' | '--mode=')
			__affirm_value_is_undefined "$TO__mode" 'write mode' || return $?
			TO__mode="${TO__item#*=}"
			;;
		'--append' | '--prepend' | '--overwrite')
			__affirm_value_is_undefined "$TO__mode" 'write mode' || return $?
			TO__mode="${TO__item:2}"
			;;
		'--')
			__affirm_value_is_undefined "$TO__source" 'source variable reference' || return $?
			# they are inputs
			if [[ $# -eq 1 ]]; then
				# a string input
				# trunk-ignore(shellcheck/SC2034)
				local TO__input="$1"
				TO__source='TO__input'
			else
				# an array input
				# trunk-ignore(shellcheck/SC2034)
				local TO__inputs=("$@")
				TO__source='TO__inputs'
			fi
			shift $#
			break
			;;
		'--'*) __unrecognised_flag "$TO__item" || return $? ;;
		*) __unrecognised_argument "$TO__item" || return $? ;;
		esac
	done
	__affirm_variable_is_defined "$TO__source" 'source variable reference' || return $?
	__affirm_value_is_valid_write_mode "$TO__mode" || return $?
	if [[ ${#TO__targets[@]} -eq 0 ]]; then
		TO__targets+=('STDOUT') # default to STDOUT
	fi
	local TO__target TO__source_size
	for TO__target in "${TO__targets[@]}"; do
		__affirm_value_is_defined "$TO__target" 'target' || return $?
		if __is_reference "$TO__target"; then
			__dereference --source="$TO__target" --name={TO__target} || return $?
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
				# as such, never do a `|| ! __is_var_defined "$TO__target"` check here and change the behaviour based on whether the value is declared but undefined, as that introduces too many failures from divergences between bash versions prior to 4.4, as such require the caller to have code that is explicit and avoids such divergent silent failures
				if __is_array "$TO__target"; then #
					# array to array
					case "$TO__mode" in
					'prepend') eval "$TO__target=(\"\${${TO__source}[@]}\" \"\${${TO__target}[@]}\")" || return 104 ;; # ENOTRECOVERABLE 104 State not recoverable
					'append') eval "$TO__target+=(\"\${${TO__source}[@]}\")" || return 104 ;; # ENOTRECOVERABLE 104 State not recoverable
					'' | 'overwrite') eval "$TO__target=(\"\${${TO__source}[@]}\")" || return 104 ;; # ENOTRECOVERABLE 104 State not recoverable
					# mode is already validated
					esac
				else
					eval "TO__source_size=\"\${#${TO__source}[@]}\"" || return 104 # ENOTRECOVERABLE 104 State not recoverable
					if [[ $TO__coerce == 'yes' && $TO__source_size -eq 0 ]]; then
						# array of no elements to empty string
						case "$TO__mode" in
						'prepend') : ;;
						'append') : ;;
						'' | 'overwrite') eval "$TO__target=" || return 104 ;; # ENOTRECOVERABLE 104 State not recoverable
						# mode is already validated
						esac
					elif [[ $TO__coerce == 'yes' && $TO__source_size -eq 1 ]]; then
						# array of single element to string
						case "$TO__mode" in
						'prepend') eval "$TO__target=\"\${${TO__source}[0]}\${${TO__target}}\"" || return 104 ;; # ENOTRECOVERABLE 104 State not recoverable
						'append') eval "$TO__target+=\"\${${TO__source}[0]}\")" || return 104 ;; # ENOTRECOVERABLE 104 State not recoverable
						'' | 'overwrite') eval "$TO__target=\"\${${TO__source}[0]}\"" || return 104 ;; # ENOTRECOVERABLE 104 State not recoverable
						# mode is already validated
						esac
					else
						__print_lines "ERROR: ${FUNCNAME[0]}: If the source $(__dump --value="$TO__source" || :) is an array, then the target $(__dump --value="$TO__target" || :) must be as well:" >&2 || :
						__dump "$TO__source" "$TO__target" >&2 || :
						return 22 # EINVAL 22 Invalid argument
					fi
				fi
			else
				# string to array
				if __is_array "$TO__target"; then
					if [[ $TO__coerce == 'yes' ]]; then
						case "$TO__mode" in
						'prepend') eval "$TO__target=(\"\${${TO__source}}\" \"\${${TO__target}[@]}\")" || return 104 ;; # ENOTRECOVERABLE 104 State not recoverable
						'append') eval "$TO__target+=(\"\${${TO__source}}\")" || return 104 ;; # ENOTRECOVERABLE 104 State not recoverable
						'' | 'overwrite') eval "$TO__target=(\"\${${TO__source}}\")" || return 104 ;; # ENOTRECOVERABLE 104 State not recoverable
						# mode is already validated
						esac
					else
						__print_lines "ERROR: ${FUNCNAME[0]}: If the source $(__dump --value="$TO__source" || :) is a string, then the target $(__dump --value="$TO__target" || :) must be as well:" >&2 || :
						__dump "$TO__source" "$TO__target" >&2 || :
						return 22 # EINVAL 22 Invalid argument
					fi
				else
					# string to string
					case "$TO__mode" in
					'prepend') eval "$TO__target=\"\${${TO__source}}\${${TO__target}}\"" || return 104 ;; # ENOTRECOVERABLE 104 State not recoverable
					'append') eval "$TO__target+=\"\$${TO__source}\"" || return 104 ;; # ENOTRECOVERABLE 104 State not recoverable
					'' | 'overwrite') eval "$TO__target=\"\${${TO__source}}\"" || return 104 ;; # ENOTRECOVERABLE 104 State not recoverable
					# mode is already validated
					esac
				fi
			fi
		else
			# no-ops on null targets
			case "$TO__target" in
			'NULL' | 'null' | '/dev/null') continue ;;
			esac
			# render for the non-null targets
			local TO__value=''
			if __is_array "$TO__source"; then
				eval "TO__source_size=\"\${#${TO__source}[@]}\"" || return 104 # ENOTRECOVERABLE 104 State not recoverable
				if [[ $TO__coerce == 'yes' && $TO__source_size -eq 1 ]]; then
					# array of single element to string
					eval "TO__value=\"\${${TO__source}[0]}\"" || return 104 # ENOTRECOVERABLE 104 State not recoverable
				else
					__print_lines "ERROR: ${FUNCNAME[0]}: If the source $(__dump --value="$TO__source" || :) is an array, then the target $(__dump --value="$TO__target" || :) must be as well:" >&2 || :
					__dump "$TO__source" >&2 || :
					if ! __is_special_file "$TO__target"; then
						__dump "$TO__target" >&2 || :
					fi
					return 22 # EINVAL 22 Invalid argument
				fi
				# don't do this the below commented out code, as it is ambiguous to what should happen when destination a variable, stream, or file:
				# eval "
				# local -i TO__index TO__size
				# for (( TO__index = 0, TO__size = \${#${TO__source}[@]}; TO__index < TO__size; TO__index++ )); do
				# 	TO__value+=\"\${${TO__source}[TO__index]}\"\$'\n'
				# done" || return $?
			else
				eval "TO__value=\"\$${TO__source}\"" || return 104 # ENOTRECOVERABLE 104 State not recoverable
			fi
			# send to target
			__value_to_target "$TO__value" "$TO__target" "$TO__mode" || return $?
		fi
	done
}

#
# @todo re-add samasama support for possible performance improvement: https://gist.github.com/balupton/32bfc21702e83ad4afdc68929af41c23
# @todo consider using `FD>&-` instead of `FD>/dev/null`
function __do {
	# 🧙🏻‍♀️ the power is yours, send donations to github.com/sponsors/balupton
	__affirm_length_defined $# 'argument' || return $?
	# normally, with > it is right to left, however that makes sense as > portions of our statement are on the right-side
	# however, __do is on the left side, so it should be left to right, such that this intuitively makes sense:
	# __do --copy-stderr=stderr.txt --copy-stdout=stdout.txt --redirect-stderr=STDOUT --copy-stdout=output.txt --redirect-stdout=NULL -- echo-style --stderr=my-stderr --stdout=my-stdout
	# as this makes no sense in this context:
	# __do --redirect-stdout=NULL --copy-stdout=output.txt --redirect-stderr=STDOUT --copy-stdout=stdout.txt --copy-stderr=stderr.txt -- echo-style --stderr=my-stderr --stdout=my-stdout
	#
	# furthermore, for some reason the recursion with the inversion is necessary for the tests to pass
	# just doing recursion with inversion later, via set, or via pop, causes the tests to fail: <https://gist.github.com/balupton/cb05a7a8a161a9df2b246cf1491b7654>
	if [[ $1 != '--inverted' ]]; then
		local DO__inversion=()
		while [[ $# -ne 0 && $1 != '--' ]]; do
			DO__inversion=("$1" "${DO__inversion[@]}")
			shift
		done
		__do --inverted "${DO__inversion[@]}" "$@"
		return $?
	else
		shift # remove the --inverted flag
	fi
	# trailing newlines defaults to no, to match bash $(...) behaviour, which while divergent from writing to files/file-descriptors/etc, this divergence is too convenient, hence why bash even has the divergence in the first place, for instance, if one does consistency, then this:
	# __do --redirect-status={choose_status} --redirect-stdout={choice} -- choose q -- a b c
	# if [[ $choice == 'b' ]]; then
	# has to become:
	# __do --redirect-status={choose_status} --redirect-stdout={choice} -- choose q -- a b c
	# if [[ $choice == $'b\n' ]]; then
	# or:
	# __do --no-trailing-newlines --redirect-status={choose_status} --redirect-stdout={choice} -- choose q -- a b c
	# if [[ $choice == $'b\n' ]]; then
	# or `choose` itself would need to be modified to not have a trailing newline on the last item
	# however, such trailing newlines are common everywhere, and are expected in all CLI/TUI output as they want a trailing newline so that dumb interactive shell prompts don't have the prompt on the same line as the tool output, so instead interactive shells just strip the trailing newline in script usage; the whole thing is a mess, and explains why consistency in an inconsistent world is not ideal and why divergence in a divergent world is better
	local DO__trailing_newlines=no DO__args=() DO__cmd=()
	while [[ $# -ne 0 ]]; do
		case "$1" in
		'--trailing-newlines' | '--trailing-newlines=yes')
			DO__trailing_newlines=yes
			shift
			;;
		'--no-trailing-newlines' | '--trailing-newlines=no')
			DO__trailing_newlines=no
			shift
			;;
		'--trailing-newlines=')
			shift
			;;
		'--')
			shift
			DO__cmd=("$@")
			shift $#
			break
			;;
		*)
			DO__args+=("$1")
			shift
			;;
		esac
	done
	if [[ ${#DO__cmd[@]} -eq 0 ]]; then
		__print_lines "ERROR: ${FUNCNAME[0]}: No command was provided." >&2 || :
		return 22 # EINVAL 22 Invalid argument
	fi
	if [[ ${#DO__args[@]} -eq 0 ]]; then
		"${DO__cmd[@]}"
		return $?
	fi
	# extract the arg that we will be working with on this recursion iteration
	local DO__arg DO__arg_value DO__arg_flag
	if [[ ${#DO__args[@]} -eq 1 ]]; then
		DO__arg="${DO__args[0]}"
		set -- --trailing-newlines="$DO__trailing_newlines" -- "${DO__cmd[@]}"
	else
		DO__arg="${DO__args[0]}"      # get the first argument
		DO__args=("${DO__args[@]:1}") # remove the first argument from the remainder
		set -- --trailing-newlines="$DO__trailing_newlines" "${DO__args[@]}" -- "${DO__cmd[@]}"
	fi
	DO__arg_flag="${DO__arg%%=*}" # [--stdout=], [--stderr=], [--output=] to [--stdout], [--stderr], [--output]
	DO__arg_value="${DO__arg#*=}"
	# if target is tty, but terminal device file is redirected, then redo the flag with the redirection value
	if __is_tty_special_file "$DO__arg_value" && ! __is_tty_special_file "$TERMINAL_OUTPUT_TARGET"; then
		DO__arg_value="$TERMINAL_OUTPUT_TARGET"
		DO__arg="${DO__arg_flag}=$DO__arg_value"
	fi
	# process
	case "$DO__arg" in
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
	'--discard-status' | '--no-status' | '--status=no')
		# catch and discard the status
		__try -- __do --inverted "$@"
		return $?
		;;

	# aliases for discard stdout, stderr, output
	'--discard-stdout' | '--no-stdout' | '--stdout=no')
		__do --inverted "$@" >/dev/null
		return $?
		;;
	'--discard-stderr' | '--no-stderr' | '--stderr=no')
		__do --inverted "$@" 2>/dev/null
		return $?
		;;
	'--discard-output' | '--no-output' | '--output=no' | '--discard-stdout+stderr' | '--no-stdout+stderr' | '--stdout+stderr=no')
		__do --inverted "$@" &>/dev/null
		return $?
		;;

	# redirect or copy, status, to a var target
	'--redirect-status={'*'}' | '--copy-status={'*'}')
		local DO__variable_name DO__status
		__dereference --source="$DO__arg_value" --name={DO__variable_name} || return $?

		# catch the status
		__try {DO__status} -- __do --inverted "$@"
		__return $? || return $?

		# apply the status to the var target
		eval "$DO__variable_name=\$DO__status" || return 104 # ENOTRECOVERABLE 104 State not recoverable

		# return or discard the status
		case "$DO__arg_flag" in
		'--redirect-'*) return 0 ;;
		'--copy-'*) return "$DO__status" ;;
		*)
			__print_lines "ERROR: ${FUNCNAME[0]}: An unrecognised target was encountered: $DO__arg" >&2 || :
			return 76 # EPROCUNAVAIL 76 Bad procedure for program
			;;
		esac
		;;

	# redirect or copy, status, to a non-var target
	'--redirect-status='* | '--copy-status='*)
		# catch the status
		local -i DO__status
		__try {DO__status} -- __do --inverted "$@"
		__return $? || return $?

		# apply the status to the non-var target
		__do --inverted --redirect-stdout="$DO__arg_value" -- printf '%s' "$DO__status" || return $?

		# return or discard the status
		case "$DO__arg_flag" in
		'--redirect-'*) return 0 ;;
		'--copy-'*) return "$DO__status" ;;
		*)
			__print_lines "ERROR: ${FUNCNAME[0]}: An unrecognised target was encountered: $DO__arg" >&2 || :
			return 76 # EPROCUNAVAIL 76 Bad procedure for program
			;;
		esac
		;;

	# redirect or copy, device files, to a var target
	'--redirect-stdout={'*'}' | '--redirect-stderr={'*'}' | '--redirect-output={'*'}' | '--copy-stdout={'*'}' | '--copy-stderr={'*'}' | '--copy-output={'*'}')
		local DO__variable_name DO__semaphore REPLY
		__dereference --source="$DO__arg_value" --name={DO__variable_name} || return $?

		# reset to prevent inheriting prior values of the same name if this one has a failure status which prevents updating the values
		eval "$DO__variable_name=" || return 104 # ENOTRECOVERABLE 104 State not recoverable

		# execute and write to a file
		# @todo consider a way to set the vars with what was written even if this fails, may not be a good idea
		DO__semaphore="$(__get_semaphore "$(__get_context_id '__do' "$DO__arg_flag" 'to-var' "$DO__variable_name" || :)")" || return $?
		__do --inverted "$DO__arg_flag=$DO__semaphore" "$@"
		__return $? --invoke-only-on-failure -- rm -f -- "$DO__semaphore" || return $?

		# load the value of the file, remove the file, apply the value to the var target
		if [[ $DO__trailing_newlines == no ]]; then
			REPLY="$(<"$DO__semaphore")" || __return $? -- rm -f -- "$DO__semaphore" || return $?
		else
			__read_whole <"$DO__semaphore" || __return $? -- rm -f -- "$DO__semaphore" || return $?
		fi
		eval "$DO__variable_name=\"\$REPLY\"" || __return $? -- rm -f -- "$DO__semaphore" || return 104 # ENOTRECOVERABLE 104 State not recoverable
		rm -f -- "$DO__semaphore" || return $?
		return $?
		;;

	# this may seem like a good idea, but it isn't, the reason why is that pipelines are forks, and as such the hierarchy gets disconnected, with the updates of inner dos not having their updates seen by outer dos
	# # redirect, device files, to pipeline
	# '--redirect-stdout=|'* | '--redirect-stderr=|'* | '--redirect-output=|'*)
	# 	# trim starting |, converting |<code> to <code>
	# 	local DO__code
	# 	__slice --source={DO__arg_value} --target={DO__code} 1 || return $?

	# 	# run our pipes
	# 	case "$DO__arg_flag" in
	# 	--redirect-stdout)
	# 		__do --inverted "$@" | eval "$DO__code"
	# 		return $?
	# 		;;
	# 	--redirect-stderr)
	# 		# there is no |2 in bash
	# 		__print_lines "ERROR: ${FUNCNAME[0]}: An unrecognised target was encountered: $DO__arg" >&2
	# 		return 76 # EPROCUNAVAIL 76 Bad procedure for program
	# 		;;
	# 	--redirect-output)
	# 		__do --inverted "$@" 2>&1 | eval "$DO__code"
	# 		return $?
	# 		;;
	# 	*)
	# 		__print_lines "ERROR: ${FUNCNAME[0]}: An unrecognised target was encountered: $DO__arg" >&2
	# 		return 76 # EPROCUNAVAIL 76 Bad procedure for program
	# 		;;
	# 	esac
	# 	;;

	# redirect, device files, to process substitution
	'--redirect-stdout=('*')' | '--redirect-stderr=('*')' | '--redirect-output=('*')')
		local DO__code DO__semaphore DO__size

		# trim starting and trailing parentheses, converting (<code>) to <code>
		DO__size="${#DO__arg_value}"
		DO__code="${DO__arg_value:1:DO__size-2}"

		# executing this in errexit mode:
		# __do --stderr='(cat; __return 10; __return 20)' -- echo-style --stderr=stderr-result --stdout=stdout-result; echo "status=[${statusvar-}] stdout=[${stdoutvar-}] stderr=[${stderrvar-}]"
		#
		# with this internal code, will not fail, as the return statuses of the subshell redirections are ignored:
		# --stderr) __do --inverted "$@" 2> >(eval "$DO__code"; __return $? -- touch "$DO__semaphore") ;;
		#
		# with this internal code, will fail with 20:
		# --stderr) __do --inverted "$@" 2> >(set +e; eval "$DO__code"; printf '%s' "$?" >"$DO__semaphore") ;;
		#
		# with this internal code, will fail with 10, which is what we want
		# --stderr) __do --inverted "$@" 2> >(__do --status="$DO__semaphore" -- eval "$DO__code") ;;

		# prepare our semaphore file that will track the exit status of the process substitution
		DO__semaphore="$(__get_semaphore "$(__get_context_id '__do' "$DO__arg_flag" 'to-process' || :)")" || return $?

		# execute while tracking the exit status to our semaphore file
		# can't use `__try` as >() is a subshell, so the status variable application won't escape the subshell
		# note [>(...)] and [> >(...)] are different, the former interpolates as a file descriptor, the latter forwards stdout to the file descriptor
		case "$DO__arg_flag" in
		'--redirect-stdout') __do --inverted "$@" > >(__do --inverted --redirect-status="$DO__semaphore" -- eval "$DO__code") ;;
		'--redirect-stderr') __do --inverted "$@" 2> >(__do --inverted --redirect-status="$DO__semaphore" -- eval "$DO__code") ;;
		'--redirect-output') __do --inverted "$@" &> >(__do --inverted --redirect-status="$DO__semaphore" -- eval "$DO__code") ;;
		*)
			__print_lines "ERROR: ${FUNCNAME[0]}: An unrecognised target was encountered: $DO__arg" >&2 || :
			return 76 # EPROCUNAVAIL 76 Bad procedure for program
			;;
		esac

		# once completed, wait for and return the status of our process substitution
		__return $? -- __wait_for_and_return_semaphores "$DO__semaphore" || return $?
		return 0
		;;

	# note that copying to a process substitution is not yet supported
	# @todo implement this
	'--copy-stdout=('*')' | '--copy-stderr=('*')' | '--copy-output=('*')')
		__print_lines "ERROR: ${FUNCNAME[0]}: A to be implemented flag was provided: $DO__arg" >&2 || :
		return 78 # NOSYS 78 Function not implemented
		;;

	# redirect, stdout, to various targets
	'--redirect-stdout='*)
		case "$DO__arg_value" in

		# redirect stdout to stdout, this is a no-op, continue to next
		'1' | 'STDOUT' | 'stdout' | '/dev/stdout')
			__do --inverted "$@"
			return $?
			;;

		# redirect stdout to stderr
		'2' | 'STDERR' | 'stderr' | '/dev/stderr')
			__do --inverted "$@" >&2
			return $?
			;;

		# redirect stdout to tty
		'TTY' | 'tty' | '/dev/tty')
			__do --inverted "$@" >>/dev/tty
			return $?
			;;

		# redirect stdout to null
		'NULL' | 'null' | '/dev/null')
			__do --inverted "$@" >/dev/null
			return $?
			;;

		# redirect stdout to FD target
		[0-9]*)
			__affirm_value_is_positive_integer "$DO__arg_value" 'file descriptor' || return $?
			__do --inverted "$@" >&"$DO__arg_value"
			return $?
			;;

		# no-op
		'')
			__do --inverted "$@"
			return $?
			;;

		# redirect stdout to file target
		*)
			__do --inverted "$@" >>"$DO__arg_value"
			return $?
			;;

		# done with stdout redirect
		esac
		;;

	# copy, stdout, to various targets
	'--copy-stdout='*)
		case "$DO__arg_value" in

		# copy stdout to stdout
		'1' | 'STDOUT' | 'stdout' | '/dev/stdout')
			# no-op
			__do --inverted "$@"
			return $?
			;;

		# copy stdout to stderr
		'2' | 'STDERR' | 'stderr' | '/dev/stderr')
			# prepare our semaphore files that will track the exit status of the process substitution
			local DO__semaphores
			__semaphores --target={DO__semaphores} -- \
				"$(__get_context_id '__do' 'copy-stdout-to-stderr' 1 || :)" \
				"$(__get_context_id '__do' 'copy-stdout-to-stderr' 2 || :)" || return $?

			# execute, keeping stdout, copying to stderr, and tracking the exit status to our semaphore file
			__do --inverted "$@" > >(
				set +e
				tee -- >(
					set +e
					cat >&2
					printf '%s' "$?" >"${DO__semaphores[0]}"
				)
				printf '%s' "$?" >"${DO__semaphores[1]}"
			)

			# once completed, wait for and return the status of our process substitution
			__return $? -- __wait_for_and_return_semaphores "${DO__semaphores[@]}" || return $?
			return 0
			;;

		# copy stdout to tty
		'TTY' | 'tty' | '/dev/tty')
			# prepare our semaphore files that will track the exit status of the process substitution
			local DO__semaphores
			__semaphores --target={DO__semaphores} -- \
				"$(__get_context_id '__do' 'copy-stdout-to-tty' 1 || :)" \
				"$(__get_context_id '__do' 'copy-stdout-to-tty' 2 || :)" || return $?

			# execute, keeping stdout, copying to stderr, and tracking the exit status to our semaphore file
			__do --inverted "$@" > >(
				set +e
				tee -- >(
					set +e
					cat >>/dev/tty
					printf '%s' "$?" >"${DO__semaphores[0]}"
				)
				printf '%s' "$?" >"${DO__semaphores[1]}"
			)

			# once completed, wait for and return the status of our process substitution
			__return $? -- __wait_for_and_return_semaphores "${DO__semaphores[@]}" || return $?
			return 0
			;;

		# copy stdout to null
		'NULL' | 'null' | '/dev/null')
			# no-op
			__do --inverted "$@"
			return $?
			;;

		# copy stdout to FD target
		[0-9]*)
			__affirm_value_is_positive_integer "$DO__arg_value" 'file descriptor' || return $?

			# prepare our semaphore files that will track the exit status of the process substitution
			local DO__semaphores
			__semaphores --target={DO__semaphores} -- \
				"$(__get_context_id '__do' 'copy-stdout-to-fd' "$DO__arg_value" 1 || :)" \
				"$(__get_context_id '__do' 'copy-stdout-to-fd' "$DO__arg_value" 2 || :)" || return $?

			# execute, keeping stdout, copying to FD, and tracking the exit status to our semaphore file
			__do --inverted "$@" > >(
				set +e
				tee -- >(
					set +e
					cat >&"$DO__arg_value"
					printf '%s' "$?" >"${DO__semaphores[0]}"
				)
				printf '%s' "$?" >"${DO__semaphores[1]}"
			)

			# once completed, wait for and return the status of our process substitution
			__return $? -- __wait_for_and_return_semaphores "${DO__semaphores[@]}" || return $?
			return 0
			;;

		# no-op
		'')
			__do --inverted "$@"
			return $?
			;;

		# copy stdout to file target
		*)
			# prepare our semaphore file that will track the exit status of the process substitution
			local DO__semaphore
			DO__semaphore="$(__get_semaphore "$(__get_context_id '__do' 'copy-stdout-to-file' || :)")" || return $?

			# execute, keeping stdout, copying to the value target, and tracking the exit status to our semaphore file
			__do --inverted "$@" > >(
				set +e
				tee -a -- "$DO__arg_value"
				printf '%s' "$?" >"$DO__semaphore"
			)

			# once completed, wait for and return the status of our process substitution
			__return $? -- __wait_for_and_return_semaphores "$DO__semaphore" || return $?
			return 0
			;;

		# done with stdout copy
		esac
		;;

	'--redirect-stderr='*)
		case "$DO__arg_value" in

		# redirect stderr to stdout
		'1' | 'STDOUT' | 'stdout' | '/dev/stdout')
			__do --inverted "$@" 2>&1
			return $?
			;;

		# redirect stderr to stderr, this is a no-op, continue to next
		'2' | 'STDERR' | 'stderr' | '/dev/stderr')
			__do --inverted "$@"
			return $?
			;;

		# redirect stderr to tty
		'TTY' | 'tty' | '/dev/tty')
			__do --inverted "$@" 2>>/dev/tty
			return $?
			;;

		# redirect stderr to null
		'NULL' | 'null' | '/dev/null')
			__do --inverted "$@" 2>/dev/null
			return $?
			;;

		# redirect stderr to FD target
		[0-9]*)
			__affirm_value_is_positive_integer "$DO__arg_value" 'file descriptor' || return $?
			__do --inverted "$@" 2>&"$DO__arg_value"
			return $?
			;;

		# no-op
		'')
			__do --inverted "$@"
			return $?
			;;

		# redirect stderr to file target
		*)
			__do --inverted "$@" 2>>"$DO__arg_value"
			return $?
			;;

		# done with stderr redirect
		esac
		;;

	# copy, stderr, to various targets
	'--copy-stderr='*)
		case "$DO__arg_value" in

		# copy stderr to stdout
		'1' | 'STDOUT' | 'stdout' | '/dev/stdout')
			# prepare our semaphore files that will track the exit status of the process substitution
			local DO__semaphores
			__semaphores --target={DO__semaphores} -- \
				"$(__get_context_id '__do' 'copy-stderr-to-stdout' 1 || :)" \
				"$(__get_context_id '__do' 'copy-stderr-to-stdout' 2 || :)" || return $?

			# execute, keeping stderr, copying to stdout, and tracking the exit status to our semaphore file
			__do --inverted "$@" 2> >(
				set +e
				tee -- >(
					set +e
					cat
					printf '%s' "$?" >"${DO__semaphores[0]}"
				) >&2
				printf '%s' "$?" >"${DO__semaphores[1]}"
			)

			# once completed, wait for and return the status of our process substitution
			__return $? -- __wait_for_and_return_semaphores "${DO__semaphores[@]}" || return $?
			return 0
			;;

		# copy stderr to stderr, this behaviour is unspecified, should it double the data to stderr?
		'2' | 'STDERR' | 'stderr' | '/dev/stderr')
			# no-op
			__do --inverted "$@"
			return $?
			;;

		# copy stderr to tty
		'TTY' | 'tty' | '/dev/tty')
			# prepare our semaphore files that will track the exit status of the process substitution
			local DO__semaphores
			__semaphores --target={DO__semaphores} -- \
				"$(__get_context_id '__do' 'copy-stderr-to-tty' 1 || :)" \
				"$(__get_context_id '__do' 'copy-stderr-to-tty' 2 || :)" || return $?

			# execute, keeping stderr, copying to stdout, and tracking the exit status to our semaphore file
			__do --inverted "$@" 2> >(
				set +e
				tee -- >(
					set +e
					cat >>/dev/tty
					printf '%s' "$?" >"${DO__semaphores[0]}"
				) >&2
				printf '%s' "$?" >"${DO__semaphores[1]}"
			)

			# once completed, wait for and return the status of our process substitution
			__return $? -- __wait_for_and_return_semaphores "${DO__semaphores[@]}" || return $?
			return 0
			;;

		# copy stderr to null
		'NULL' | 'null' | '/dev/null')
			# no-op
			__do --inverted "$@"
			return $?
			;;

		# copy stderr to FD target
		[0-9]*)
			__affirm_value_is_positive_integer "$DO__arg_value" 'file descriptor' || return $?

			# prepare our semaphore files that will track the exit status of the process substitution
			local DO__semaphores
			__semaphores --target={DO__semaphores} -- \
				"$(__get_context_id '__do' 'copy-stderr-to-fd' "$DO__arg_value" 1 || :)" \
				"$(__get_context_id '__do' 'copy-stderr-to-fd' "$DO__arg_value" 2 || :)" || return $?

			# execute, keeping stdout, copying to FD, and tracking the exit status to our semaphore file
			__do --inverted "$@" 2> >(
				set +e
				tee -- >(
					set +e
					cat >&"$DO__arg_value"
					printf '%s' "$?" >"${DO__semaphores[0]}"
				) >&2
				printf '%s' "$?" >"${DO__semaphores[1]}"
			)

			# once completed, wait for and return the status of our process substitution
			__return $? -- __wait_for_and_return_semaphores "${DO__semaphores[@]}" || return $?
			return 0
			;;

		# no-op
		'')
			__do --inverted "$@"
			return $?
			;;

		# copy stderr to file target
		*)
			# prepare our semaphore file that will track the exit status of the process substitution
			local DO__semaphore
			DO__semaphore="$(__get_semaphore "$(__get_context_id '__do' 'copy-stderr-to-file' || :)")" || return $?

			# execute, keeping stderr, copying to the value target, and tracking the exit status to our semaphore file
			__do --inverted "$@" 2> >(
				set +e
				tee -a -- "$DO__arg_value" >&2
				printf '%s' "$?" >"$DO__semaphore"
			)

			# once completed, wait for and return the status of our process substitution
			__return $? -- __wait_for_and_return_semaphores "$DO__semaphore" || return $?
			return 0
			;;

		# done with stderr copy
		esac
		;;

	'--redirect-output='*)
		case "$DO__arg_value" in

		# redirect stderr to stdout
		'1' | 'STDOUT' | 'stdout' | '/dev/stdout')
			__do --inverted "$@" 2>&1
			return $?
			;;

		# redirect stdout to stderr
		'2' | 'STDERR' | 'stderr' | '/dev/stderr')
			__do --inverted "$@" >&2
			return $?
			;;

		# redirect stderr to stdout, then stdout to tty, as `&>>` is not supported in all bash versions
		'TTY' | 'tty' | '/dev/tty')
			__do --inverted "$@" >>/dev/tty 2>&1
			return $?
			;;

		# redirect output to null
		'NULL' | 'null' | '/dev/null' | 'no')
			__do --inverted "$@" &>/dev/null
			return $?
			;;

		# redirect stderr to stdout, such that and then, both stdout and stderr are redirected to the fd target
		[0-9]*)
			__affirm_value_is_positive_integer "$DO__arg_value" 'file descriptor' || return $?
			__do --inverted "$@" 1>&"$DO__arg_value" 2>&1
			return $?
			;;

		# no-op
		'')
			__do --inverted "$@"
			return $?
			;;

		# redirect stderr to stdout, such that and then, both stdout and stderr are redirect to the file target
		*)
			__do --inverted "$@" >"$DO__arg_value" 2>&1
			return $?
			;;

		# done with output redirect
		esac
		;;

	# copy, output, to various targets
	'--copy-output='*)
		case "$DO__arg_value" in

		# copy output to stdout, this behaviour is unspecified, as there is no way to send it back to output
		'1' | 'STDOUT' | 'stdout' | '/dev/stdout')
			# @todo implement this
			__print_lines "ERROR: ${FUNCNAME[0]}: A to be implemented flag was provided: $DO__arg" >&2 || :
			return 78 # NOSYS 78 Function not implemented
			;;

		# copy output to stderr, this behaviour is unspecified, as there is no way to send it back to output
		'2' | 'STDERR' | 'stderr' | '/dev/stderr')
			# @todo implement this
			__print_lines "ERROR: ${FUNCNAME[0]}: A to be implemented flag was provided: $DO__arg" >&2 || :
			return 78 # NOSYS 78 Function not implemented
			;;

		# copy output to tty, this behaviour is unspecified, as there is no way to send it back to output
		'TTY' | 'tty' | '/dev/tty')
			# @todo implement this
			__print_lines "ERROR: ${FUNCNAME[0]}: A to be implemented flag was provided: $DO__arg" >&2 || :
			return 78 # NOSYS 78 Function not implemented
			;;

		# copy stderr to null
		'NULL' | 'null' | '/dev/null')
			# no-op
			__do --inverted "$@"
			return $?
			;;

		# copy output to FD target, this behaviour is unspecified, as there is no way to send it back to output
		[0-9]*)
			__affirm_value_is_positive_integer "$DO__arg_value" 'file descriptor' || return $?
			__print_lines "ERROR: ${FUNCNAME[0]}: A to be implemented flag was provided: $DO__arg" >&2 || :
			return 78 # NOSYS 78 Function not implemented
			;;

		# no-op
		'')
			__do --inverted "$@"
			return $?
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
function dorothy_try__context_lines { :; }
function dorothy_try__dump_lines { :; }

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
	local -i continued_status
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
	elif __is_subshell_function__internal "${DOROTHY_TRY__COMMAND[0]}"; then
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
	local DOROTHY_TRY__item DOROTHY_TRY__exit_status_variable_name=''
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
		'{'*'}') __dereference --source="$DOROTHY_TRY__item" --name={DOROTHY_TRY__exit_status_variable_name} || return $? ;;
		*)
			__print_lines "ERROR: ${FUNCNAME[0]}: An unrecognised flag was provided: $DOROTHY_TRY__item" >&2 || :
			return 22 # EINVAL 22 Invalid argument
			;;
		esac
	done

	# update globals
	DOROTHY_TRY__COUNT="${DOROTHY_TRY__COUNT:-0}" # so we can remove our trap once all tries are finished

	# update shared variables
	# [3.2.57][testing_middle] [__try] [26180].status
	DOROTHY_TRY__CONTEXT="$(__get_context_id '__try' 'status' || :)"
	DOROTHY_TRY__SEMAPHORE="$(__get_semaphore "$DOROTHY_TRY__CONTEXT")"

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
	if [[ -n $DOROTHY_TRY__exit_status_variable_name ]]; then
		eval "$DOROTHY_TRY__exit_status_variable_name=${DOROTHY_TRY__STATUS:-0}"
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
			__print_help <<-EOF
				ABOUT:
				Capture or ignore exit status, without disabling errexit, and without a subshell.
				\`\`\`
				Copyright 2023+ Benjamin Lupton <b@lupton.cc> (https://balupton.com)
				Written for Dorothy (https://github.com/bevry/dorothy)
				Licensed under the Reciprocal Public License 1.5 (http://spdx.org/licenses/RPL-1.5.html)
				\`\`\`

				USAGE:
				\`local -i status=0; local stdout='' stderr='' output=''\`
				\`eval_capture [--status-var=status] [--stdout-var=stdout] [--stderr-var=stderr] [--output-var=output] [--stdout-target=/dev/stdout] [--stderr-target=/dev/stderr] [--output-target=...] [--no-stdout] [--no-stderr] [--no-output] [--] cmd ...\`

				QUIRKS:
				Using \`--stdout-var\` will set \`--stdout-target=/dev/null\`
				Using \`--stderr-var\` will set \`--stderr-target=/dev/null\`
				Using \`--output-var\` will set \`--stdout-target=/dev/null --stderr-target=/dev/null\`

				WARNING:
				If \`eval_capture\` triggers something that still does function invocation via \`if\`, \`&&\`, \`||\`, or \`!\`, then errexit will still be disabled for that invocation.
				This is a limitation of bash, with no workaround (at least at the time of bash v5.2).
				Refer to <https://github.com/bevry/dorothy/blob/master/docs/bash/errors.md> for guidance.
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
	if ! __is_var_defined LOGIN_USER; then
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
	if ! __is_var_defined LOGIN_UID; then
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
	if ! __is_var_defined LOGIN_GROUP; then
		__prepare_login_uid || :
		LOGIN_GROUP="$(id -gn "$LOGIN_UID" || :)"
		if [[ -z $LOGIN_GROUP ]]; then
			__print_lines "ERROR: ${FUNCNAME[0]}: Unable to fetch the group name of the login user." >&2 || :
			return 1
		fi
	fi
}
function __prepare_login_gid {
	if ! __is_var_defined LOGIN_GID; then
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
	if ! __is_var_defined LOGIN_GROUPS; then
		LOGIN_GROUPS=()
		local groups
		__prepare_login_uid || :
		groups="$(id -Gn "$LOGIN_UID" || :)"
		__split --source={groups} --target={LOGIN_GROUPS} --delimiter=' ' --no-zero-length || :
		if [[ ${#LOGIN_GROUPS[@]} -eq 0 ]]; then
			__print_lines "ERROR: ${FUNCNAME[0]}: Unable to fetch the group names of the login user." >&2 || :
			return 1
		fi
	fi
}
function __prepare_login_gids {
	if ! __is_var_defined LOGIN_GIDS; then
		LOGIN_GIDS=()
		local groups
		__prepare_login_uid || :
		groups="$(id -G "$LOGIN_UID" || :)"
		__split --source={groups} --target={LOGIN_GIDS} --delimiter=' ' --no-zero-length || :
		if [[ ${#LOGIN_GIDS[@]} -eq 0 ]]; then
			__print_lines "ERROR: ${FUNCNAME[0]}: Unable to fetch the groups IDs of the login user." >&2 || :
			return 1
		fi
	fi
}
function __prepare_current_user {
	if ! __is_var_defined CURRENT_USER; then
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
	if ! __is_var_defined CURRENT_UID; then
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
	if ! __is_var_defined CURRENT_GROUP; then
		CURRENT_GROUP="$(id -gn || :)"
		if [[ -z $CURRENT_GROUP ]]; then
			__print_lines "ERROR: ${FUNCNAME[0]}: Unable to fetch the group name of the current user." >&2 || :
			return 1
		fi
	fi
}
function __prepare_current_gid {
	if ! __is_var_defined CURRENT_GID; then
		CURRENT_GID="$(id -g || :)"
		if [[ -z $CURRENT_GID ]]; then
			__print_lines "ERROR: ${FUNCNAME[0]}: Unable to fetch the group ID of the current user." >&2 || :
			return 1
		fi
	fi
}
function __prepare_current_groups {
	if ! __is_var_defined CURRENT_GROUPS; then
		CURRENT_GROUPS=()
		if __is_var_defined GROUPS; then
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
	if ! __is_var_defined CURRENT_GIDS; then
		CURRENT_GIDS=()
		local groups
		# trunk-ignore(shellcheck/SC2034)
		groups="$(id -G || :)"
		__split --source={groups} --target={CURRENT_GIDS} --delimiter=' ' --no-zero-length || :
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
		eval-helper --elevate -- "$@" || return $?
		return 0
	elif __command_exists -- sudo; then
		# check if password is required
		if ! sudo --non-interactive -- true &>/dev/null; then
			# password is required, let the user know what they are being prompted for
			__print_lines \
				'Your password is required to momentarily grant privileges to execute the command:' $'\n' \
				"sudo $*" >&2 || return $?
		fi
		sudo "$@" # eval
		return $?
	elif __command_exists -- doas; then
		if ! doas -n true &>/dev/null; then
			__print_lines \
				'Your password is required to momentarily grant privileges to execute the command:' $'\n' \
				"doas $*" >&2 || return $?
		fi
		doas "$@" # eval
		return $?
	else
		"$@" # eval
		return $?
	fi
}
# bc alias
function __try_sudo {
	if __command_exists -- dorothy-warnings; then
		dorothy-warnings add --code='__try_sudo' --bold=' has been deprecated in favor of ' --code='__elevate' || :
	fi
	__elevate "$@" || return $?
	return 0
}

# this should never be the case, as TMPDIR bash should prefill if not env inherited, but just in case, ensure it
if [[ -z ${TMPDIR-} ]]; then
	TMPDIR="$(mktemp -d)"
fi
while [[ ${TMPDIR: -1} == '/' ]]; do
	TMPDIR="${TMPDIR:0:(( ${#TMPDIR} - 1 ))}"
done

# performantly make directories as many directories as possible without sudo
# this is beta, and may change later
function __mkdirp {
	# trim -- prefix
	if [[ ${1-} == '--' ]]; then
		shift
	fi
	# proceed
	local -i status=0
	local dir missing=()
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
		# 			# if mkdir -p -- "$dir" 2>&1 | grep --quiet --extended-regexp --regexp=': Permission denied$'; then
		# 			# 	sudo_missing+=("$dir")
		# 			# else
		# 			# 	mkdir -p -- "$dir" || return $?
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
	local -i status=0
	local dir missing=()
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
	__elevate_mkdirp "$@" || return $?
	return 0
}

# -------------------------------------
# Read Toolkit
# these are beta and may change

# `printf '\0'` will write a null-byte, however `bash` discards it, and `read` requires workarounds: https://unix.stackexchange.com/a/626655
# `LC_ALL=C IFS= read -rd '' -n1` works, capturing newlines and null-bytes
# `LC_ALL=C IFS= read -rn1` discards newlines
# `LC_ALL=C IFS= read -rd ''` discards null-bytes
# `LC_ALL=C IFS= read -rd '' -N1` discards null-bytes
# `(<file)` discards null-bytes and trailing line

# @todo one day make something like this, but for now, it is too complex and not needed
# __read --whole
# __read --null-separated-pieces
# __read --lines --inline
# __read --until=<character>
# function __read {
# 	local READ__whole='' READ__pieces='' READ__lines='' READ__inline='' READ__until=''
# 	while [[ $# -ne 0 ]]; do
# 		case "$1" in
# 		'--whole') READ__whole=yes ;;
# 		'--null-separated-pieces') READ__pieces=yes ;;
# 		'--lines') READ__lines=yes ;;
# 		'--inline') READ__inline=yes ;;
# 		'--until='*)
# 			READ__until="${1#*=}"
# 			if [[ ${#READ__until} -gt 1 ]]; then
# 				printf '%s%q%d' "ERROR: ${FUNCNAME[0]}: The until character must be zero-length or a single-length character:" "$READ__until" "${#READ__until}" >&2 || :
# 				return 22 # EINVAL 22 Invalid argument
# 			elif [[ -z $READ__until ]]; then
# 				READ__until='null'
# 			fi
# 			;;
# 		*) __unrecognised_argument "$1" || return $? ;;
# 		esac
# 		shift
# 	done

function __ansi_trim {
	__invoke_function_from_source 'ansi.bash' "$@" || return $?
}
function __split_shapeshifting {
	__invoke_function_from_source 'ansi.bash' "$@" || return $?
}
function __ansi_keep_right {
	__invoke_function_from_source 'ansi.bash' "$@" || return $?
}
function __is_shapeshifter {
	__invoke_function_from_source 'ansi.bash' "$@" || return $?
}
function __read_key {
	__invoke_function_from_source 'ansi.bash' "$@" || return $?
}
function __should_wrap {
	__invoke_function_from_source 'ansi.bash' "$@" || return $?
}

# once this supports a target variable, then make __split use it
function __read_whole {
	# LC_ALL=C IFS= read -rd '' <-- this just reads until the first null byte, needs a loop
	local whole=''
	REPLY=''
	# unable to capture null-bytes in bash in a whole string
	while LC_ALL=C IFS= read -rd '' || [[ -n $REPLY ]]; do
		whole+="$REPLY"
		REPLY=''
	done
	REPLY="$whole"
}

# function __read_pieces
# function __write_pieces

function __cat_pieces {
	local segment='' REPLY
	while LC_ALL=C IFS= read -rd '' -n1 || [[ -n $REPLY ]]; do
		if [[ -z $REPLY ]]; then
			printf '%s\0' "$segment"
			segment=''
		else
			segment+="$REPLY"
			REPLY=''
		fi
	done
	if [[ -n $segment ]]; then
		printf '%s' "$segment"
	fi
}

function __cat_until {
	local until
	if [[ $# -eq 0 ]]; then
		until=$'\004' # default to end of transmission, ctrl-D
	elif [[ $# -eq 1 ]]; then
		until="$1"
		if [[ ${#until} -gt 1 ]]; then
			printf '%s%q%s' "ERROR: ${FUNCNAME[0]}: The until character must be zero-length or a single-length character:" "$until" "${#until}" >&2 || :
			return 22 # EINVAL 22 Invalid argument
		fi
	else
		__print_lines "ERROR: ${FUNCNAME[0]}: Too many arguments provided, expected 0 or 1." >&2 || :
		return 22 # EINVAL 22 Invalid argument
	fi
	# n1 will exit on newlines, so N1 must be used
	# we want to output everything as it happens, which unfortunately is character by character
	# as timeout will cause an unnecessary delay
	local REPLY
	while LC_ALL=C IFS= read -rd '' -n1 || [[ -n $REPLY ]]; do
		if [[ $REPLY == "$until" ]]; then
			break
		fi
		if [[ -z $REPLY ]]; then
			printf '\0'
		else
			printf '%s' "$REPLY"
			REPLY=''
		fi
	done
}

# -------------------------------------
# File Descriptor Toolkit

# See <https://stackoverflow.com/q/8297415/130638> then <https://gist.github.com/balupton/66e023e68f08ae827288a68a04d835c1> for commentary

# checks if a file descriptor reference or number is open, not that despite being able to open a file descriptor for reading or writing, there is no reliable way to detect if the file descriptor was opened only for reading xor writing, see: https://gist.github.com/balupton/66e023e68f08ae827288a68a04d835c1
function __is_fd_open {
	local IS_FD_OPEN__item IS_FD_OPEN__numbers=()
	while [[ $# -ne 0 ]]; do
		IS_FD_OPEN__item="$1"
		shift
		case "$IS_FD_OPEN__item" in
		# no way to test if a file descriptor reference is available, it has to be dereferenced first
		'{'*'}') __dereference --source="$IS_FD_OPEN__item" --append --value={IS_FD_OPEN__numbers} || return $? ;;
		[0-9]*) IS_FD_OPEN__numbers+=("$IS_FD_OPEN__item") ;; # affirmation is handled later
		*) __unrecognised_argument "$IS_FD_OPEN__item" || return $? ;;
		esac
	done
	__affirm_length_defined "${#IS_FD_OPEN__numbers[@]}" 'file descriptor reference or number' || return $?
	for IS_FD_OPEN__item in "${IS_FD_OPEN__numbers[@]}"; do
		__affirm_value_is_positive_integer "$IS_FD_OPEN__item" 'file descriptor number' || return $?
		# other techniques, especially those recommended by others, have issues: https://gist.github.com/balupton/66e023e68f08ae827288a68a04d835c1
		# this works but is very slow: ( : >&${IS_FD_OPEN__item} ) 2>/dev/null || return 1
		# as such, the below is the best:
		[[ -e /dev/fd/${IS_FD_OPEN__item} ]] || return 1
	done
	return 0
}

# checks if a file descriptor reference or number is available to be opened
function __is_fd_available {
	local IS_FD_AVAILABLE__item IS_FD_AVAILABLE__numbers=()
	while [[ $# -ne 0 ]]; do
		IS_FD_AVAILABLE__item="$1"
		shift
		case "$IS_FD_AVAILABLE__item" in
		# no way to test if a file descriptor reference is available, it has to be dereferenced first
		'{'*'}') __dereference --source="$IS_FD_AVAILABLE__item" --append --value={IS_FD_AVAILABLE__numbers} || return $? ;;
		[0-9]*) IS_FD_AVAILABLE__numbers+=("$IS_FD_AVAILABLE__item") ;; # affirmation is handled later
		*) __unrecognised_argument "$IS_FD_AVAILABLE__item" || return $? ;;
		esac
	done
	__affirm_length_defined "${#IS_FD_AVAILABLE__numbers[@]}" 'file descriptor reference or number' || return $?
	for IS_FD_AVAILABLE__item in "${IS_FD_AVAILABLE__numbers[@]}"; do
		__affirm_value_is_positive_integer "$IS_FD_AVAILABLE__item" 'file descriptor number' || return $?
		if [[ -e /dev/fd/${IS_FD_AVAILABLE__item} ]]; then
			return 1
		fi
	done
	return 0
}

# Open a file descriptor in a cross-bash compatible way
# __open_fd ...<{file_descriptor_reference}> ...<file_descriptor_number> <mode> <target>
function __open_fd {
	local OPEN_FD__item OPEN_FD__numbers=() OPEN_FD__references=() OPEN_FD__mode='' OPEN_FD__target_number='' OPEN_FD__target_file=''
	while [[ $# -ne 0 ]]; do
		OPEN_FD__item="$1"
		shift
		if [[ -z $OPEN_FD__mode ]]; then
			case "$OPEN_FD__item" in
			# file descriptor
			'{'*'}') __dereference --source="$OPEN_FD__item" --append --name={OPEN_FD__references} || return $? ;;
			[0-9]*)
				__affirm_value_is_positive_integer "$OPEN_FD__item" 'file descriptor' || return $?
				OPEN_FD__numbers+=("$OPEN_FD__item") ;;
			# mode
			'<' | '--read') OPEN_FD__mode='<' ;;
			'>' | '--overwrite' | '--write') OPEN_FD__mode='>' ;;
			'<>' | '--read-write') OPEN_FD__mode='<>' ;;
			'>>' | '--append') OPEN_FD__mode='>>' ;;
			*) __unrecognised_argument "$OPEN_FD__item" || return $? ;;
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
		__print_lines "ERROR: ${FUNCNAME[0]}: Too many arguments provided, expected only a file descriptor number or reference, a mode, and a target." >&2 || :
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
		if [[ $BASH_CAN_OPEN_AVAILABLE_FILE_DESCRIPTOR_TO_REFERENCE == 'yes' ]]; then
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
			# FD 3 and 4 are commonly used and expected
			# FD >=10 are apparently used internally, whatever that means
			# So start at 5 and hope for the best
			local -i OPEN_FD__end OPEN_FD__references_index
			OPEN_FD__end="$(ulimit -n)" # this must be here, instead of in the for loop initialisation, as otherwise bash 4.3 and 4.4 will crash
			for ((OPEN_FD__number = 5, OPEN_FD__references_index = 0; OPEN_FD__number < OPEN_FD__end && OPEN_FD__references_index < OPEN_FD__references_count; OPEN_FD__number++)); do
				if __is_fd_available "$OPEN_FD__number"; then
					OPEN_FD__numbers+=("$OPEN_FD__number")
					OPEN_FD__reference="${OPEN_FD__references[OPEN_FD__references_index]}"
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
	eval "exec $OPEN_FD__eval_statement_exec; $OPEN_FD__eval_statement_assignments" || return 104 # ENOTRECOVERABLE 104 State not recoverable
}

# __close_fd ...<{file_descriptor_reference}> ...<file_descriptor_number>
# uses `>&-` as closing doesn't matter if < or >, and < has a bug prior to bash 4.3
function __close_fd {
	local CLOSE_FD__item CLOSE_FD__number CLOSE_FD__reference CLOSE_FD__eval_statement_exec=''
	__affirm_length_defined $# 'file descriptor reference or file descriptor number' || return $?
	for CLOSE_FD__item in "$@"; do
		if __is_positive_integer "$CLOSE_FD__item"; then
			CLOSE_FD__number="$CLOSE_FD__item"
		else
			if [[ $BASH_CAN_OPEN_AVAILABLE_FILE_DESCRIPTOR_TO_REFERENCE == 'yes' ]]; then
				# close via the file descriptor reference
				__dereference --source="$CLOSE_FD__item" --name={CLOSE_FD__reference} || return $?
				CLOSE_FD__eval_statement_exec+="{$CLOSE_FD__reference}>&- "
				continue
			else
				# get the file descriptor directly
				__dereference --source="$CLOSE_FD__item" --value={CLOSE_FD__number} || return $?
				if [[ -z $CLOSE_FD__number ]]; then
					__print_lines "ERROR: ${FUNCNAME[0]}: Invalid file descriptor reference provided: $CLOSE_FD__item" >&2 || :
					return 22 # EINVAL 22 Invalid argument
				fi
			fi
		fi
		# close the file descriptor number
		CLOSE_FD__eval_statement_exec+="$CLOSE_FD__number>&- "
	done
	eval "exec $CLOSE_FD__eval_statement_exec" || return 104 # ENOTRECOVERABLE 104 State not recoverable
	sleep 0.01 # closures complete in the background, so we need to sleep to have them happen now
}

# -------------------------------------
# Process Toolkit

function __is_process_alive {
	if [[ $# -ne 1 ]] || ! __is_positive_integer "$1" || [[ $1 -eq 0 ]]; then
		return 1
	fi
	local -i IS_PROCESS_ALIVE__id="$1"
	if [[ "$(ps -p "$IS_PROCESS_ALIVE__id" &>/dev/null || __print_string dead)" == 'dead' ]]; then
		return 1
	else
		return 0
	fi
}

function __is_trap_alive {
	if [[ -z $* ]]; then
		return 1
	fi
	local IS_TRAP_ALIVE__id="$1"
	if [[ -z "$(trap -p "$IS_TRAP_ALIVE__id" 2>/dev/null || :)" ]]; then
		return 1
	fi
	return 0
}

# -------------------------------------
# Semaphore Toolkit

function __get_semlock {
	local GET_SEMLOCK__context_id="$1" GET_SEMLOCK__dir="$TMPDIR/dorothy/semlocks" GET_SEMLOCK__semlock GET_SEMLOCK__wait GET_SEMLOCK__pid=$$
	__mkdirp "$GET_SEMLOCK__dir" || return $?
	# the lock file contains the process id that has the lock
	GET_SEMLOCK__semlock="${GET_SEMLOCK__dir}/${GET_SEMLOCK__context_id}.lock"
	# wait for a exclusive lock
	while :; do
		# don't bother with a [[ -s "$semlock" ]] before `cat` as the semlock could have been removed between
		GET_SEMLOCK__wait="$(cat "$GET_SEMLOCK__semlock" 2>/dev/null || :)"
		if [[ -z $GET_SEMLOCK__wait ]]; then
			__print_string "$GET_SEMLOCK__pid" >"$GET_SEMLOCK__semlock" || return $?
		elif [[ $GET_SEMLOCK__wait == "$GET_SEMLOCK__pid" ]]; then
			break
		elif ! __is_process_alive "$GET_SEMLOCK__wait"; then
			# the process is dead, it probably crashed, so failed to cleanup, so remove the lock file
			rm -f "$GET_SEMLOCK__semlock" || return $?
		fi
		sleep "0.01$RANDOM"
	done
	__print_lines "$GET_SEMLOCK__semlock" || return $?
}

# For semaphores, use $RANDOM$RANDOM as a single $RANDOM caused conflicts on Dorothy's CI tests when we didn't actually use semaphores, now that we use semaphores, we solve the underlying race conditions that caused the conflicts in the first place, however keep the double $RANDOM so it is enough entropy we don't have to bother for an existence check, here are the tests that had conflicts:
# https://github.com/bevry/dorothy/actions/runs/13038210988/job/36373738417#step:2:7505
# https://github.com/bevry/dorothy/actions/runs/13038210988/job/36373738417#step:2:12541
# as to why use `__get_semaphore` instead of `mktemp`, is that we want `dorothy test` to check if we cleaned everything up, furthermore, `mktemp` actually makes the files, so you have to do more expensive `-s` checks
function __get_semaphore {
	local GET_SEMAPHORE__context_id="${1:-"$RANDOM$RANDOM"}" GET_SEMAPHORE__dir="$TMPDIR/dorothy/semaphores"
	__mkdirp "$GET_SEMAPHORE__dir" || return $?
	__print_lines "${GET_SEMAPHORE__dir}/${GET_SEMAPHORE__context_id}" || return $?
}

# adds/appends the semaphores to the target array variable
# __semaphores --target={<array-variable-reference>} -- ...<context-id>
function __semaphores {
	# process reference argument
	local SEMAPHORES__item SEMAPHORES__variable_name='' SEMAPHORES__context_ids=() SEMAPHORES__size=''
	while [[ $# -ne 0 ]]; do
		SEMAPHORES__item="$1"
		shift
		case "$SEMAPHORES__item" in
		'--target={'*'}')
			__affirm_value_is_undefined "$SEMAPHORES__variable_name" 'target reference' || return $?
			__dereference --source="${SEMAPHORES__item#*=}" --name={SEMAPHORES__variable_name} || return $?
			;;
		'--size='*)
			__affirm_value_is_undefined "$SEMAPHORES__size" 'size/count of semaphores' || return $?
			SEMAPHORES__size="${SEMAPHORES__item#*=}"
			;;
		'--')
			SEMAPHORES__context_ids+=("$@")
			shift $#
			break
			;;
		'--'*) __unrecognised_flag "$TO__item" || return $? ;;
		*) __unrecognised_argument "$TO__item" || return $? ;;
		esac
	done
	# turn context ids into semaphores
	local SEMAPHORES__context_id SEMAPHORES__semaphores=() SEMAPHORES__index
	for SEMAPHORES__context_id in "${SEMAPHORES__context_ids[@]}"; do
		SEMAPHORES__semaphores+=("$(__get_semaphore "$SEMAPHORES__context_id")") || return $?
	done
	for ((SEMAPHORES__index = 0; SEMAPHORES__index < SEMAPHORES__size; SEMAPHORES__index++)); do
		SEMAPHORES__semaphores+=("$(__get_semaphore)") || return $?
	done
	# append the semaphores to the target
	eval "$SEMAPHORES__variable_name+=(\"\${SEMAPHORES__semaphores[@]}\")" || return 104 # ENOTRECOVERABLE 104 State not recoverable
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
	__wait_for_semaphores "$@" || return $?
	rm -f -- "$@" || return $?
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
			} || return $?
		fi
	done
	rm -f -- "$@" || :
	return "$semaphore_status"
}

# -------------------------------------
# Strings & Arrays Toolkit

# extract the value of a flag/option/argument
function __flag {
	local FLAG__filter='' FLAG__boolean='no' FLAG__invert='no' FLAG__export='no' FLAG__coerce='no' FLAG__empty='yes' FLAG__yes='yes' FLAG__no='no'
	# <single-source helper arguments>
	local FLAG__item FLAG__source_variable_name='' FLAG__targets=() FLAG__mode=''
	while [[ $# -ne 0 ]]; do
		local FLAG__item="$1"
		shift
		case "$FLAG__item" in
		'--source={'*'}')
			__affirm_value_is_undefined "$FLAG__source_variable_name" 'source variable reference' || return $?
			__dereference --source="${FLAG__item#*=}" --name={FLAG__source_variable_name} || return $?
			;;
		'--source+target={'*'}')
			FLAG__item="${FLAG__item#*=}"
			FLAG__targets+=("$FLAG__item")
			__affirm_value_is_undefined "$FLAG__source_variable_name" 'source variable reference' || return $?
			__dereference --source="$FLAG__item" --name={FLAG__source_variable_name} || return $?
			;;
		'--targets='*) __dereference --source="${FLAG__item#*=}" --append --value={FLAG__targets} || return $? ;;
		'--target='*) FLAG__targets+=("${FLAG__item#*=}") ;;
		'--yes='*) FLAG__yes="${FLAG__item#*=}" ;;
		'--no='*) FLAG__no="${FLAG__item#*=}" ;;
		'--mode=prepend' | '--mode=append' | '--mode=overwrite' | '--mode=')
			__affirm_value_is_undefined "$FLAG__mode" 'write mode' || return $?
			FLAG__mode="${FLAG__item#*=}"
			;;
		'--append' | '--prepend' | '--overwrite')
			__affirm_value_is_undefined "$FLAG__mode" 'write mode' || return $?
			FLAG__mode="${FLAG__item:2}"
			;;
		'--')
			__affirm_value_is_undefined "$FLAG__source_variable_name" 'source variable reference' || return $?
			# they are inputs
			if [[ $# -eq 1 ]]; then
				# a string input
				# trunk-ignore(shellcheck/SC2034)
				local FLAG__input="$1"
				FLAG__source_variable_name='FLAG__input'
			else
				# an array input
				# trunk-ignore(shellcheck/SC2034)
				local FLAG__inputs=("$@")
				FLAG__source_variable_name='FLAG__inputs'
			fi
			shift $#
			break
			;;
		# </single-source helper arguments>
		'--name='*)
			__affirm_value_is_undefined "$FLAG__filter" 'flag name filter' || return $?
			FLAG__filter="${FLAG__item#*=}"
			;;
		'--affirmative') FLAG__boolean='yes' ;; # consider enforcing coerce, which was to be opted out of for non yes/no values
		'--non-affirmative')                    # consider enforcing coerce, which has to be opted out of for non yes/no values
			FLAG__boolean='yes'
			FLAG__invert='yes'
			;;
		'--export') FLAG__export='yes' ;;
		'--coerce') FLAG__coerce='yes' ;;
		'--no-coerce') FLAG__coerce='no' ;;
		'--no-empty') FLAG__empty='no' ;; # aka --discard-empty, --fallback-on-empty, --ignore-empty
		'--'*) __unrecognised_flag "$FLAG__item" || return $? ;;
		*) __unrecognised_argument "$FLAG__item" || return $? ;;
		esac
	done
	# affirm
	__affirm_variable_is_defined "$FLAG__source_variable_name" 'source variable reference' || return $?
	__affirm_value_is_valid_write_mode "$FLAG__mode" || return $?
	if [[ $FLAG__coerce == 'yes' ]]; then
		if [[ $FLAG__boolean == 'no' ]]; then
			__print_lines "ERROR: ${FUNCNAME[0]}: Cannot coerce non-boolean flags, use --affirmative or --non-affirmative to coerce boolean values only." >&2 || :
			return 22 # EINVAL 22 Invalid argument
		fi
		FLAG__empty='no'
	fi
	# export
	if [[ $FLAG__export == 'yes' ]]; then
		for FLAG__item in "${FLAG__targets[@]}"; do
			if __is_reference "$FLAG__item"; then
				__dereference --source="$FLAG__item" --name={FLAG__item} || return $?
				# export the variable
				# trunk-ignore(shellcheck/SC2163)
				export "$FLAG__item"
			fi
		done
	fi
	# set the inputs
	if __is_array "$FLAG__source_variable_name"; then
		eval 'set -- "${'"$FLAG__source_variable_name"'[@]}"'
	else
		eval 'set -- "${'"$FLAG__source_variable_name"'}"'
	fi
	# process the inputs
	local FLAG__name FLAG__inverted FLAG__value FLAG__values=()
	local -i FLAG__index FLAG__name_size
	for FLAG__item in "$@"; do
		# check flag status
		if [[ ${FLAG__item:0:2} != '--' ]]; then
			# not a flag
			continue
		fi
		FLAG__index=2

		# check inversion
		if [[ ${FLAG__item:FLAG__index:3} == 'no-' ]]; then
			# is inverted
			FLAG__inverted='yes'
			FLAG__index=5
		else
			FLAG__inverted='no'
		fi

		# get the name
		FLAG__name="${FLAG__item:FLAG__index}"
		FLAG__name="${FLAG__name%%=*}"

		# if we are looking for a specific flag, check it is so
		if [[ -n $FLAG__filter && $FLAG__name != "$FLAG__filter" ]]; then
			# not our specific flag
			continue
		fi

		# get the value
		FLAG__name_size=${#FLAG__name}
		FLAG__value="${FLAG__item:FLAG__index+FLAG__name_size}"
		if [[ -z $FLAG__value ]]; then
			FLAG__value='yes'
		elif [[ ${FLAG__value:0:1} == '=' ]]; then
			# is a proper value, trim =
			FLAG__value="${FLAG__value:1}"
		else
			# we didn't actually find the option, we just found its prefix, continue
			continue
		fi

		# do we support empty
		if [[ -z $FLAG__value && $FLAG__empty == 'no' ]]; then
			# empty values are not allowed, so keep the original source value
			continue
		fi

		# convert the value if inverted, affirmative, or non-affirmative
		if [[ $FLAG__boolean == 'yes' ]]; then
			if [[ $FLAG__invert == 'no' ]]; then
				case "$FLAG__value" in
				'yes' | 'y' | 'true' | 'Y' | 'YES' | 'TRUE') FLAG__value='yes' ;;
				'no' | 'n' | 'false' | 'N' | 'NO' | 'FALSE') FLAG__value='no' ;;
				esac
			else
				case "$FLAG__value" in
				'yes' | 'y' | 'true' | 'Y' | 'YES' | 'TRUE') FLAG__value='no' ;;
				'no' | 'n' | 'false' | 'N' | 'NO' | 'FALSE') FLAG__value='yes' ;;
				esac
			fi
			if [[ $FLAG__coerce == 'yes' && $FLAG__value != 'yes' && $FLAG__value != 'no' ]]; then
				# error as invalid
				__print_lines "ERROR: ${FUNCNAME[0]}: Invalid boolean value for flag $(__dump --value="$FLAG__name" || :), it was: $(__dump --value="$FLAG__value" || :)" >&2 || :
				return 22 # EINVAL 22 Invalid argument
			fi
		fi
		if [[ $FLAG__inverted == 'yes' ]]; then
			if [[ $FLAG__value == 'yes' ]]; then
				FLAG__value='no'
			elif [[ $FLAG__value == 'no' ]]; then
				FLAG__value='yes'
			fi
		fi

		# convert to custom
		if [[ $FLAG__value == 'yes' ]]; then
			FLAG__value="$FLAG__yes"
		elif [[ $FLAG__value == 'no' ]]; then
			FLAG__value="$FLAG__no"
		fi

		# output
		FLAG__values+=("$FLAG__value")
	done

	# if we have values, apply them
	if [[ ${#FLAG__values[@]} -ne 0 ]]; then
		__to --source={FLAG__values} --mode="$FLAG__mode" --targets={FLAG__targets} || return $?
	fi
}

# appends the size with optional fill values to the the target array variables
function __array {
	local ARRAY__size='' ARRAY__fill=''
	# <no-source, multi-target, helper arguments>
	local ARRAY__item ARRAY__targets=() ARRAY__mode=''
	while [[ $# -ne 0 ]]; do
		ARRAY__item="$1"
		shift
		case "$ARRAY__item" in
		'--targets='*) __dereference --source="${ARRAY__item#*=}" --append --value={ARRAY__targets} || return $? ;;
		'--target='*) ARRAY__targets+=("${ARRAY__item#*=}") ;;
		'--mode=prepend' | '--mode=append' | '--mode=overwrite' | '--mode=')
			__affirm_value_is_undefined "$ARRAY__mode" 'write mode' || return $?
			ARRAY__mode="${ARRAY__item#*=}"
			;;
		'--append' | '--prepend' | '--overwrite')
			__affirm_value_is_undefined "$ARRAY__mode" 'write mode' || return $?
			ARRAY__mode="${ARRAY__item:2}"
			;;
		# </no-source, multi-target, helper arguments>
		'--size='*)
			__affirm_value_is_undefined "${ARRAY__size-}" 'array size' || return $?
			ARRAY__size="${ARRAY__item#*=}"
			;;
		'--fill='*)
			__affirm_value_is_undefined "$ARRAY__fill" 'array fill' || return $?
			ARRAY__fill="${ARRAY__item#*=}"
			;;
		'--'*) __unrecognised_flag "$ARRAY__item" || return $? ;;
		*) __unrecognised_argument "$ARRAY__item" || return $? ;;
		esac
	done
	# affirm
	__affirm_value_is_positive_integer "$ARRAY__size" 'array fill size' || return $?
	# generate the array values
	local ARRAY__index ARRAY__results=()
	for ((ARRAY__index = 0; ARRAY__index < ARRAY__size; ARRAY__index++)); do
		ARRAY__results+=("$ARRAY__fill")
	done
	__to --source={ARRAY__results} --mode="$ARRAY__mode" --targets={ARRAY__targets} --no-coerce || return $?
}

# reverses the array or string
function __reverse {
	# <single-source helper arguments>
	local REVERSE__item REVERSE__source_variable_name='' REVERSE__targets=() REVERSE__mode=''
	while [[ $# -ne 0 ]]; do
		REVERSE__item="$1"
		shift
		case "$REVERSE__item" in
		'--source={'*'}')
			__affirm_value_is_undefined "$REVERSE__source_variable_name" 'source variable reference' || return $?
			__dereference --source="${REVERSE__item#*=}" --name={REVERSE__source_variable_name} || return $?
			;;
		'--source+target={'*'}')
			REVERSE__item="${REVERSE__item#*=}"
			REVERSE__targets+=("$REVERSE__item")
			__affirm_value_is_undefined "$REVERSE__source_variable_name" 'source variable reference' || return $?
			__dereference --source="$REVERSE__item" --name={REVERSE__source_variable_name} || return $?
			;;
		'--targets='*) __dereference --source="${REVERSE__item#*=}" --append --value={REVERSE__targets} || return $? ;;
		'--target='*) REVERSE__targets+=("${REVERSE__item#*=}") ;;
		'--mode=prepend' | '--mode=append' | '--mode=overwrite' | '--mode=')
			__affirm_value_is_undefined "$REVERSE__mode" 'write mode' || return $?
			REVERSE__mode="${REVERSE__item#*=}"
			;;
		'--append' | '--prepend' | '--overwrite')
			__affirm_value_is_undefined "$REVERSE__mode" 'write mode' || return $?
			REVERSE__mode="${REVERSE__item:2}"
			;;
		'--')
			# they are inputs
			__affirm_value_is_undefined "$REVERSE__source_variable_name" 'source variable reference' || return $?
			if [[ $# -eq 1 ]]; then
				# a string input
				# trunk-ignore(shellcheck/SC2034)
				local REVERSE__input="$1"
				REVERSE__source_variable_name='REVERSE__input'
			else
				# an array input
				# trunk-ignore(shellcheck/SC2034)
				local REVERSE__inputs=("$@")
				REVERSE__source_variable_name='REVERSE__inputs'
			fi
			shift $#
			break
			;;
		# </single-source helper arguments>
		'--'*) __unrecognised_flag "$REVERSE__item" || return $? ;;
		*) __unrecognised_argument "$REVERSE__item" || return $? ;;
		esac
	done
	__affirm_variable_is_defined "$REVERSE__source_variable_name" 'source variable reference' || return $?
	__affirm_value_is_valid_write_mode "$REVERSE__mode" || return $?
	# action
	if __is_array "$REVERSE__source_variable_name"; then
		# support sparse arrays
		# trunk-ignore(shellcheck/SC2034)
		local REVERSE__indices=() REVERSE__results=()
		eval 'REVERSE__indices=("${!'"$REVERSE__source_variable_name"'[@]}")' || return 104 # ENOTRECOVERABLE 104 State not recoverable
		local -i REVERSE__index REVERSE__source_index REVERSE__size="${#REVERSE__indices[@]}"
		for ((REVERSE__index = REVERSE__size - 1; REVERSE__index >= 0; REVERSE__index--)); do
			REVERSE__source_index="${REVERSE__indices[REVERSE__index]}"
			eval 'REVERSE__results+=("${'"$REVERSE__source_variable_name"'[REVERSE__source_index]}")' || return 104 # ENOTRECOVERABLE 104 State not recoverable
		done
		__to --source={REVERSE__results} --mode="$REVERSE__mode" --targets={REVERSE__targets} || return $?
	else
		# trunk-ignore(shellcheck/SC2034)
		local REVERSE__result=''
		local -i REVERSE__source_index REVERSE__source_size
		eval 'REVERSE__source_size=${#'"$REVERSE__source_variable_name"'}' || return 104 # ENOTRECOVERABLE 104 State not recoverable
		for ((REVERSE__source_index = REVERSE__source_size - 1; REVERSE__source_index >= 0; REVERSE__source_index--)); do
			eval 'REVERSE__result+="${'"$REVERSE__source_variable_name"':REVERSE__source_index:1}"' || return 104 # ENOTRECOVERABLE 104 State not recoverable
		done
		__to --source={REVERSE__result} --mode="$REVERSE__mode" --targets={REVERSE__targets} || return $?
	fi
}

# get an array of indices of the array or string
function __indices {
	local INDICES__direction='ascending'
	# <single-source helper arguments>
	local INDICES__item INDICES__source_variable_name='' INDICES__targets=() INDICES__mode=''
	while [[ $# -ne 0 ]]; do
		INDICES__item="$1"
		shift
		case "$INDICES__item" in
		'--source={'*'}')
			__affirm_value_is_undefined "$INDICES__source_variable_name" 'source variable reference' || return $?
			__dereference --source="${INDICES__item#*=}" --name={INDICES__source_variable_name} || return $?
			;;
		'--source+target={'*'}')
			INDICES__item="${INDICES__item#*=}"
			INDICES__targets+=("$INDICES__item")
			__affirm_value_is_undefined "$INDICES__source_variable_name" 'source variable reference' || return $?
			__dereference --source="$INDICES__item" --name={INDICES__source_variable_name} || return $?
			;;
		'--targets='*) __dereference --source="${INDICES__item#*=}" --append --value={INDICES__targets} || return $? ;;
		'--target='*) INDICES__targets+=("${INDICES__item#*=}") ;;
		'--mode=prepend' | '--mode=append' | '--mode=overwrite' | '--mode=')
			__affirm_value_is_undefined "$INDICES__mode" 'write mode' || return $?
			INDICES__mode="${INDICES__item#*=}"
			;;
		'--append' | '--prepend' | '--overwrite')
			__affirm_value_is_undefined "$INDICES__mode" 'write mode' || return $?
			INDICES__mode="${INDICES__item:2}"
			;;
		'--')
			# they are inputs
			__affirm_value_is_undefined "$INDICES__source_variable_name" 'source variable reference' || return $?
			if [[ $# -eq 1 ]]; then
				# a string input
				# trunk-ignore(shellcheck/SC2034)
				local INDICES__input="$1"
				INDICES__source_variable_name='INDICES__input'
			else
				# an array input
				# trunk-ignore(shellcheck/SC2034)
				local INDICES__inputs=("$@")
				INDICES__source_variable_name='INDICES__inputs'
			fi
			shift $#
			break
			;;
		# </single-source helper arguments># direction mode:
		'--direction=descending' | '--direction=reverse' | '--direction=reversed' | '--descending' | '--reverse' | '--reversed') INDICES__direction='descending' ;;
		'--direction=ascending' | '--direction=forward' | '--ascending' | '--forward') INDICES__direction='ascending' ;; # default
		'--'*) __unrecognised_flag "$INDICES__item" || return $? ;;
		*) __unrecognised_argument "$INDICES__item" || return $? ;;
		esac
	done
	__affirm_variable_is_defined "$INDICES__source_variable_name" 'source variable reference' || return $?
	__affirm_value_is_valid_write_mode "$INDICES__mode" || return $?
	# action
	if __is_array "$INDICES__source_variable_name"; then
		# support sparse arrays
		local INDICES__indices=()
		eval 'INDICES__indices=("${!'"$INDICES__source_variable_name"'[@]}")' || return 104 # ENOTRECOVERABLE 104 State not recoverable
		if [[ $INDICES__direction == 'ascending' ]]; then
			__to --source={INDICES__indices} --mode="$INDICES__mode" --targets={INDICES__targets} || return $?
		else
			local INDICES__indices_reversed=()
			local -i INDICES__index INDICES__size="${#INDICES__indices[@]}"
			for ((INDICES__index = INDICES__size - 1; INDICES__index >= 0; INDICES__index--)); do
				INDICES__indices_reversed+=("${INDICES__indices[INDICES__index]}")
			done
			__to --source={INDICES__indices_reversed} --mode="$INDICES__mode" --targets={INDICES__targets} || return $?
		fi
	else
		local INDICES__indices=()
		local -i INDICES__index INDICES__size
		eval 'INDICES__size=${#'"$INDICES__source_variable_name"'}' || return 104 # ENOTRECOVERABLE 104 State not recoverable
		if [[ $INDICES__direction == 'ascending' ]]; then
			for ((INDICES__index = 0; INDICES__index < INDICES__size; INDICES__index++)); do
				INDICES__indices+=("$INDICES__index")
			done
		else
			for ((INDICES__index = INDICES__size - 1; INDICES__index >= 0; INDICES__index--)); do
				INDICES__indices+=("$INDICES__index")
			done
		fi
		__to --source={INDICES__indices} --mode="$INDICES__mode" --targets={INDICES__targets} || return $?
	fi
}

# set the targets to the value(s) at the indices of the source reference
function __at {
	local AT__indices=()
	# <single-source helper arguments>
	local AT__item AT__source_variable_name='' AT__targets=() AT__mode=''
	while [[ $# -ne 0 ]]; do
		AT__item="$1"
		shift
		case "$AT__item" in
		'--source={'*'}')
			__affirm_value_is_undefined "$AT__source_variable_name" 'source variable reference' || return $?
			__dereference --source="${AT__item#*=}" --name={AT__source_variable_name} || return $?
			;;
		'--source+target={'*'}')
			AT__item="${AT__item#*=}"
			AT__targets+=("$AT__item")
			__affirm_value_is_undefined "$AT__source_variable_name" 'source variable reference' || return $?
			__dereference --source="$AT__item" --name={AT__source_variable_name} || return $?
			;;
		'--targets='*) __dereference --source="${AT__item#*=}" --append --value={AT__targets} || return $? ;;
		'--target='*) AT__targets+=("${AT__item#*=}") ;;
		'--mode=prepend' | '--mode=append' | '--mode=overwrite' | '--mode=')
			__affirm_value_is_undefined "$AT__mode" 'write mode' || return $?
			AT__mode="${AT__item#*=}"
			;;
		'--append' | '--prepend' | '--overwrite')
			__affirm_value_is_undefined "$AT__mode" 'write mode' || return $?
			AT__mode="${AT__item:2}"
			;;
		'--')
			if [[ -z $AT__source_variable_name ]]; then
				# they are inputs
				if [[ $# -eq 1 ]]; then
					# a string input
					# trunk-ignore(shellcheck/SC2034)
					local AT__input="$1"
					AT__source_variable_name='AT__input'
				else
					# an array input
					# trunk-ignore(shellcheck/SC2034)
					local AT__inputs=("$@")
					AT__source_variable_name='AT__inputs'
				fi
			else
				# they are indices
				for AT__item in "$@"; do
					__affirm_value_is_integer "$AT__item" 'index' || return $?
				done
				AT__indices+=("$@")
			fi
			shift $#
			break
			;;
		# </single-source helper arguments>
		'--index='[0-9]* | '--index=-'[0-9]*)
			AT__item="${AT__item#*=}"
			__affirm_value_is_integer "$AT__item" 'index' || return $?
			AT__indices+=("$AT__item") ;;
		[0-9]* | '-'[0-9]*)
			__affirm_value_is_integer "$AT__item" 'index' || return $?
			AT__indices+=("$AT__item") ;;
		'--'*) __unrecognised_flag "$AT__item" || return $? ;;
		*) __unrecognised_argument "$AT__item" || return $? ;;
		esac
	done
	__affirm_variable_is_defined "$AT__source_variable_name" 'source variable reference' || return $?
	__affirm_value_is_valid_write_mode "$AT__mode" || return $?
	__affirm_length_defined "${#AT__indices[@]}" 'index' || return $?
	# action
	# trunk-ignore(shellcheck/SC2034)
	local AT__results=() AT__eval_segment AT__index # AT__index could be -0 which is string
	local -i AT__size AT__negative_size
	if __is_array "$AT__source_variable_name"; then
		eval "AT__size=\${#${AT__source_variable_name}[@]}"
		AT__eval_segment="AT__results+=(\"\${${AT__source_variable_name}[AT__index]}\")"
	else
		# AT__index could be negative, so wrap it in () to avoid bash version inconsistencies
		eval "AT__size=\${#${AT__source_variable_name}}"
		AT__eval_segment="AT__results+=(\"\${${AT__source_variable_name}:(\$AT__index):1}\")"
	fi
	AT__negative_size="$((AT__size * -1))"
	for AT__index in "${AT__indices[@]}"; do
		# validate the index
		if [[ $AT__index == '-0' ]]; then # -eq will convert -0 to 0
			__print_lines "ERROR: ${FUNCNAME[0]}: The index -0 convention only makes sense when used as a length; for a starting index that fetches the last character, you want -1." >&2 || :
			return 22 # EINVAL 22 Invalid argument
		elif [[ $AT__size -eq 0 || $AT__index -lt $AT__negative_size || $AT__index -ge $AT__size ]]; then
			__print_lines "ERROR: ${FUNCNAME[0]}: The index $(__dump --value="$AT__index" || :) was beyond the range of:" >&2 || :
			__dump --indices "$AT__source_variable_name" >&2 || :
			return 33 # EDOM 33 Numerical argument out of domain
		elif [[ $AT__index -lt 0 ]]; then
			AT__index="$((AT__size + AT__index))"
		fi
		eval "$AT__eval_segment" || return 104 # ENOTRECOVERABLE 104 State not recoverable
	done
	__to --source={AT__results} --mode="$AT__mode" --targets={AT__targets} || return $?
}

function __transform {
	local TRANSFORM__case='sensitive'
	# <single-source helper arguments>
	local TRANSFORM__item TRANSFORM__source_variable_name='' TRANSFORM__targets=() TRANSFORM__mode=''
	while [[ $# -ne 0 ]]; do
		TRANSFORM__item="$1"
		shift
		case "$TRANSFORM__item" in
		'--source={'*'}')
			__affirm_value_is_undefined "$TRANSFORM__source_variable_name" 'source variable reference' || return $?
			__dereference --source="${TRANSFORM__item#*=}" --name={TRANSFORM__source_variable_name} || return $?
			;;
		'--source+target={'*'}')
			TRANSFORM__item="${TRANSFORM__item#*=}"
			TRANSFORM__targets+=("$TRANSFORM__item")
			__affirm_value_is_undefined "$TRANSFORM__source_variable_name" 'source variable reference' || return $?
			__dereference --source="$TRANSFORM__item" --name={TRANSFORM__source_variable_name} || return $?
			;;
		'--targets='*) __dereference --source="${TRANSFORM__item#*=}" --append --value={TRANSFORM__targets} || return $? ;;
		'--target='*) TRANSFORM__targets+=("${TRANSFORM__item#*=}") ;;
		'--mode=prepend' | '--mode=append' | '--mode=overwrite' | '--mode=')
			__affirm_value_is_undefined "$TRANSFORM__mode" 'write mode' || return $?
			TRANSFORM__mode="${TRANSFORM__item#*=}"
			;;
		'--append' | '--prepend' | '--overwrite')
			__affirm_value_is_undefined "$TRANSFORM__mode" 'write mode' || return $?
			TRANSFORM__mode="${TRANSFORM__item:2}"
			;;
		'--')
			__affirm_value_is_undefined "$TRANSFORM__source_variable_name" 'source variable reference' || return $?
			# they are inputs
			if [[ $# -eq 1 ]]; then
				# a string input
				# trunk-ignore(shellcheck/SC2034)
				local TRANSFORM__input="$1"
				TRANSFORM__source_variable_name='TRANSFORM__input'
			else
				# an array input
				# trunk-ignore(shellcheck/SC2034)
				local TRANSFORM__inputs=("$@")
				TRANSFORM__source_variable_name='TRANSFORM__inputs'
			fi
			shift $#
			break
			;;
		# </single-source helper arguments>
		'--case=upper' | '--uppercase') TRANSFORM__case='upper' ;;
		'--case=lower' | '--lowercase') TRANSFORM__case='lower' ;;
		'--case=sensitive') TRANSFORM__case='sensitive' ;;
		'--case=') : ;;
		# later on there will be more transformations
		'--'*) __unrecognised_flag "$TRANSFORM__item" || return $? ;;
		*) __unrecognised_argument "$TRANSFORM__item" || return $? ;;
		esac
	done
	__affirm_variable_is_defined "$TRANSFORM__source_variable_name" 'source variable reference' || return $?
	__affirm_value_is_valid_write_mode "$TRANSFORM__mode" || return $?
	if [[ "$TRANSFORM__case" == 'sensitive' ]]; then
		# nothing to do so exit early
		__to --source={TRANSFORM__result} --mode="$TRANSFORM__mode" --targets={TRANSFORM__targets} || return $?
		return 0
	fi
	# action
	# we do a sparse array check here, as the native case changes convert sparse arrays into complete arrays by redoing indices
	if [[ -n $BASH_NATIVE_UPPERCASE_SUFFIX ]] && ! __is_sparse_array "$TRANSFORM__source_variable_name"; then
		if __is_array "$TRANSFORM__source_variable_name"; then
			local TRANSFORM__results=()
			case "$TRANSFORM__case" in
			'upper') eval 'TRANSFORM__results=("${'"$TRANSFORM__source_variable_name"'[@]'"$BASH_NATIVE_UPPERCASE_SUFFIX"'}")' || return 104 ;; # ENOTRECOVERABLE 104 State not recoverable
			'lower') eval 'TRANSFORM__results=("${'"$TRANSFORM__source_variable_name"'[@]'"$BASH_NATIVE_LOWERCASE_SUFFIX"'}")' || return 104 ;; # ENOTRECOVERABLE 104 State not recoverable
			esac
			__to --source={TRANSFORM__results} --mode="$TRANSFORM__mode" --targets={TRANSFORM__targets} || return $?
		else
			local TRANSFORM__result=''
			case "$TRANSFORM__case" in
			'upper') eval 'TRANSFORM__result="${'"${TRANSFORM__source_variable_name}${BASH_NATIVE_UPPERCASE_SUFFIX}"'}"' || return 104 ;; # ENOTRECOVERABLE 104 State not recoverable
			'lower') eval 'TRANSFORM__result="${'"${TRANSFORM__source_variable_name}${BASH_NATIVE_LOWERCASE_SUFFIX}"'}"' || return 104 ;; # ENOTRECOVERABLE 104 State not recoverable
			esac
			__to --source={TRANSFORM__result} --mode="$TRANSFORM__mode" --targets={TRANSFORM__targets} || return $?
		fi
	else
		if __is_array "$TRANSFORM__source_variable_name"; then
			local -i TRANSFORM__index
			# trunk-ignore(shellcheck/SC2034)
			local TRANSFORM__results=() TRANSFORM__indices=()
			__indices --source="{$TRANSFORM__source_variable_name}" --target={TRANSFORM__indices} || return $?
			# trunk-ignore(shellcheck/SC2034)
			for TRANSFORM__index in "${TRANSFORM__indices[@]}"; do
				case "$TRANSFORM__case" in
				'upper') eval 'TRANSFORM__results[TRANSFORM__index]="$(__get_uppercase_string -- "${'"$TRANSFORM__source_variable_name"'[TRANSFORM__index]}")"' || return 104 ;; # ENOTRECOVERABLE 104 State not recoverable
				'lower') eval 'TRANSFORM__results[TRANSFORM__index]="$(__get_lowercase_string -- "${'"$TRANSFORM__source_variable_name"'[TRANSFORM__index]}")"' || return 104 ;; # ENOTRECOVERABLE 104 State not recoverable
				esac
			done
			__to --source={TRANSFORM__results} --mode="$TRANSFORM__mode" --targets={TRANSFORM__targets} || return $?
		else
			# trunk-ignore(shellcheck/SC2034)
			local TRANSFORM__result=''
			case "$TRANSFORM__case" in
			'upper') eval 'TRANSFORM__result="$(__get_uppercase_string -- "${'"$TRANSFORM__source_variable_name"'}")"' || return 104 ;; # ENOTRECOVERABLE 104 State not recoverable
			'lower') eval 'TRANSFORM__result="$(__get_lowercase_string -- "${'"$TRANSFORM__source_variable_name"'}")"' || return 104 ;; # ENOTRECOVERABLE 104 State not recoverable
			esac
			__to --source={TRANSFORM__result} --mode="$TRANSFORM__mode" --targets={TRANSFORM__targets} || return $?
		fi
	fi
}

# -----------------------------------------------------------------------------
# A NOTE ON THE REMOVAL OF `--keep-*` ARGUMENTS
#
# `__iterate`, `__evict`, `__slice` all use to contain support `--keep-*` arguments, however they were all better served by either `__replace` or by the following two calls:
#
# `--keep-before-first=*` is:
# `__index --forward --source={my_array_or_string} --target={the_index} --value="my-needle"`
# `__slice --source+target={my_array_or_string} -- 0 "$the_index"`
#
# `--keep-before-last=*` is:
# `__index --reverse --source={my_array_or_string} --target={the_index} --value="my-needle"`
# `__slice --source+target={my_array_or_string} -- 0 "$the_index"`
#
# `--keep-after-first=*` is:
# `__index --forward --source={my_array_or_string} --target={the_index} --value="my-needle"`
# `__slice --source+target={my_array_or_string} -- "$((the_index + 1))"`
#
# `--keep-after-last=*` is:
# `__index --reverse --source={my_array_or_string} --target={the_index} --value="my-needle"`
# `__slice --source+target={my_array_or_string} -- "$((the_index + 1))"`
#
# for their original implementation, see fb6ead4ea1a16506af6536aa08ce227e9eb98867fb6ead4ea1a16506af6536aa08ce227e9eb98867 and its subsequent commit for their removal

# -----------------------------------------------------------------------------
# WHAT IS `__iterate`
#
# It is the super function of `__index`, `__has`, and `__evict`.
# They use to all be distinct functions, however, it turns out they are all the same internals only with different outputs.
#
# -----------------------------------------------------------------------------
# HOW DOES `__iterate` WORK
#
# Indices are fetched via `__indices` for the source reference, this supports strings, arrays, and sparse arrays.
# If there are no indices:
# - `__has` will return `1`
# - `__evict` will send the result, which will just be the empty source
# - `__index` will fail
#
# We then fetch the first and last indices in the original order, for use by `--{suffix,prefix}` lookups.
#
# If reversing/descending, indices are now reversed, and we extract the first in the new order, for use by `--{pattern,glob}` lookups.
#
# We then extract whether our source is an array or not, and validate lookups accordingly.
# Array sources can lookup empty array items, other empty lookups don't make sense.
# String sources don't make sense with any empty lookup.
#
# BY MODE:
# To iterate over the source, this is determined by `--by={lookup,cursor}`.
# If `--by=lookup`, we iterate by each lookup, with each lookup cycling through all index cursors.
# If `--by=cursor`, we iterate over each cursor index, with each index cycling through each lookup.
# i.e.
# If we do `--first` (which is `--by=lookup --seek=first --require=any`), we seek the first lookup in their lookup order, e.g. `__iterate --first --value=b --value=a -- abc` will match `b` and output `1`.
# If we do `--any` (which is `--by=cursor --seek=first --require=any`), we seek the first lookup in their cursor order, e.g. `__iterate --any --value=b --value=a -- abc` will match `a` and output `0`.
#
# SEEK MODE:
# If `--seek=first`, the operation will conclude upon the first matched lookup.
# If `--seek=each`, the operation will conclude after the source content is exhausted or after all lookups have been consumed, whichever occurs first; each lookup can only be matched once, in which it is marked as consumed, and unable to be used again.
# If `--seek=multiple`, the operation will conclude after the source content is exhausted
# once a match has completed, OVERLAP MODE takes effect.
#
# OVERLAP MODE:
# If `--overlap`, then in `each` and `multiple` seek modes, additional matches are allowed on the same cursor position and (if source content is a string) throughout the matched lookup segment.
# If `--no-overlap`, then in `each` and `multiple` seek modes, no more matches are allowed within the cursor position and (if source content is a string) the matched lookup segment, skipping around it.
#
# REQUIRE MODE:
# Upon conclusion of the operation:
# If `--require=none`, no checks for matched lookups are made.
# If `--require=any`, at least one lookup must have matched at least once.
# If `--require=all`, all the specified lookups must have matched at least once.
# If no require mode failures, then the noted indexes are sent to the targets.
function __iterate {
	__pause_tracing || return $?
	local ITERATE__lookups=() ITERATE__direction='ascending' ITERATE__seek='' ITERATE__overlap='no' ITERATE__require='' ITERATE__quiet='no' ITERATE__by='' ITERATE__operation='' ITERATE__case='sensitive'
	# <single-source helper arguments>
	local ITERATE__item ITERATE__source_variable_name='' ITERATE__targets=() ITERATE__mode=''
	while [[ $# -ne 0 ]]; do
		ITERATE__item="$1"
		shift
		case "$ITERATE__item" in
		'--source={'*'}')
			__affirm_value_is_undefined "$ITERATE__source_variable_name" 'source variable reference' || return $?
			__dereference --source="${ITERATE__item#*=}" --name={ITERATE__source_variable_name} || return $?
			;;
		'--source+target={'*'}')
			ITERATE__item="${ITERATE__item#*=}"
			ITERATE__targets+=("$ITERATE__item")
			__affirm_value_is_undefined "$ITERATE__source_variable_name" 'source variable reference' || return $?
			__dereference --source="$ITERATE__item" --name={ITERATE__source_variable_name} || return $?
			;;
		'--targets='*) __dereference --source="${ITERATE__item#*=}" --append --value={ITERATE__targets} || return $? ;;
		'--target='*) ITERATE__targets+=("${ITERATE__item#*=}") ;;
		'--mode=prepend' | '--mode=append' | '--mode=overwrite' | '--mode=')
			__affirm_value_is_undefined "$ITERATE__mode" 'write mode' || return $?
			ITERATE__mode="${ITERATE__item#*=}"
			;;
		'--append' | '--prepend' | '--overwrite')
			__affirm_value_is_undefined "$ITERATE__mode" 'write mode' || return $?
			ITERATE__mode="${ITERATE__item:2}"
			;;
		'--')
			if [[ -z $ITERATE__source_variable_name ]]; then
				# they are inputs
				if [[ $# -eq 1 ]]; then
					# a string input
					# ITERATE__input="$1"
					# ITERATE__source_variable_name='ITERATE__input'
					# ^ this doesn't allow for recursive sources, whereas the below does
					ITERATE__source_variable_name="ITERATE_${RANDOM}__input"
					eval "local $ITERATE__source_variable_name=\"\$1\"" || return 104 # ENOTRECOVERABLE 104 State not recoverable
				else
					# an array input
					# ITERATE__inputs=("$@")
					# ITERATE__source_variable_name='ITERATE__inputs'
					# ^ this doesn't allow for recursive sources, whereas the below does
					ITERATE__source_variable_name="ITERATE_${RANDOM}__inputs"
					eval "local $ITERATE__source_variable_name=(\"\$@\")" || return 104 # ENOTRECOVERABLE 104 State not recoverable
				fi
			else
				# they are needles
				for ITERATE__item in "$@"; do
					ITERATE__lookups+=(--needle="$ITERATE__item")
				done
			fi
			shift $#
			break
			;;
		# </single-source helper arguments>
		# lookups:
		'--value='* | '--needle='* | '--index='* | '--prefix='* | '--suffix='* | '--pattern='* | '--glob='*) ITERATE__lookups+=("$ITERATE__item") ;;
		# order mode
		'--by=lookup' | '--order=lookup' | '--order=argument' | '--lookup') ITERATE__by='lookup' ;;
		'--by=cursor' | '--by=content' | '--order=content' | '--order=source' | '--cursor') ITERATE__by='content' ;;
		# content direction mode
		'--direction=descending' | '--direction=reverse' | '--descending' | '--reverse') ITERATE__direction='descending' ;;
		'--direction=ascending' | '--direction=forward' | '--ascending' | '--forward') ITERATE__direction='ascending' ;; # default
		# seek mode
		'--seek=first' | '--first') ITERATE__seek='first' ;;                                   # only the first match of any needle
		'--seek=each' | '--each') ITERATE__seek='each' ;;                                      # only the first match of each needle
		'--seek=every' | '--seek=multiple' | '--every' | '--multiple') ITERATE__seek='multiple' ;; # all matches of all needles
		# overlap mode
		'--overlap=yes' | '--overlap') ITERATE__overlap='yes' ;;  # for `seek=multiple` string matches, "aaaa" with needles "aa" and "a" will match "aa" 3 times and "a" 4 times, for `seek=each` string matches, "aab" will match needles "aa" 1 time and "ab" 1 time
		'--overlap=no' | '--no-overlap') ITERATE__overlap='no' ;; # for `seek=multiple` string matches, "aaaa" with needles "aa" and "a" will match "aa" twice and "a" 0 times, for `seek=each` string matches, "aab" will match needles "aa" 1 time and "ab" 0 times
		# require mode
		'--require=none' | '--optional') ITERATE__require='none' ;;
		'--require=any' | '--any') ITERATE__require='any' ;;
		'--require=all' | '--all' | '--required') ITERATE__require='all' ;;
		# quiet mode
		'--no-verbose'* | '--verbose'*) __flag --source={ITERATE__item} --target={ITERATE__quiet} --non-affirmative --coerce ;;
		'--no-quiet'* | '--quiet'*) __flag --source={ITERATE__item} --target={ITERATE__quiet} --affirmative --coerce ;;
		# case mode
		'--case=upper' | '--uppercase') ITERATE__case='upper' ;; # result/compare
		'--case=lower' | '--lowercase') ITERATE__case='lower' ;; # result/compare
		'--case=ignore' | '--ignore-case') ITERATE__case='ignore' ;; # compare
		'--case=sensitive') ITERATE__case='sensitive' ;;
		'--case=') : ;;
		# operation mode
		'--operation=index' | '--index' | '--indices') ITERATE__operation='index' ;;
		'--operation=has' | '--has')
			ITERATE__operation='has'
			ITERATE__quiet='yes'
			;;
		'--operation=evict' | '--evict') ITERATE__operation='evict' ;;
		'--operation=filter' | '--filter') ITERATE__operation='filter' ;;
		# evict on mode
		# '--on=content') ITERATE__on='content' ;;
		# '--on=result') ITERATE__on='result' ;; <-- this would work by wrapping the iteration in a while loop, that checks if there is another iteration to perform, which is enabled when the content is changed in which case the indices and their corresponding variables are regenerated, however, with that complexity, one is probably just wanting the `__replace` function
		# shortcut mode mostly for has/evict
		'--'*) __unrecognised_flag "$ITERATE__item" || return $? ;;
		*) __unrecognised_argument "$ITERATE__item" || return $? ;;
		esac
	done
	local -i ITERATE__lookups_size="${#ITERATE__lookups[@]}"
	__affirm_value_is_defined "$ITERATE__operation" 'operation' || return $?
	__affirm_variable_is_defined "$ITERATE__source_variable_name" 'source variable reference' || return $?
	__affirm_value_is_valid_write_mode "$ITERATE__mode" || return $?
	__affirm_length_defined "$ITERATE__lookups_size" 'lookup' || return $?
	# handle the new automatic inference or failure of inference of various modes
	if [[ -z $ITERATE__seek ]]; then
		if [[ $ITERATE__operation == 'evict' ]]; then
			__print_lines "ERROR: ${FUNCNAME[0]}: The $(__dump --value=evict || :) operation requires an explicit $(__dump --value='{first,each,every}' || :) seek mode." >&2 || :
			__dump {ITERATE__lookups} "{$ITERATE__source_variable_name}" >&2 || :
			return 22 # EINVAL 22 Invalid argument
		elif [[ $ITERATE__require == 'any' ]]; then
			if [[ -z $ITERATE__by ]]; then
				ITERATE__by='cursor' # this default is only done, as it doesn't matter in first/any mode
			fi
			ITERATE__seek='first'
		elif [[ $ITERATE__lookups_size -eq 1 || $ITERATE__require == 'all' ]]; then
			# if all, then default to each, as desiring every is an edge case typically only for evict, which we've already aborted
			ITERATE__seek='each' # first/each are equivalent when there is only one lookup
		else
			__print_lines "ERROR: ${FUNCNAME[0]}: The $(__dump --value="$ITERATE__operation" || :) operation requires an explicit $(__dump --value='{first,each,every}' || :) seek mode when using multiple lookups." >&2 || :
			__dump {ITERATE__lookups} "{$ITERATE__source_variable_name}" >&2 || :
			return 22 # EINVAL 22 Invalid argument
		fi
	fi
	if [[ -z $ITERATE__require ]]; then
		if [[ $ITERATE__seek == 'first' ]]; then
			ITERATE__require='any' # if they are seeking first, then all is a mistake, and none is unlikely
		elif [[ $ITERATE__operation == 'evict' ]]; then
			__print_lines "ERROR: ${FUNCNAME[0]}: The $(__dump --value=evict || :) operation requires an explicit $(__dump --value='{optional,any,all}' || :) require mode." >&2 || :
			__dump {ITERATE__lookups} "{$ITERATE__source_variable_name}" >&2 || :
			return 22 # EINVAL 22 Invalid argument
		elif [[ $ITERATE__lookups_size -eq 1 ]]; then
			ITERATE__require='any' # any/all are equivalent when there is only one lookup
		elif [[ $ITERATE__operation == 'has' ]]; then
			__print_lines "ERROR: ${FUNCNAME[0]}: $(__dump --value=has || :) operation requires an explicit $(__dump --value='{any,all}' || :) require mode when using multiple lookups." >&2 || :
			__dump {ITERATE__lookups} "{$ITERATE__source_variable_name}" >&2 || :
			return 22 # EINVAL 22 Invalid argument
		else
			ITERATE__require='all'
		fi
	fi
	if [[ -z $ITERATE__by ]]; then
		ITERATE__by='lookup'
	fi
	# sanity checks
	__affirm_value_is_defined "$ITERATE__by" 'by mode' || return $?
	__affirm_value_is_defined "$ITERATE__seek" 'seek mode' || return $?
	__affirm_value_is_defined "$ITERATE__require" 'require mode' || return $?
	# ensure that if multiple lookups were specified, it can't be all and first
	if [[ $ITERATE__lookups_size -gt 1 && $ITERATE__require == 'all' && $ITERATE__seek == 'first' ]]; then
		__print_lines "ERROR: ${FUNCNAME[0]}: The $(__dump --value=first || :) seek mode cannot be used with the $(__dump --value=all || :) require mode when multiple lookups are specified, as such would always fail." >&2 || :
		__dump {ITERATE__lookups} "{$ITERATE__source_variable_name}" >&2 || :
		return 22 # EINVAL 22 Invalid argument
	fi
	# get the indices
	local ITERATE__indices=()
	__indices --source="{$ITERATE__source_variable_name}" --target={ITERATE__indices} || return $?
	# affirm there are indices available
	local -i ITERATE__size="${#ITERATE__indices[@]}"
	if [[ $ITERATE__size -eq 0 ]]; then
		case "$ITERATE__operation" in
		has) return 1 ;;
		evict)
			__to --source="{$ITERATE__source_variable_name}" --mode="$ITERATE__mode" --targets={ITERATE__targets} || return $?
			return 0
			;;
		esac
		__affirm_length_defined "$ITERATE__size" 'source' || {
			local -i ITERATE__exit_status="$?"
			__dump {ITERATE__source_variable_name} {ITERATE__targets} {ITERATE__operation} {ITERATE__lookups} >&2 || :
			return "$ITERATE__exit_status"
		}
	fi
	# get the first and last indices for use with prefix/suffix
	# trunk-ignore(shellcheck/SC2124)
	local -i ITERATE__first_in_whole="${ITERATE__indices[0]}" ITERATE__last_in_whole="${ITERATE__indices[@]: -1}"
	# reverse the indices if desired
	if [[ $ITERATE__direction == 'descending' ]]; then
		__reverse --source+target={ITERATE__indices} || return $?
	fi
	# get the first and last indices for use with pattern/glob
	local -i ITERATE__first_in_order="${ITERATE__indices[0]}" # ITERATE__last_in_order="${ITERATE__indices[@]: -1}"
	# prepare array awareness
	local ITERATE__array
	if __is_array "$ITERATE__source_variable_name"; then
		ITERATE__array=yes
		# if we are an array, validate what can be empty and what cannot be
		for ITERATE__item in "${ITERATE__lookups[@]}"; do
			if [[ -z ${ITERATE__item#*=} ]]; then
				case "$ITERATE__item" in
				# we can lookup empty array elements
				'--value='* | '--needle='*) : ;;

				# these lookups make no sense if they are empty
				'--prefix='* | '--suffix='* | '--pattern='* | '--glob='*)
					__print_lines "ERROR: ${FUNCNAME[0]}: The $(__dump --value="$ITERATE__item" || :) option must not have an empty value." >&2 || :
					__dump {ITERATE__lookups} "{$ITERATE__source_variable_name}" >&2 || :
					return 22 # EINVAL 22 Invalid argument
					;;

				# invalid lookup
				*) __unrecognised_flag "$ITERATE__item" || return $? ;;
				esac
			fi
		done
	else
		ITERATE__array=no
		# if we are a string, ensure no empty lookups, as none of them make sense if empty
		for ITERATE__item in "${ITERATE__lookups[@]}"; do
			if [[ -z ${ITERATE__item#*=} ]]; then
				__print_lines "ERROR: ${FUNCNAME[0]}: The $(__dump --value="$ITERATE__item" || :) option must not have an empty value when the input is a string." >&2 || :
				__dump {ITERATE__lookups} "{$ITERATE__source_variable_name}" >&2 || :
				return 22 # EINVAL 22 Invalid argument
			fi
		done
	fi
	# case
	if [[ $ITERATE__case != 'sensitive' ]]; then
		shopt -s nocasematch
	fi
	# iterate
	local -i ITERATE__outer ITERATE__inner ITERATE__index ITERATE__lookup_index ITERATE__lookup_size ITERATE__match_index ITERATE__match_size ITERATE__overlap_index ITERATE__break
	local ITERATE__results=() ITERATE__consumed_indices_map=() ITERATE__consumed_lookups_map=() ITERATE__lookups_indices=("${!ITERATE__lookups[@]}") ITERATE__value ITERATE__lookup_option ITERATE__lookup ITERATE__match ITERATE__matched
	if [[ $ITERATE__by == 'lookup' ]]; then
		ITERATE__outers=("${ITERATE__lookups_indices[@]}")
		ITERATE__inners=("${ITERATE__indices[@]}")
	else
		ITERATE__outers=("${ITERATE__indices[@]}")
		ITERATE__inners=("${ITERATE__lookups_indices[@]}")
	fi
	function __is_string_overlapped {
		if [[ $ITERATE__overlap == 'no' ]]; then
			for ((ITERATE__overlap_index = ITERATE__match_index; ITERATE__overlap_index < ITERATE__match_index + ITERATE__lookup_size; ITERATE__overlap_index++)); do
				if [[ -n ${ITERATE__consumed_indices_map[ITERATE__overlap_index]-} ]]; then
					return 0
				fi
			done
		fi
		return 1
	}
	for ITERATE__outer in "${ITERATE__outers[@]}"; do
		for ITERATE__inner in "${ITERATE__inners[@]}"; do
			# adjust for our iteration mode
			if [[ $ITERATE__by == 'lookup' ]]; then
				ITERATE__lookup_index="$ITERATE__outer" ITERATE__index="$ITERATE__inner"
			else
				ITERATE__index="$ITERATE__outer" ITERATE__lookup_index="$ITERATE__inner"
			fi
			# has this lookup index or content index already been consumed? these maps are always updated, regardless of modes
			if [[ $ITERATE__overlap == 'no' && -n ${ITERATE__consumed_indices_map[ITERATE__index]-} ]] || [[ $ITERATE__seek == 'each' && -n ${ITERATE__consumed_lookups_map[ITERATE__lookup_index]-} ]]; then
				continue
			fi
			# handle the lookup
			ITERATE__lookup_option="${ITERATE__lookups[ITERATE__lookup_index]}" ITERATE__match='' ITERATE__matched=no ITERATE__value='' ITERATE__match_index=$ITERATE__index ITERATE__break=0
			ITERATE__lookup="${ITERATE__lookup_option#*=}"
			case "$ITERATE__lookup_option" in
			'--value='* | '--needle='*)
				# exact match
				if [[ $ITERATE__array == 'yes' ]]; then
					eval 'ITERATE__value=${'"$ITERATE__source_variable_name"'[ITERATE__index]}' || return 104 # ENOTRECOVERABLE 104 State not recoverable
				else
					ITERATE__lookup_size=${#ITERATE__lookup}
					if [[ $ITERATE__direction == 'ascending' ]]; then
						# ascending, so we need to look right-ways
						if [[ $((ITERATE__match_index + ITERATE__lookup_size)) -le $ITERATE__size ]]; then
							# when not overlapping, validate none of the indices have been consumed
							if __is_string_overlapped; then
								continue
							fi
							# valid, note the match value
							eval 'ITERATE__value="${'"$ITERATE__source_variable_name"':ITERATE__match_index:ITERATE__lookup_size}"' || return 104 # ENOTRECOVERABLE 104 State not recoverable
						else
							continue
						fi
					else
						# descending, so we need to look left-ways
						ITERATE__match_index=$((ITERATE__index - ITERATE__lookup_size + 1)) # +1 to include the current character
						if [[ $ITERATE__match_index -ge 0 ]]; then
							# when not overlapping, validate none of the indices have been consumed
							if __is_string_overlapped; then
								continue
							fi
							# valid, note the match value
							eval 'ITERATE__value="${'"$ITERATE__source_variable_name"':ITERATE__match_index:ITERATE__lookup_size}"' || return 104 # ENOTRECOVERABLE 104 State not recoverable
						else
							continue
						fi
					fi
				fi
				if [[ $ITERATE__value == "$ITERATE__lookup" ]]; then
					ITERATE__matched=yes
					ITERATE__match="$ITERATE__value" # substring match
					ITERATE__consumed_lookups_map[ITERATE__lookup_index]="$ITERATE__index"
				else
					continue
				fi
				;;
			'--index='*)
				# index match
				ITERATE__lookup_size=1
				if [[ $ITERATE__array == 'yes' ]]; then
					eval 'ITERATE__value=${'"$ITERATE__source_variable_name"'[ITERATE__index]}' || return 104 # ENOTRECOVERABLE 104 State not recoverable
				else
					eval 'ITERATE__value="${'"$ITERATE__source_variable_name"':ITERATE__index:1}"' || return 104 # ENOTRECOVERABLE 104 State not recoverable
				fi
				if [[ $ITERATE__index == "$ITERATE__lookup" ]]; then
					ITERATE__matched=yes
					ITERATE__match="$ITERATE__value"
					ITERATE__consumed_lookups_map[ITERATE__lookup_index]="$ITERATE__index"
				else
					continue
				fi
				;;
			'--prefix='*)
				# prefix match
				ITERATE__lookup_size=${#ITERATE__lookup}
				if [[ $ITERATE__array == 'yes' ]]; then
					eval 'ITERATE__value=${'"$ITERATE__source_variable_name"'[ITERATE__index]:0:ITERATE__lookup_size}' || return 104 # ENOTRECOVERABLE 104 State not recoverable
				elif [[ $ITERATE__index -eq $ITERATE__first_in_whole ]]; then # only match when we are at the first in whole index
					# when not overlapping, validate none of the indices have been consumed
					if __is_string_overlapped; then
						continue
					fi
					# valid, note the match value
					eval 'ITERATE__value="${'"$ITERATE__source_variable_name"':0:ITERATE__lookup_size}"' || return 104 # ENOTRECOVERABLE 104 State not recoverable
				else
					continue
				fi
				if [[ $ITERATE__value == "$ITERATE__lookup" ]]; then
					ITERATE__matched=yes
					ITERATE__match="$ITERATE__value" # substring match
					ITERATE__consumed_lookups_map[ITERATE__lookup_index]="$ITERATE__index"
				else
					continue
				fi
				;;
			'--suffix='*)
				# suffix match
				ITERATE__lookup_size=${#ITERATE__lookup}
				if [[ $ITERATE__array == 'yes' ]]; then
					eval 'ITERATE__value=${'"$ITERATE__source_variable_name"'[ITERATE__index]: -ITERATE__lookup_size}' || return 104 # ENOTRECOVERABLE 104 State not recoverable
				elif [[ $ITERATE__index -eq $ITERATE__last_in_whole ]]; then         # only match once when we are at the last in whole index
					ITERATE__match_index=$((ITERATE__index - ITERATE__lookup_size + 1)) # +1 to include the current character# when not overlapping, validate none of the indices have been consumed
					if __is_string_overlapped; then
						continue
					fi
					# valid, note the match value
					eval 'ITERATE__value="${'"$ITERATE__source_variable_name"':ITERATE__match_index}"' || return 104 # ENOTRECOVERABLE 104 State not recoverable
				else
					continue
				fi
				if [[ $ITERATE__value == "$ITERATE__lookup" ]]; then
					ITERATE__matched=yes
					ITERATE__match="$ITERATE__value" # substring match
					ITERATE__consumed_lookups_map[ITERATE__lookup_index]="$ITERATE__index"
				else
					continue
				fi
				;;
			'--pattern='*)
				# pattern match: POSIX extended regular expression
				if [[ $ITERATE__array == 'yes' ]]; then
					eval 'ITERATE__value=${'"$ITERATE__source_variable_name"'[ITERATE__index]}' || return 104 # ENOTRECOVERABLE 104 State not recoverable
				elif [[ $ITERATE__index -eq $ITERATE__first_in_order ]]; then
					# whole string match
					eval 'ITERATE__value="${'"$ITERATE__source_variable_name"'}"' || return 104 # ENOTRECOVERABLE 104 State not recoverable
				else
					continue
				fi
				if [[ $ITERATE__value =~ $ITERATE__lookup ]] && [[ -n ${BASH_REMATCH[0]-} ]]; then # workaround a bash bug
					ITERATE__matched=yes
					ITERATE__match="$ITERATE__value" # whole string match
					ITERATE__consumed_lookups_map[ITERATE__lookup_index]="$ITERATE__index"
				else
					continue
				fi
				;;
			'--glob='*)
				# pattern match
				if [[ $ITERATE__array == 'yes' ]]; then
					eval 'ITERATE__value=${'"$ITERATE__source_variable_name"'[ITERATE__index]}' || return 104 # ENOTRECOVERABLE 104 State not recoverable
				elif [[ $ITERATE__index -eq $ITERATE__first_in_order ]]; then
					# whole string match
					eval 'ITERATE__value="${'"$ITERATE__source_variable_name"'}"' || return 104 # ENOTRECOVERABLE 104 State not recoverable
				else
					continue
				fi
				# trunk-ignore(shellcheck/SC2053)
				if [[ $ITERATE__value == $ITERATE__lookup ]]; then
					ITERATE__matched=yes
					ITERATE__match="$ITERATE__value" # whole string match
					ITERATE__consumed_lookups_map[ITERATE__lookup_index]="$ITERATE__index"
				else
					continue
				fi
				;;

			# invalid lookup
			*) __unrecognised_flag "$ITERATE__lookup_option" || return $? ;;
			esac
			if [[ $ITERATE__matched == 'yes' ]]; then
				# for eviction, keep this for the overlap and breaking modifications, even though the results array doesn't matter for eviction
				if [[ $ITERATE__seek == 'multiple' ]]; then
					ITERATE__results+=("$ITERATE__match_index")
				elif [[ $ITERATE__seek == 'each' ]]; then
					ITERATE__results[ITERATE__lookup_index]="$ITERATE__match_index"
					if [[ ${#ITERATE__results[@]} -eq $ITERATE__lookups_size ]]; then
						ITERATE__break=2 # finished, break the outer loop
					fi
				else
					# first
					ITERATE__results+=("$ITERATE__match_index")
					ITERATE__break=2 # finished, break the outer loop
				fi
				# note the consumed indices,
				# this is utilised by our entrance overlap check (as our no overlap skips consumed indices), or by our exit when evicting (as the evict result evicts consumed indices)
				if [[ $ITERATE__overlap == 'no' || $ITERATE__operation == 'evict' ]]; then
					if [[ $ITERATE__array == 'yes' ]]; then
						ITERATE__consumed_indices_map["$ITERATE__match_index"]="$ITERATE__lookup_index"
					else
						ITERATE__match_size=${#ITERATE__match}
						for ((ITERATE__overlap_index = ITERATE__match_index; ITERATE__overlap_index < ITERATE__match_index + ITERATE__match_size; ITERATE__overlap_index++)); do
							ITERATE__consumed_indices_map["$ITERATE__overlap_index"]="$ITERATE__lookup_index"
						done
					fi
				fi
				# handle the break now, so that the overlap eviction above takes effect
				if [[ $ITERATE__break -ne 0 ]]; then
					break "$ITERATE__break"
				fi
			fi
		done
	done
	# reset case
	if [[ $ITERATE__case != 'sensitive' ]]; then
		shopt -u nocasematch
	fi
	# any/all require checks
	local -i ITERATE__found_size="${#ITERATE__consumed_lookups_map[@]}"
	# handle special operations
	case "$ITERATE__operation" in
	'evict')
		ITERATE__results=()
		if [[ $ITERATE__array == 'yes' ]]; then
			for ITERATE__index in "${ITERATE__indices[@]}"; do
				if [[ -n ${ITERATE__consumed_indices_map[ITERATE__index]-} ]]; then
					# this index was consumed, so skip it
					continue
				fi
				eval 'ITERATE__results+=("${'"$ITERATE__source_variable_name"'[ITERATE__index]}")' || return 104 # ENOTRECOVERABLE 104 State not recoverable
			done
		else
			local ITERATE__result=''
			for ITERATE__index in "${ITERATE__indices[@]}"; do
				if [[ -n ${ITERATE__consumed_indices_map[ITERATE__index]-} ]]; then
					# this index was consumed, so skip it
					continue
				fi
				eval 'ITERATE__result+="${'"$ITERATE__source_variable_name"':ITERATE__index:1}"' || return 104 # ENOTRECOVERABLE 104 State not recoverable
			done
			ITERATE__results+=("$ITERATE__result")
		fi
		;;
	'filter')
		local ITERATE__values=()
		if [[ $ITERATE__array == 'yes' ]]; then
			for ITERATE__index in "${ITERATE__results[@]}"; do
				eval 'ITERATE__values+=("${'"$ITERATE__source_variable_name"'[ITERATE__index]}")' || return 104 # ENOTRECOVERABLE 104 State not recoverable
			done
		else
			local ITERATE__result=''
			for ITERATE__index in "${ITERATE__results[@]}"; do
				eval 'ITERATE__result+="${'"$ITERATE__source_variable_name"':ITERATE__index:1}"' || return 104 # ENOTRECOVERABLE 104 State not recoverable
			done
			ITERATE__values+=("$ITERATE__result")
		fi
		case "$ITERATE__case" in
		'upper' | 'lower') __transform --source+target={ITERATE__values} --case="$ITERATE__case" || return $? ;;
		esac
		ITERATE__results=("${ITERATE__values[@]}")
		;;
	'has')
		if [[ $ITERATE__require == 'none' ]]; then
			__print_lines "ERROR: ${FUNCNAME[0]}: The operation $(__dump --value=has || :) cannot be used with the require mode $(__dump --value=none || :), use $(__dump --value=any || :) or $(__dump --value=all || :) or there is no point." >&2 || :
			return 22 # EINVAL 22 Invalid argument
		fi
		;;
	esac
	# validate first mode
	if [[ $ITERATE__seek == 'first' && $ITERATE__found_size -gt 1 ]]; then
		__print_lines "ERROR: ${FUNCNAME[0]}: Too many lookups were found, expected $(__dump --value="1" || :) but found $(__dump --value="$ITERATE__found_size" || :):" >&2 || :
		__dump {ITERATE__lookups} {ITERATE__consumed_lookups_map} {ITERATE__results} "{$ITERATE__source_variable_name}" >&2 || :
		return 34 # ERANGE 34 Result too large
	fi
	# any/all require checks
	if [[ $ITERATE__require == 'any' ]]; then
		if [[ $ITERATE__found_size -eq 0 ]]; then
			if [[ $ITERATE__quiet == 'no' ]]; then
				__print_lines "ERROR: ${FUNCNAME[0]}: No lookups were found, expected at least $(__dump --value='1' || :) but found $(__dump --value="$ITERATE__found_size" || :):" >&2 || :
				__dump {ITERATE__lookups} {ITERATE__consumed_lookups_map} {ITERATE__results} "{$ITERATE__source_variable_name}" >&2 || :
			fi
			return 33 # EDOM 33 Numerical argument out of domain
		fi
	elif [[ $ITERATE__require == 'all' ]]; then
		if [[ $ITERATE__found_size -ne ITERATE__lookups_size ]]; then
			if [[ $ITERATE__quiet == 'no' ]]; then
				__print_lines "ERROR: ${FUNCNAME[0]}: Not all lookups were found, expected $(__dump --value="$ITERATE__lookups_size" || :) but found $(__dump --value="$ITERATE__found_size" || :):" >&2 || :
				__dump {ITERATE__lookups} {ITERATE__consumed_lookups_map} {ITERATE__results} "{$ITERATE__source_variable_name}" >&2 || :
			fi
			return 33 # EDOM 33 Numerical argument out of domain
		fi
	fi
	# send the appropriate result based on the operation
	if [[ $ITERATE__operation == 'has' ]]; then
		# failure checks already happened above for has, so we can just return 0
		return 0
	fi
	# send the results
	__to --source={ITERATE__results} --mode="$ITERATE__mode" --targets={ITERATE__targets} || return $?
	__restore_tracing || return $?
}
function __filter {
	__iterate --filter "$@" || return $?
}
function __index {
	__iterate --index "$@" || return $?
}
function __has {
	__iterate --has "$@" || return $?
}
function __evict {
	__iterate --evict "$@" || return $?
}

function __replace {
	local REPLACE__empty="EMPTY${RANDOM}EMPTY"
	local REPLACE__lookups=() REPLACE__require='all' REPLACE__quiet='no' REPLACE__default_replacement='' REPLACE__default_fallback="$REPLACE__empty"
	# <single-source helper arguments>
	local REPLACE__item REPLACE__source_variable_name='' REPLACE__targets=() REPLACE__mode=''
	while [[ $# -ne 0 ]]; do
		REPLACE__item="$1"
		shift
		case "$REPLACE__item" in
		'--source={'*'}')
			__affirm_value_is_undefined "$REPLACE__source_variable_name" 'source variable reference' || return $?
			__dereference --source="${REPLACE__item#*=}" --name={REPLACE__source_variable_name} || return $?
			;;
		'--source+target={'*'}')
			REPLACE__item="${REPLACE__item#*=}"
			REPLACE__targets+=("$REPLACE__item")
			__affirm_value_is_undefined "$REPLACE__source_variable_name" 'source variable reference' || return $?
			__dereference --source="$REPLACE__item" --name={REPLACE__source_variable_name} || return $?
			;;
		'--targets='*) __dereference --source="${REPLACE__item#*=}" --append --value={REPLACE__targets} || return $? ;;
		'--target='*) REPLACE__targets+=("${REPLACE__item#*=}") ;;
		'--mode=prepend' | '--mode=append' | '--mode=overwrite' | '--mode=')
			__affirm_value_is_undefined "$REPLACE__mode" 'write mode' || return $?
			REPLACE__mode="${REPLACE__item#*=}"
			;;
		'--append' | '--prepend' | '--overwrite')
			__affirm_value_is_undefined "$REPLACE__mode" 'write mode' || return $?
			REPLACE__mode="${REPLACE__item:2}"
			;;
		'--')
			# they are inputs
			__affirm_value_is_undefined "$REPLACE__source_variable_name" 'source variable reference' || return $?
			if [[ $# -eq 1 ]]; then
				# a string input
				# trunk-ignore(shellcheck/SC2034)
				local REPLACE__input="$1"
				REPLACE__source_variable_name='REPLACE__input'
			else
				# an array input
				# trunk-ignore(shellcheck/SC2034)
				local REPLACE__inputs=("$@")
				REPLACE__source_variable_name='REPLACE__inputs'
			fi
			shift $#
			break
			;;
		# </single-source helper arguments>
		'--default-replacement='* | '--default-replace='*)
			__affirm_value_is_undefined "$REPLACE__default_replacement" 'default replace' || return $?
			REPLACE__default_replacement="${REPLACE__item#*=}"
			;;
		'--replacement='* | '--replace='* | '--with='*) REPLACE__lookups+=("$REPLACE__item") ;;
		# require mode
		'--require=none' | '--optional' | '--fallback') REPLACE__require='none' ;;
		'--require=any' | '--any') REPLACE__require='any' ;;
		'--require=all' | '--all') REPLACE__require='all' ;;
		'--fallback='*) REPLACE__default_fallback="${REPLACE__item#*=}" REPLACE__require='none' ;;
		# case mode
		# @todo support case mode, same as `__iterate`
		# quiet mode
		'--no-verbose'* | '--verbose'*) __flag --source={REPLACE__item} --target={REPLACE__quiet} --non-affirmative --coerce ;;
		'--no-quiet'* | '--quiet'*) __flag --source={REPLACE__item} --target={REPLACE__quiet} --affirmative --coerce ;;
		# everything else assume is a lookup to save us from duplicating case statements:
		'--'*)
			if [[ -z ${REPLACE__item#*=} ]]; then
				__print_lines "ERROR: ${FUNCNAME[0]}: The $(__dump --value="$REPLACE__item" || :) option must not have an empty value." >&2 || :
				__dump {REPLACE__lookups} "{$REPLACE__source_variable_name}" >&2 || :
				return 22 # EINVAL 22 Invalid argument
			fi
			REPLACE__lookups+=("$REPLACE__item")
			;;
		*) __unrecognised_argument "$REPLACE__item" || return $? ;;
		esac
	done
	__affirm_variable_is_defined "$REPLACE__source_variable_name" 'source variable reference' || return $?
	__affirm_length_defined "${#REPLACE__lookups[@]}" 'lookup' || return $?
	# handle array
	if __is_array "$REPLACE__source_variable_name"; then
		# if we are an array, perform the replace on each element
		local -i REPLACE__index
		local REPLACE__indices=() REPLACE__array=() REPLACE__recursion_reference="REPLACE_${RANDOM}__item"
		__indices --source="{$REPLACE__source_variable_name}" --target={REPLACE__indices} || return $?
		for REPLACE__index in "${REPLACE__indices[@]}"; do
			eval "$REPLACE__recursion_reference"'="${'"$REPLACE__source_variable_name"'['"$REPLACE__index"']}"'
			__replace --source+target="{$REPLACE__recursion_reference}" --require="$REPLACE__require" --quiet="$REPLACE__quiet" "${REPLACE__lookups[@]}" || return $?
			# trunk-ignore(shellcheck/SC2034)
			REPLACE__array["$REPLACE__index"]="${!REPLACE__recursion_reference}"
		done
		__to --source={REPLACE__array} --mode="$REPLACE__mode" --targets={REPLACE__targets} || return $?
		return 0
	fi
	# handle string
	local -i REPLACE__expected_size=0
	local REPLACE__found_lookups=() REPLACE__missing_lookups=() REPLACE__value_wip REPLACE__replacement
	eval 'REPLACE__value_wip="${'"$REPLACE__source_variable_name"'}"' || return 104 # ENOTRECOVERABLE 104 State not recoverable
	set -- "${REPLACE__lookups[@]}"
	while [[ $# -ne 0 ]]; do
		REPLACE__lookup="$1"
		shift
		if [[ -n ${1-} ]] && [[ $1 == --replacement=* || $1 == --replace=* || $1 == --with=* ]]; then
			REPLACE__replacement="${1#*=}"
			shift
		else
			REPLACE__replacement="$REPLACE__default_replacement"
		fi
		# handle the lookup
		REPLACE__expected_size=$((REPLACE__expected_size + 1))
		REPLACE__lookup_query="${REPLACE__lookup#*=}"
		REPLACE__value_before="$REPLACE__value_wip"
		case "$REPLACE__lookup" in
		# --replace-this=*
		'--value='* | '--needle='*)
			REPLACE__value_wip="${REPLACE__value_wip/"$REPLACE__lookup_query"/$REPLACE__replacement}" # don't wrap replacement in `"` as that outputs the `"` on bash versions <= 4.2
			;;
		# --replace-all-occurrences-of-this=*
		'--value-all='* | '--needle-all='*)
			while [[ $REPLACE__value_wip == *"$REPLACE__lookup_query"* ]]; do
				REPLACE__value_wip="${REPLACE__value_wip//"$REPLACE__lookup_query"/$REPLACE__replacement}" # don't wrap replacement in `"` as that outputs the `"` on bash versions <= 4.2
			done
			;;

		# --replace-this-prefix=*
		'--prefix='* | '--leading='*)
			if [[ $REPLACE__value_wip == "$REPLACE__lookup_query"* ]]; then
				REPLACE__value_wip="$REPLACE__replacement${REPLACE__value_wip#"$REPLACE__lookup_query"}"
			fi
			;;
		# --replace-all-occurrences-of-this-prefix=*
		'--prefix-all='* | '--leading-all='*)
			while [[ $REPLACE__value_wip == "$REPLACE__lookup_query"* ]]; do
				REPLACE__value_wip="$REPLACE__replacement${REPLACE__value_wip#"$REPLACE__lookup_query"}"
			done
			;;

		# --replace-this-suffix=*
		'--suffix='* | '--trailing='*)
			if [[ $REPLACE__value_wip == *"$REPLACE__lookup_query" ]]; then
				REPLACE__value_wip="${REPLACE__value_wip%"$REPLACE__lookup_query"}$REPLACE__replacement"
			fi
			;;
		# --replace-all-occurrences-of-this-suffix=*
		'--suffix-all='* | '--trailing-all='*)
			while [[ $REPLACE__value_wip == *"$REPLACE__lookup_query" ]]; do
				REPLACE__value_wip="${REPLACE__value_wip%"$REPLACE__lookup_query"}$REPLACE__replacement"
			done
			;;

		# --replace-this-pattern=*
		'--pattern='*)
			REPLACE__value_wip="${REPLACE__value_wip/$REPLACE__lookup_query/$REPLACE__replacement}"
			;;
		# --replace-all-occurrences-of-this-pattern=*
		'--pattern-all='*)
			REPLACE__value_wip="${REPLACE__value_wip//$REPLACE__lookup_query/$REPLACE__replacement}"
			;;

		# Bash/POSIX Character Classes: <https://www.gnu.org/software/gawk/manual/html_node/Bracket-Expressions.html>
		'--leading-whitespace')
			REPLACE__value_wip="${REPLACE__value_wip#"${REPLACE__value_wip%%[![:space:]]*}"}"
			;;
		'--trailing-whitespace')
			REPLACE__value_wip="${REPLACE__value_wip%"${REPLACE__value_wip##*[![:space:]]}"}"
			;;

		# --replace-everything-before-the-start-of-this=*
		# --keep-everything-after-the-start-of-this=*
		'--replace-before-first='*)
			local -i REPLACE__index
			REPLACE__index="$(__index --source={REPLACE__value_wip} --first --quiet -- "$REPLACE__lookup_query")" || continue
			REPLACE__value_wip="$REPLACE__replacement${REPLACE__value_wip:REPLACE__index}"
			;;
		# --replace-everything-before-the-start-of-the-last-occurrence-of-this=*
		# --keep-everything-after-the-start-of-the-last-occurrence-of-this=*
		'--replace-before-last='*)
			local -i REPLACE__index
			REPLACE__index="$(__index --source={REPLACE__value_wip} --reverse --first --quiet -- "$REPLACE__lookup_query")" || continue
			REPLACE__value_wip="$REPLACE__replacement${REPLACE__value_wip:REPLACE__index}"
			;;

		# --replace-everything-before-the-end-of-this=*
		# --keep-everything-after-the-end-of-this=*
		'--keep-after-first='*)
			if [[ $REPLACE__value_wip == *"$REPLACE__lookup_query"* ]]; then
				REPLACE__value_wip="$REPLACE__replacement${REPLACE__value_wip#*"$REPLACE__lookup_query"}"
			fi
			;;
		# --replace-everything-before-the-end-of-the-last-occurrence-of-this=*
		# --keep-everything-after-the-end-of-the-last-occurrence-of-this=*
		'--keep-after-last='*)
			if [[ $REPLACE__value_wip == *"$REPLACE__lookup_query"* ]]; then
				REPLACE__value_wip="$REPLACE__replacement${REPLACE__value_wip##*"$REPLACE__lookup_query"}"
			fi
			;;

		# --replace-everything-after-the-start-of-this=*
		# --keep-everything-before-the-start-of-this=*
		'--keep-before-first='*)
			if [[ $REPLACE__value_wip == *"$REPLACE__lookup_query"* ]]; then
				REPLACE__value_wip="${REPLACE__value_wip%%"$REPLACE__lookup_query"*}$REPLACE__replacement"
			fi
			;;
		# --replace-everything-after-the-start-of-the-last-occurrence-of-this=*
		# --keep-everything-before-the-start-of-the-last-occurrence-of-this=*
		'--keep-before-last='*)
			if [[ $REPLACE__value_wip == *"$REPLACE__lookup_query"* ]]; then
				REPLACE__value_wip="${REPLACE__value_wip%"$REPLACE__lookup_query"*}$REPLACE__replacement"
			fi
			;;

		# --replace-everything-after-the-end-of-this=*
		# --keep-everything-before-the-end-of-this=*
		'--replace-after-first='*)
			local -i REPLACE__index REPLACE__lookup_size
			REPLACE__index="$(__index --source={REPLACE__value_wip} --first --quiet -- "$REPLACE__lookup_query")" || continue
			REPLACE__lookup_size=${#REPLACE__lookup_query}
			REPLACE__value_wip="${REPLACE__value_wip:0:REPLACE__index+REPLACE__lookup_size}$REPLACE__replacement"
			;;
		# --replace-everything-after-the-end-of-the-last-occurrence-of-this=*
		# --keep-everything-before-the-end-of-the-last-occurrence-of-this=*
		'--replace-after-last='*)
			local -i REPLACE__index REPLACE__lookup_size
			REPLACE__index="$(__index --source={REPLACE__value_wip} --reverse --first --quiet -- "$REPLACE__lookup_query")" || continue
			REPLACE__lookup_size=${#REPLACE__lookup_query}
			REPLACE__value_wip="${REPLACE__value_wip:0:REPLACE__index+REPLACE__lookup_size}$REPLACE__replacement"
			;;

		*)
			__unrecognised_flag "$REPLACE__lookup" || return $?
			;;
		esac
		if [[ $REPLACE__value_wip != "$REPLACE__value_before" ]]; then
			REPLACE__found_lookups+=("$REPLACE__lookup")
		else
			REPLACE__missing_lookups+=("$REPLACE__lookup")
		fi
	done
	# any/all require checks
	local -i REPLACE__found_size="${#REPLACE__found_lookups[@]}" # REPLACE__missing_size="${#REPLACE__missing_lookups[@]}"
	if [[ $REPLACE__require == 'none' ]]; then
		if [[ $REPLACE__found_size -eq 0 && $REPLACE__default_fallback != "$REPLACE__empty" ]]; then
			REPLACE__value_wip="$REPLACE__default_fallback"
		fi
	elif [[ $REPLACE__require == 'any' ]]; then
		if [[ $REPLACE__found_size -eq 0 ]]; then
			if [[ $REPLACE__quiet == 'no' ]]; then
				__print_lines "ERROR: ${FUNCNAME[0]}: No lookups were found, expected at least $(__dump --value='1' || :) but found $(__dump --value="$REPLACE__missing_size" || :):" >&2 || :
				__dump {REPLACE__lookups} {REPLACE__found_lookups} {REPLACE__missing_lookups} "{$REPLACE__source_variable_name}" >&2 || :
			fi
			return 33 # EDOM 33 Numerical argument out of domain
		fi
	elif [[ $REPLACE__require == 'all' ]]; then
		if [[ $REPLACE__found_size -ne $REPLACE__expected_size ]]; then
			if [[ $REPLACE__quiet == 'no' ]]; then
				__print_lines "ERROR: ${FUNCNAME[0]}: Not all lookups were found, expected $(__dump --value="$REPLACE__expected_size" || :) but found $(__dump --value="$REPLACE__found_size" || :):" >&2 || :
				__dump {REPLACE__lookups} {REPLACE__found_lookups} {REPLACE__missing_lookups} "{$REPLACE__source_variable_name}" >&2 || :
			fi
			return 33 # EDOM 33 Numerical argument out of domain
		fi
	fi
	# send the results
	__to --source={REPLACE__value_wip} --mode="$REPLACE__mode" --targets={REPLACE__targets} || return $?
}

function __unique {
	local UNIQUE__case='sensitive'
	# <multi-source helper arguments>
	local UNIQUE__item UNIQUE__sources_variable_names=() UNIQUE__targets=() UNIQUE__mode=''
	while [[ $# -ne 0 ]]; do
		UNIQUE__item="$1"
		shift
		case "$UNIQUE__item" in
		'--source={'*'}')
			__dereference --source="${UNIQUE__item#*=}" --append --name={UNIQUE__sources_variable_names} || return $?
			;;
		'--source+target={'*'}')
			UNIQUE__item="${UNIQUE__item#*=}"
			UNIQUE__targets+=("$UNIQUE__item") # keep squigglies
			__dereference --source="$UNIQUE__item" --append --name={UNIQUE__sources_variable_names} || return $?
			;;
		'--targets='*) __dereference --source="${UNIQUE__item#*=}" --append --value={UNIQUE__targets} || return $? ;;
		'--target='*) UNIQUE__targets+=("${UNIQUE__item#*=}") ;;
		'--mode=prepend' | '--mode=append' | '--mode=overwrite' | '--mode=')
			__affirm_value_is_undefined "$UNIQUE__mode" 'write mode' || return $?
			UNIQUE__mode="${UNIQUE__item#*=}"
			;;
		'--append' | '--prepend' | '--overwrite')
			__affirm_value_is_undefined "$UNIQUE__mode" 'write mode' || return $?
			UNIQUE__mode="${UNIQUE__item:2}"
			;;
		'--')
			# an array input
			# trunk-ignore(shellcheck/SC2034)
			local UNIQUE__inputs=("$@")
			UNIQUE__sources_variable_names+=('UNIQUE__inputs')
			shift $#
			break
			;;
		# </multi-source helper arguments>
		'--case=lower' | '--lowercase') UNIQUE__case='lower' ;;
		'--case=upper' | '--uppercase') UNIQUE__case='upper' ;;
		'--case=ignore' | '--ignore-case') UNIQUE__case='ignore' ;;
		'--case=sensitive') UNIQUE__case='sensitive' ;;
		'--case=') : ;;
		'--'*) __unrecognised_flag "$UNIQUE__item" || return $? ;;
		*) __unrecognised_argument "$UNIQUE__item" || return $? ;;
		esac
	done
	__affirm_length_defined "${#UNIQUE__sources_variable_names[@]}" 'source variable reference' || return $?
	__affirm_value_is_valid_write_mode "$UNIQUE__mode" || return $?
	# case
	local UNIQUE__value UNIQUE__lookup
	case "$UNIQUE__case" in
	'sensitive')
		function UNIQUE__prepare {
			UNIQUE__lookup="$UNIQUE__value"
		}
		;;
	'ignore')
		function UNIQUE__prepare {
			UNIQUE__lookup="$(__get_lowercase_string "$UNIQUE__value")"
		}
		;;
	'lower')
		function UNIQUE__prepare {
			UNIQUE__value="$(__get_lowercase_string "$UNIQUE__value")"
			UNIQUE__lookup="$UNIQUE__value"
		}
		;;
	'upper')
		function UNIQUE__prepare {
			UNIQUE__value="$(__get_uppercase_string "$UNIQUE__value")"
			UNIQUE__lookup="$UNIQUE__value"
		}
		;;
	esac
	# process
	local -i UNIQUE__index
	local UNIQUE__source_variable_name UNIQUE__indices=() UNIQUE__empty="EMPTY${RANDOM}EMPTY" UNIQUE__results=()
	if [[ $BASH_HAS_NATIVE_ASSOCIATIVE_ARRAY == 'yes' ]]; then
		declare -A UNIQUE__encountered_associative
		for UNIQUE__source_variable_name in "${UNIQUE__sources_variable_names[@]}"; do
			__affirm_variable_is_array "$UNIQUE__source_variable_name" 'source variable reference' || return $?
			eval 'UNIQUE__indices=("${!'"$UNIQUE__source_variable_name"'[@]}")' || return 104 # ENOTRECOVERABLE 104 State not recoverable
			# source is always an array, so no need for `__indices --source="{$UNIQUE__source_variable_name}" --target={UNIQUE__indices} || return $?`
			for UNIQUE__index in "${UNIQUE__indices[@]}"; do
				eval 'UNIQUE__value="${'"$UNIQUE__source_variable_name"'[UNIQUE__index]:-"$UNIQUE__empty"}"' || return 104 # ENOTRECOVERABLE 104 State not recoverable
				UNIQUE__prepare || return $?
				# associative arrays cannot have zero-length keys, so we do the UNIQUE__empty fallback
				if [[ -n ${UNIQUE__encountered_associative["$UNIQUE__lookup"]-} ]]; then
					continue
				fi
				UNIQUE__encountered_associative["$UNIQUE__lookup"]="$UNIQUE__index"
				# when doing the results, handle the `UNIQUE__empty` placeholder
				if [[ $UNIQUE__value == "$UNIQUE__empty" ]]; then
					UNIQUE__results+=('')
				else
					UNIQUE__results+=("$UNIQUE__value")
				fi
			done
		done
	else
		local UNIQUE__encountered_array=() UNIQUE__encountered_value
		for UNIQUE__source_variable_name in "${UNIQUE__sources_variable_names[@]}"; do
			__affirm_variable_is_array "$UNIQUE__source_variable_name" 'source variable reference' || return $?
			eval 'UNIQUE__indices=("${!'"$UNIQUE__source_variable_name"'[@]}")' || return 104 # ENOTRECOVERABLE 104 State not recoverable
			# source is always an array, so no need for `__indices --source="{$UNIQUE__source_variable_name}" --target={UNIQUE__indices} || return $?`
			for UNIQUE__index in "${UNIQUE__indices[@]}"; do
				eval 'UNIQUE__value="${'"$UNIQUE__source_variable_name"'[UNIQUE__index]}"' || return 104 # ENOTRECOVERABLE 104 State not recoverable
				UNIQUE__prepare || return $?
				for UNIQUE__encountered_value in "${UNIQUE__encountered_array[@]}"; do
					if [[ $UNIQUE__encountered_value == "$UNIQUE__lookup" ]]; then
						continue 2 # skip to the next index
					fi
				done
				UNIQUE__encountered_array+=("$UNIQUE__lookup")
				UNIQUE__results+=("$UNIQUE__value")
			done
		done
	fi
	__to --source={UNIQUE__results} --mode="$UNIQUE__mode" --targets={UNIQUE__targets} || return $?
}

# set the targets to the slice between the start and length indices of the source reference
# negative starts and lengths will be counted from the source reference's end
# out of bound indices will throw
# if you want to suppress out of bounds, do: `__slice --quiet ... || __ignore_exit_status 33`
# a prior implementation of this had a sliding window implementation, however the problem is, while a sliding window implementation is intuitive, it is not standard, and as such, there are differing expectations as to what out of bound behaviour should be, as such that is why the current implementation throws to enforce the caller to be explicit
# at a later point, one could implement an option that adjusts the out of bound behaviour
# note that the following proposals are error-prone, as again, they do not specify which out of bound behaviour should occur:
# ```
# __slice --source+target={parts} -- \
# 	0 "$i" \
# 	"$((i + 1))" --ignore-out-of-bounds
# ```
# as such, it would need ot be something like:
# ```
# __slice --source+target={parts} -- \
# 	0 "$i" \
# 	"$((i + 1))" --out-of-bound=sliding-window
# ```
# which would still enforce an out of bound error if the first tuple is out of bound,
# a default out of bound override could occur like so:
# ```
# __slice --source+target={parts} --out-of-bound=sliding-window -- \
# 	0 "$i" \
# 	"$((i + 1))"
# ```
# for now, if you are just wanting to evict certain indices, use the less efficient but clearer `__evict` function:
# ```
# __evict --source+target={parts} --each --all --index="$i"
# ```
function __slice {
	local SLICE__indices=() SLICE__quiet='no'
	# <single-source helper arguments>
	local SLICE__item SLICE__source_variable_name='' SLICE__targets=() SLICE__mode=''
	while [[ $# -ne 0 ]]; do
		SLICE__item="$1"
		shift
		case "$SLICE__item" in
		'--source={'*'}')
			__affirm_value_is_undefined "$SLICE__source_variable_name" 'source variable reference' || return $?
			__dereference --source="${SLICE__item#*=}" --name={SLICE__source_variable_name} || return $?
			;;
		'--source+target={'*'}')
			SLICE__item="${SLICE__item#*=}"
			SLICE__targets+=("$SLICE__item")
			__affirm_value_is_undefined "$SLICE__source_variable_name" 'source variable reference' || return $?
			__dereference --source="$SLICE__item" --name={SLICE__source_variable_name} || return $?
			;;
		'--targets='*) __dereference --source="${SLICE__item#*=}" --append --value={SLICE__targets} || return $? ;;
		'--target='*) SLICE__targets+=("${SLICE__item#*=}") ;;
		'--mode=prepend' | '--mode=append' | '--mode=overwrite' | '--mode=')
			__affirm_value_is_undefined "$SLICE__mode" 'write mode' || return $?
			SLICE__mode="${SLICE__item#*=}"
			;;
		'--append' | '--prepend' | '--overwrite')
			__affirm_value_is_undefined "$SLICE__mode" 'write mode' || return $?
			SLICE__mode="${SLICE__item:2}"
			;;
		'--')
			if [[ -z $SLICE__source_variable_name ]]; then
				# they are inputs
				if [[ $# -eq 1 ]]; then
					# a string input
					# trunk-ignore(shellcheck/SC2034)
					local SLICE__input="$1"
					SLICE__source_variable_name='SLICE__input'
				else
					# an array input
					# trunk-ignore(shellcheck/SC2034)
					local SLICE__inputs=("$@")
					SLICE__source_variable_name='SLICE__inputs'
				fi
			else
				# they are indices
				for SLICE__item in "$@"; do
					__affirm_value_is_integer "$SLICE__item" 'index' || return $?
				done
				SLICE__indices+=("$@")
			fi
			shift $#
			break
			;;
		# </single-source helper arguments>
		# quiet mode
		'--no-verbose'* | '--verbose'*) __flag --source={SLICE__item} --target={SLICE__quiet} --non-affirmative --coerce ;;
		'--no-quiet'* | '--quiet'*) __flag --source={SLICE__item} --target={SLICE__quiet} --affirmative --coerce ;;
		# index/length
		[0-9]* | '-'[0-9]*)
			__affirm_value_is_integer "$SLICE__item" 'index' || return $?
			SLICE__indices+=("$SLICE__item") ;;
		'--'*) __unrecognised_flag "$SLICE__item" || return $? ;;
		*) __unrecognised_argument "$SLICE__item" || return $? ;;
		esac
	done
	# affirm
	__affirm_variable_is_defined "$SLICE__source_variable_name" 'source variable reference' || return $?
	__affirm_value_is_valid_write_mode "$SLICE__mode" || return $?
	__affirm_length_defined "${#SLICE__indices[@]}" '<index> [<length>] tuple' || return $?
	# if indices is odd, then make it to the end
	if __is_odd "${#SLICE__indices[@]}"; then
		SLICE__indices+=('-0') # -0 means to the end
	fi
	# indices
	local -i SLICE__size SLICE__remaining
	# trunk-ignore(shellcheck/SC2034)
	local SLICE__results=() SLICE__eval_left_segment SLICE__eval_length_segment SLICE__left SLICE__length # left and length could be -0 which is string
	if __is_array "$SLICE__source_variable_name"; then
		eval "SLICE__size=\"\${#${SLICE__source_variable_name}[@]}\"" || return 104 # ENOTRECOVERABLE 104 State not recoverable
		SLICE__eval_left_segment="SLICE__results+=(\"\${${SLICE__source_variable_name}[@]:SLICE__left}\")"
		SLICE__eval_length_segment="SLICE__results+=(\"\${${SLICE__source_variable_name}[@]:SLICE__left:SLICE__length}\")"
	else
		eval "SLICE__size=\"\${#${SLICE__source_variable_name}}\"" || return 104 # ENOTRECOVERABLE 104 State not recoverable
		SLICE__eval_left_segment="SLICE__results+=(\"\${${SLICE__source_variable_name}:SLICE__left}\")"
		SLICE__eval_length_segment="SLICE__results+=(\"\${${SLICE__source_variable_name}:SLICE__left:SLICE__length}\")"
	fi
	SLICE__negative_size=$((SLICE__size * -1))
	# we guaranteed earlier we have even indices, and instead of for a loop, a shifting while loop is easiest
	set -- "${SLICE__indices[@]}"
	while [[ $# -ne 0 ]]; do
		SLICE__left="$1"
		SLICE__length="$2"
		shift 2
		# __dump SLICE__left SLICE__length SLICE__size SLICE__negative_size >&2 || :
		if [[ $SLICE__left == '-0' || $SLICE__length == '0' ]]; then
			continue # there is nothing to do
		elif [[ $SLICE__left -lt $SLICE__negative_size || $SLICE__left -ge $SLICE__size ]]; then
			if [[ $SLICE__quiet == 'no' ]]; then
				__print_lines "ERROR: ${FUNCNAME[0]}: The index $(__dump --value="$SLICE__left" || :) was beyond the range of:" >&2 || :
				__dump --indices "$SLICE__source_variable_name" >&2 || :
			fi
			return 33 # EDOM 33 Numerical argument out of domain
		fi
		if [[ $SLICE__length == '-0' || $SLICE__length -eq $SLICE__size ]]; then
			eval "$SLICE__eval_left_segment" || return 104 # ENOTRECOVERABLE 104 State not recoverable
			continue
		fi
		SLICE__remaining="$((SLICE__size - SLICE__left))"
		if [[ $SLICE__length -gt $SLICE__remaining || $SLICE__length -lt $SLICE__remaining*-1 ]]; then
			if [[ $SLICE__quiet == 'no' ]]; then
				__print_lines "ERROR: ${FUNCNAME[0]}: The index $(__dump --value="$SLICE__left" || :) with length $(__dump --value="$SLICE__length" || :) was beyond the range of:" >&2 || :
				__dump --indices "$SLICE__source_variable_name" >&2 || :
			fi
			return 33 # EDOM 33 Numerical argument out of domain
		elif [[ $SLICE__length -lt 0 && $BASH_CAN_USE_A_NEGATIVE_LENGTH == 'no' ]]; then
			SLICE__length="$((SLICE__size + SLICE__length - SLICE__left))"
		fi
		eval "$SLICE__eval_length_segment" || return 104 # ENOTRECOVERABLE 104 State not recoverable
	done
	__to --source={SLICE__results} --mode="$SLICE__mode" --targets={SLICE__targets} || return $?
}

# split, unlike mapfile and readarray, supports multi-character delimiters, and multiple delimiters
# this is wrong:
# __split --target={arr} --no-zero-length --stdin < <(<output-command>)
# __split --target={arr} --no-zero-length --stdin <<< "$(<output-command>)"
# __split --target={arr} --no-zero-length --stdin < <(<output-command> | tr $'\t ,|' '\n')
# and this is right:
# fodder_to_respect_exit_status="$(<output-command>)"
# __split --target={arr} --no-zero-length --invoke -- <output-command> # this preserves trail
# __split --target={arr} --no-zero-length -- "$fodder_to_respect_exit_status"
# __split --target={arr} --no-zero-length -- "$fodder_to_respect_exit_status"
# __split --target={arr} --delimiters=$'\n\t ,|' --no-zero-length -- "$fodder_to_respect_exit_status"
# use --delimiter='<a multi character delimiter>' to specify a single multi-character delimiter
function __split {
	local SPLIT__character SPLIT__results=() SPLIT__window SPLIT__segment SPLIT__invoke='no' SPLIT__trailing_newlines='' SPLIT__zero_length='yes' SPLIT__delimiters=() SPLIT__delimiter
	local -i SPLIT__last_slice_left_index SPLIT__string_length SPLIT__string_last SPLIT__delimiter_size SPLIT__window_size SPLIT__window_offset SPLIT__character_left_index
	# <multi-source helper arguments>
	local SPLIT__item SPLIT__sources_variable_names=() SPLIT__targets=() SPLIT__mode=''
	while [[ $# -ne 0 ]]; do
		SPLIT__item="$1"
		shift
		case "$SPLIT__item" in
		'--source={'*'}')
			__dereference --source="${SPLIT__item#*=}" --name={SPLIT__sources_variable_names} || return $?
			;;
		'--source+target={'*'}')
			SPLIT__item="${SPLIT__item#*=}"
			SPLIT__targets+=("$SPLIT__item")
			__dereference --source="$SPLIT__item" --append --name={SPLIT__sources_variable_names} || return $?
			;;
		'--targets='*) __dereference --source="${SPLIT__item#*=}" --append --value={SPLIT__targets} || return $? ;;
		'--target='*) SPLIT__targets+=("${SPLIT__item#*=}") ;;
		'--mode=prepend' | '--mode=append' | '--mode=overwrite' | '--mode=')
			__affirm_value_is_undefined "$SPLIT__mode" 'write mode' || return $?
			SPLIT__mode="${SPLIT__item#*=}"
			;;
		'--append' | '--prepend' | '--overwrite')
			__affirm_value_is_undefined "$SPLIT__mode" 'write mode' || return $?
			SPLIT__mode="${SPLIT__item:2}"
			;;
		# </multi-source helper arguments>
		'--stdin' | '--source=STDIN' | '--source=stdin' | '--source=/dev/stdin' | '--source=0')
			local SPLIT__stdin='' SPLIT__reply=''
			while LC_ALL=C IFS= read -rd '' SPLIT__reply || [[ -n $SPLIT__reply ]]; do
				if [[ -n $SPLIT__stdin ]]; then
					SPLIT__stdin+=$'\n'
				fi
				SPLIT__stdin+="$SPLIT__reply"
			done
			SPLIT__sources_variable_names+=('SPLIT__stdin')
			;;
		'--')
			if [[ $SPLIT__invoke == 'yes' ]]; then
				local SPLIT__fodder_with_redirect_exit_status SPLIT__exit_status
				__do --trailing-newlines="$SPLIT__trailing_newlines" --redirect-status={SPLIT__exit_status} --redirect-stdout={SPLIT__fodder_with_redirect_exit_status} -- "$@"
				if [[ $SPLIT__exit_status -ne 0 ]]; then
					return "$SPLIT__exit_status"
				fi
				local SPLIT__input="$SPLIT__fodder_with_redirect_exit_status"
				SPLIT__sources_variable_names+=('SPLIT__input')
			elif [[ $SPLIT__invoke == 'try' ]]; then
				local SPLIT__fodder_with_discard_exit_status
				__do --trailing-newlines="$SPLIT__trailing_newlines" --discard-status --redirect-stdout={SPLIT__fodder_with_discard_exit_status} -- "$@"
				# trunk-ignore(shellcheck/SC2034)
				local SPLIT__input="$SPLIT__fodder_with_discard_exit_status"
				SPLIT__sources_variable_names+=('SPLIT__input')
			else
				# an array input
				# trunk-ignore(shellcheck/SC2034)
				local SPLIT__inputs=("$@")
				SPLIT__sources_variable_names+=('SPLIT__inputs')
				shift $#
				break
			fi
			shift $#
			break
			;;
		'--no-trailing-newlines'* | '--trailing-newlines'*) __flag --source={SPLIT__item} --target={SPLIT__trailing_newlines} --affirmative --coerce || return $? ;;
		'--no-zero-length'* | '--zero-length'* | '--keep-zero-length'*) __flag --source={SPLIT__item} --target={SPLIT__zero_length} --affirmative --coerce || return $? ;;
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
		'--'*) __unrecognised_flag "$SPLIT__item" || return $? ;;
		*) __unrecognised_argument "$SPLIT__item" || return $? ;;
		esac
	done
	__affirm_length_defined "${#SPLIT__sources_variable_names[@]}" 'source variable reference' || return $?
	__affirm_value_is_valid_write_mode "$SPLIT__mode" || return $?
	if [[ ${#SPLIT__delimiters[@]} -eq 0 ]]; then
		SPLIT__delimiters+=($'\n')
	fi
	# process
	local SPLIT__source_variable_name SPLIT__strings=()
	for SPLIT__source_variable_name in "${SPLIT__sources_variable_names[@]}"; do
		__affirm_variable_is_defined "$SPLIT__source_variable_name" 'source variable reference' || return $?
		if __is_array "$SPLIT__source_variable_name"; then
			eval 'SPLIT__strings+=("${'"$SPLIT__source_variable_name"'[@]}")' || return 104 # ENOTRECOVERABLE 104 State not recoverable
		else
			eval 'SPLIT__strings+=("${'"$SPLIT__source_variable_name"'}")' || return 104 # ENOTRECOVERABLE 104 State not recoverable
		fi
	done
	local SPLIT__string SPLIT__results=()
	for SPLIT__string in "${SPLIT__strings[@]}"; do
		# handle empty
		if [[ -z $SPLIT__string ]]; then
			# add iff desired
			if [[ $SPLIT__zero_length == 'yes' ]]; then
				SPLIT__results+=('')
			fi
			# done with empty
			continue
		fi
		# reset the window for each argument
		SPLIT__window=''
		SPLIT__last_slice_left_index=-1
		SPLIT__string_length=${#SPLIT__string}
		SPLIT__string_last=$((SPLIT__string_length - 1))
		# process the argument
		for ((SPLIT__character_left_index = 0; SPLIT__character_left_index < SPLIT__string_length; SPLIT__character_left_index++)); do
			# add the character to the window, no need for string __slice as it is a simple slice
			SPLIT__character="${SPLIT__string:SPLIT__character_left_index:1}"
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
				SPLIT__results+=("$SPLIT__string")
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
	done
	__to --source={SPLIT__results} --mode="$SPLIT__mode" --targets={SPLIT__targets} || return $?
}

# join by the delimiter
function __join {
	local JOIN__between='' JOIN__first='' JOIN__last='' JOIN__before='' JOIN__after='' JOIN__style='' JOIN__wrap_style='' JOIN__between_style=''
	# <multi-source helper arguments>
	local JOIN__item JOIN__sources_variable_names=() JOIN__targets=() JOIN__mode=''
	while [[ $# -ne 0 ]]; do
		JOIN__item="$1"
		shift
		case "$JOIN__item" in
		'--source={'*'}')
			__dereference --source="${JOIN__item#*=}" --append --name={JOIN__sources_variable_names} || return $?
			;;
		'--source+target={'*'}')
			JOIN__item="${JOIN__item#*=}"
			JOIN__targets+=("$JOIN__item")
			__dereference --source="$JOIN__item" --append --name={JOIN__sources_variable_names} || return $?
			;;
		'--targets='*) __dereference --source="${JOIN__item#*=}" --append --value={JOIN__targets} || return $? ;;
		'--target='*) JOIN__targets+=("${JOIN__item#*=}") ;;
		'--mode=prepend' | '--mode=append' | '--mode=overwrite' | '--mode=')
			__affirm_value_is_undefined "$JOIN__mode" 'write mode' || return $?
			JOIN__mode="${JOIN__item#*=}"
			;;
		'--append' | '--prepend' | '--overwrite')
			__affirm_value_is_undefined "$JOIN__mode" 'write mode' || return $?
			JOIN__mode="${JOIN__item:2}"
			;;
		'--')
			# an array input
			# trunk-ignore(shellcheck/SC2034)
			local JOIN__inputs=("$@")
			JOIN__sources_variable_names+=('JOIN__inputs')
			shift $#
			break
			;;
		# </multi-source helper arguments>
		'--first='* ) JOIN__first="${JOIN__item#*=}" ;;
		'--last='* ) JOIN__last="${JOIN__item#*=}" ;;
		'--between='* | '--join='* | '--delimiter='*) JOIN__between="${JOIN__item#*=}" ;;
		'--before='* | '--prefix='* | '--left='*) JOIN__before="${JOIN__item#*=}" ;;
		'--after='* | '--suffix='* | '--right='*) JOIN__after="${JOIN__item#*=}" ;;
		'--style='*) JOIN__style="${JOIN__item#*=}" ;;
		'--wrap-style='*) JOIN__wrap_style="${JOIN__item#*=}" ;;
		'--between-style='*) JOIN__between_style="${JOIN__item#*=}" ;;
		'--'*) __unrecognised_flag "$JOIN__item" || return $? ;;
		*) __unrecognised_argument "$JOIN__item" || return $? ;;
		esac
	done
	__affirm_length_defined "${#JOIN__sources_variable_names[@]}" 'source variable reference' || return $?
	__affirm_value_is_valid_write_mode "$JOIN__mode" || return $?
	# process
	local JOIN__source_variable_name JOIN__values=() JOIN__result="$JOIN__first"
	if [[ -n $JOIN__style ]]; then
		__load_styles --save -- "$JOIN__style" || return $?
		eval 'JOIN__before="$JOIN__before${STYLE__'"$JOIN__style"'-}"'
		eval 'JOIN__after="${STYLE__END__'"$JOIN__style"'-}$JOIN__after"'
	fi
	if [[ -n $JOIN__wrap_style ]]; then
		__load_styles --save -- "$JOIN__wrap_style" || return $?
		eval 'JOIN__before="${STYLE__'"$JOIN__wrap_style"'-}$JOIN__before"'
		eval 'JOIN__after="$JOIN__after${STYLE__END__'"$JOIN__wrap_style"'-}"'
	fi
	if [[ -n $JOIN__between_style ]]; then
		__load_styles --save -- "$JOIN__between_style" || return $?
		eval 'JOIN__between="${STYLE__'"$JOIN__between_style"'-}$JOIN__between${STYLE__END__'"$JOIN__between_style"'-}"'
	fi
	for JOIN__source_variable_name in "${JOIN__sources_variable_names[@]}"; do
		__affirm_variable_is_array "$JOIN__source_variable_name" 'source variable reference' || return $?
		eval 'JOIN__values+=("${'"$JOIN__source_variable_name"'[@]}")' || return 104 # ENOTRECOVERABLE 104 State not recoverable
	done
	set -- "${JOIN__values[@]}" || return $?
	while [[ $# -gt 1 ]]; do
		JOIN__result+="$JOIN__before$1$JOIN__after$JOIN__between"
		shift
	done
	if [[ $# -eq 1 ]]; then
		JOIN__result+="$JOIN__before$1$JOIN__after"
	fi
	JOIN__result+="$JOIN__last"
	__to --source={JOIN__result} --mode="$JOIN__mode" --targets={JOIN__targets} || return $?
}

# sort
function __sort {
	local SORT__args=()
	# <multi-source-value helper arguments>
	local SORT__item SORT__elements=() SORT__targets=() SORT__mode=''
	while [[ $# -ne 0 ]]; do
		SORT__item="$1"
		shift
		case "$SORT__item" in
		'--source={'*'}')
			__dereference --source="${SORT__item#*=}" --append --value={SORT__elements} || return $?
			;;
		'--source+target={'*'}')
			SORT__item="${SORT__item#*=}"
			SORT__targets+=("$SORT__item")
			__dereference --source="$SORT__item" --append --value={SORT__elements} || return $?
			;;
		'--targets='*) __dereference --source="${SORT__item#*=}" --append --value={SORT__targets} || return $? ;;
		'--target='*) SORT__targets+=("${SORT__item#*=}") ;;
		'--mode=prepend' | '--mode=append' | '--mode=overwrite' | '--mode=')
			__affirm_value_is_undefined "$SORT__mode" 'write mode' || return $?
			SORT__mode="${SORT__item#*=}"
			;;
		'--append' | '--prepend' | '--overwrite')
			__affirm_value_is_undefined "$SORT__mode" 'write mode' || return $?
			SORT__mode="${SORT__item:2}"
			;;
		'--')
			# an array input
			SORT__elements+=("$@")
			shift $#
			break
			;;
		# </multi-source-value helper arguments>
		'-'*) SORT__args+=("$SORT__item") ;;
		*) __unrecognised_argument "$SORT__item" || return $? ;;
		esac
	done
	__affirm_value_is_valid_write_mode "$SORT__mode" || return $?
	# process
	__split --targets={SORT__targets} --no-zero-length --invoke -- sort "${SORT__args[@]}" <<< "$(__print_lines "${SORT__elements[@]}")" || return $?
}

# minimum
function __minimum {
	local MINIMUM__args=()
	# <multi-source-value helper arguments>
	local MINIMUM__item MINIMUM__elements=() MINIMUM__targets=() MINIMUM__mode=''
	while [[ $# -ne 0 ]]; do
		MINIMUM__item="$1"
		shift
		case "$MINIMUM__item" in
		'--source={'*'}')
			__dereference --source="${MINIMUM__item#*=}" --append --value={MINIMUM__elements} || return $?
			;;
		'--source+target={'*'}')
			MINIMUM__item="${MINIMUM__item#*=}"
			MINIMUM__targets+=("$MINIMUM__item")
			__dereference --source="$MINIMUM__item" --append --value={MINIMUM__elements} || return $?
			;;
		'--targets='*) __dereference --source="${MINIMUM__item#*=}" --append --value={MINIMUM__targets} || return $? ;;
		'--target='*) MINIMUM__targets+=("${MINIMUM__item#*=}") ;;
		'--mode=prepend' | '--mode=append' | '--mode=overwrite' | '--mode=')
			__affirm_value_is_undefined "$MINIMUM__mode" 'write mode' || return $?
			MINIMUM__mode="${MINIMUM__item#*=}"
			;;
		'--append' | '--prepend' | '--overwrite')
			__affirm_value_is_undefined "$MINIMUM__mode" 'write mode' || return $?
			MINIMUM__mode="${MINIMUM__item:2}"
			;;
		'--')
			# an array input
			MINIMUM__elements+=("$@")
			shift $#
			break
			;;
		# </multi-source-value helper arguments>
		'-'*) MINIMUM__args+=("$MINIMUM__item") ;;
		*) __unrecognised_argument "$MINIMUM__item" || return $? ;;
		esac
	done
	__affirm_value_is_valid_write_mode "$MINIMUM__mode" || return $?
	__affirm_length_defined "${#MINIMUM__elements[@]}" 'elements' || return $?
	# process
	local MINIMUM__result=''
	for MINIMUM__item in "${MINIMUM__elements[@]}"; do
		__affirm_value_is_integer "$MINIMUM__item" || return $?
		if [[ -z $MINIMUM__result ]]; then
			MINIMUM__result="$MINIMUM__item"
		elif [[ $MINIMUM__item -lt $MINIMUM__result ]]; then
			MINIMUM__result="$MINIMUM__item"
		fi
	done
	__to --source={MINIMUM__result} --mode="$MINIMUM__mode" --targets={MINIMUM__targets} || return $?
}

# maximum
function __maximum {
	local MAXIMUM__args=()
	# <multi-source-value helper arguments>
	local MAXIMUM__item MAXIMUM__elements=() MAXIMUM__targets=() MAXIMUM__mode=''
	while [[ $# -ne 0 ]]; do
		MAXIMUM__item="$1"
		shift
		case "$MAXIMUM__item" in
		'--source={'*'}')
			__dereference --source="${MAXIMUM__item#*=}" --append --value={MAXIMUM__elements} || return $?
			;;
		'--source+target={'*'}')
			MAXIMUM__item="${MAXIMUM__item#*=}"
			MAXIMUM__targets+=("$MAXIMUM__item")
			__dereference --source="$MAXIMUM__item" --append --value={MAXIMUM__elements} || return $?
			;;
		'--targets='*) __dereference --source="${MAXIMUM__item#*=}" --append --value={MAXIMUM__targets} || return $? ;;
		'--target='*) MAXIMUM__targets+=("${MAXIMUM__item#*=}") ;;
		'--mode=prepend' | '--mode=append' | '--mode=overwrite' | '--mode=')
			__affirm_value_is_undefined "$MAXIMUM__mode" 'write mode' || return $?
			MAXIMUM__mode="${MAXIMUM__item#*=}"
			;;
		'--append' | '--prepend' | '--overwrite')
			__affirm_value_is_undefined "$MAXIMUM__mode" 'write mode' || return $?
			MAXIMUM__mode="${MAXIMUM__item:2}"
			;;
		'--')
			# an array input
			MAXIMUM__elements+=("$@")
			shift $#
			break
			;;
		# </multi-source-value helper arguments>
		'-'*) MAXIMUM__args+=("$MAXIMUM__item") ;;
		*) __unrecognised_argument "$MAXIMUM__item" || return $? ;;
		esac
	done
	__affirm_value_is_valid_write_mode "$MAXIMUM__mode" || return $?
	__affirm_length_defined "${#MAXIMUM__elements[@]}" 'elements' || return $?
	# process
	local MAXIMUM__result=''
	for MAXIMUM__item in "${MAXIMUM__elements[@]}"; do
		__affirm_value_is_integer "$MAXIMUM__item" || return $?
		if [[ -z $MAXIMUM__result ]]; then
			MAXIMUM__result="$MAXIMUM__item"
		elif [[ $MAXIMUM__item -gt $MAXIMUM__result ]]; then
			MAXIMUM__result="$MAXIMUM__item"
		fi
	done
	__to --source={MAXIMUM__result} --mode="$MAXIMUM__mode" --targets={MAXIMUM__targets} || return $?
}

# tool
function __tool {
	# local TOOL_delimiter=$'\n'
	# <multi-source helper arguments>
	local TOOL_item TOOL__tool_variable_name='' TOOL__tools_variable_name='' TOOL__help_function_name=''
	while [[ $# -ne 0 ]]; do
		TOOL_item="$1"
		shift
		case "$TOOL_item" in
		'--tool={'*'}') __dereference --source="${TOOL_item#*=}" --name={TOOL__tool_variable_name} || return $? ;;
		'--tools={'*'}') __dereference --source="${TOOL_item#*=}" --name={TOOL__tools_variable_name} || return $? ;;
		'--help={'*'}') __dereference --source="${TOOL_item#*=}" --name={TOOL__help_function_name} || return $? ;;
		'--'*) __unrecognised_flag "$JOIN__item" || return $? ;;
		*) __unrecognised_argument "$JOIN__item" || return $? ;;
		esac
	done
	# assertions
	__affirm_variable_is_defined "$TOOL__tool_variable_name" 'tool variable reference' || return $?
	__affirm_variable_is_defined "$TOOL__tools_variable_name" 'tools variable reference' || return $?
	__affirm_function_is_defined "$TOOL__help_function_name" 'help function reference' || return $?
	local TOOL__tool='' TOOL__tools=()
	__dereference --source="$TOOL__tool_variable_name" --value={TOOL__tool} || return $?
	__dereference --source="$TOOL__tools_variable_name" --value={TOOL__tools} || return $?
	# dependency
	if [[ $TOOL__tool == '?' ]]; then
		TOOL__tool="$(choose --required 'Which tool to use?' -- "${TOOL__tools[@]}")" || return $?
		__command_required -- "$TOOL__tool" || return $?
	elif [[ -z $TOOL__tool ]]; then
		TOOL__tool="$(__command_required --print -- "${TOOL__tools[@]}")" || return $?
	elif __has --source={TOOL__tools} -- "$TOOL__tool"; then
		__command_required -- "$TOOL__tool" || return $?
	else
		"$TOOL__help_function_name" 'The provided <tool> of ' --variable-value={TOOL__tool} ' is not supported. Supported tools are:' --newline --variable-value={TOOL__tools} || return $? # eval
		return $?
	fi
	# apply
	__to --source={TOOL__tool} --target="{$TOOL__tool_variable_name}" || return $?
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
# 	__slice --source+target={value} -- -1 || return $?
# done
# ```
# into the following:
# ```
# __trim --source+target={test} --leading-delimiters=' ' --trailing-delimiters=' '
# ```
# ```
# __trim --source+target={value} --leading-delimiters=' \'\"' --trailing-delimiters=' \'\"'
# ```

# -------------------------------------
# Progress Bar Toolkit

TERMINAL_TITLE_PROGRESS_BAR__alarmer=0
TERMINAL_TITLE_PROGRESS_BAR__waiter=0
TERMINAL_TITLE_PROGRESS_BAR__ansi=''
function __terminal_title_progress_bar__send_alarm {
	if __is_trap_alive ALRM && __is_process_alive "$TERMINAL_TITLE_PROGRESS_BAR__alarmer"; then
		kill -s ALRM "$TERMINAL_TITLE_PROGRESS_BAR__alarmer" || return 1
	else
		return 1
	fi
}
function __terminal_title_progress_bar__on_alarm {
	if [[ -n $TERMINAL_TITLE_PROGRESS_BAR__ansi ]]; then
		__value_to_tty "$TERMINAL_TITLE_PROGRESS_BAR__ansi" || return $?
	fi
	if __is_trap_alive ALRM && __is_process_alive "$TERMINAL_TITLE_PROGRESS_BAR__alarmer"; then
		{
			sleep 10 || :
			__terminal_title_progress_bar__send_alarm || :
		} &
		TERMINAL_TITLE_PROGRESS_BAR__waiter=$!
	fi
}
function __terminal_title_progress_bar {
	local -i TERMINAL_TITLE_PROGRESS_BAR__progress=0 TERMINAL_TITLE_PROGRESS_BAR__remaining=-1 TERMINAL_TITLE_PROGRESS_BAR__total=100
	local TERMINAL_TITLE_PROGRESS_BAR__item='' TERMINAL_TITLE_PROGRESS_BAR__create='no' TERMINAL_TITLE_PROGRESS_BAR__destroy='no'
	while [[ $# -ne 0 ]]; do
		TERMINAL_TITLE_PROGRESS_BAR__item="$1"
		shift
		case "$TERMINAL_TITLE_PROGRESS_BAR__item" in
		'--create') TERMINAL_TITLE_PROGRESS_BAR__create='yes' ;;
		'--destroy') TERMINAL_TITLE_PROGRESS_BAR__destroy='yes' ;;
		'--progress='* | '--index='*)
			TERMINAL_TITLE_PROGRESS_BAR__item="${TERMINAL_TITLE_PROGRESS_BAR__item#*=}"
			__affirm_value_is_integer "$TERMINAL_TITLE_PROGRESS_BAR__item" 'progress' || return $?
			TERMINAL_TITLE_PROGRESS_BAR__progress="$TERMINAL_TITLE_PROGRESS_BAR__item"
			;;
		'--remaining='*)
			TERMINAL_TITLE_PROGRESS_BAR__item="${TERMINAL_TITLE_PROGRESS_BAR__item#*=}"
			__affirm_value_is_integer "$TERMINAL_TITLE_PROGRESS_BAR__item" 'remaining' || return $?
			TERMINAL_TITLE_PROGRESS_BAR__remaining="$TERMINAL_TITLE_PROGRESS_BAR__item"
			;;
		'--total='*)
			TERMINAL_TITLE_PROGRESS_BAR__item="${TERMINAL_TITLE_PROGRESS_BAR__item#*=}"
			__affirm_value_is_integer "$TERMINAL_TITLE_PROGRESS_BAR__item" 'total' || return $?
			TERMINAL_TITLE_PROGRESS_BAR__total="$TERMINAL_TITLE_PROGRESS_BAR__item"
			;;
		'--'*) __unrecognised_flag "$JOIN__item" || return $? ;;
		*) __unrecognised_argument "$JOIN__item" || return $? ;;
		esac
	done
	# destroy
	if [[ $TERMINAL_TITLE_PROGRESS_BAR__destroy == 'yes' ]]; then
		# kill the waiter
		if __is_process_alive "$TERMINAL_TITLE_PROGRESS_BAR__waiter"; then
			kill -s INT "$TERMINAL_TITLE_PROGRESS_BAR__waiter" || :
		fi
		# clear the alarmer
		trap - ALRM || :
		# send the clear
		TERMINAL_TITLE_PROGRESS_BAR__ansi=$'\e]9;4;0\a'
		__value_to_tty "$TERMINAL_TITLE_PROGRESS_BAR__ansi" || return $?
	elif [[ $TERMINAL_TITLE_PROGRESS_BAR__create == 'yes' ]]; then
		# start the alarmer
		TERMINAL_TITLE_PROGRESS_BAR__alarmer=$(($$ + 1))
		trap __terminal_title_progress_bar__on_alarm ALRM # SIGALRM, 142
		__terminal_title_progress_bar__send_alarm || :
	else
		# calculate the percentages
		if [[ $TERMINAL_TITLE_PROGRESS_BAR__remaining -ne -1 ]]; then
			TERMINAL_TITLE_PROGRESS_BAR__progress="$((TERMINAL_TITLE_PROGRESS_BAR__total - TERMINAL_TITLE_PROGRESS_BAR__remaining))"
		fi
		if [[ $TERMINAL_TITLE_PROGRESS_BAR__total -ne 100 && $TERMINAL_TITLE_PROGRESS_BAR__progress -ne -1 ]]; then
			# trunk-ignore(shellcheck/SC2017)
			TERMINAL_TITLE_PROGRESS_BAR__progress="$(((TERMINAL_TITLE_PROGRESS_BAR__progress * 100 / TERMINAL_TITLE_PROGRESS_BAR__total * 100) / 100))" # bash can't do floating point, so this variation is a workaround
		fi
		# update via alarmer or directly
		TERMINAL_TITLE_PROGRESS_BAR__ansi=$'\e]9;4;1;'"$TERMINAL_TITLE_PROGRESS_BAR__progress"$'\a'
		__terminal_title_progress_bar__send_alarm || {
			if [[ -n $TERMINAL_TITLE_PROGRESS_BAR__ansi ]]; then
				__value_to_tty "$TERMINAL_TITLE_PROGRESS_BAR__ansi" || return $?
			fi
		}
	fi
}

# -------------------------------------
# Debug Toolkit

# BASH_XTRACEFD is a numerical file descriptor where [set -xv] messages go, which are rendered by `PS4`
# BASH_XTRACEFD can only be set during the invocation of bash, and can only be modified within an existing bash process via `exec ...` which forks it.
# If BASH_XTRACEFD is not defined, then it defaults to 2.

export BASH_DEBUG_FORMAT PS4
BASH_DEBUG_FORMAT='+ ${BASH_SOURCE[0]-} [${LINENO}] [${FUNCNAME-}] [${BASH_SUBSHELL-}]'$'    \t'
PS4="$BASH_DEBUG_FORMAT"

# more detailed `set -x`
function __enable_debugging {
	DOROTHY_DEBUG=yes
	set -xv
}
function __disable_debugging {
	set +xv
	DOROTHY_DEBUG=
}

# restore tracing
__restore_tracing
