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
	# equivalent to [printf '\n'] if no arguments
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

# check if the value is a reference, i.e. starts with `{` and ends with `}`, e.g. `{var_name}`.
function __is_reference {
	[[ $1 == '{'*'}' ]] || return
}

# trim the starting `{` and the trailing `}`, e.g. converting `{var_name}` to `var_name`
function __get_reference_name {
	local value_or_var_name="$1" var_name="$1"
	if ! __is_reference "$value_or_var_name"; then
		__print_lines "ERROR: ${FUNCNAME[0]}: Argument was not a reference, which requires wrapping in squigglies: $value_or_var_name" >&2 || :
		return 22 # EINVAL 22 Invalid argument
	fi
	var_name="$(__get_substring "$value_or_var_name" 1 -1)" || return
	if [[ -z $var_name ]]; then
		__print_lines "ERROR: ${FUNCNAME[0]}: Argument reference name was empty: $value_or_var_name" >&2 || :
		return 22 # EINVAL 22 Invalid argument
	fi
	__print_lines "$var_name" || return
	return 0
}
# for __get_reference_value, just use `${!var_name}`

function __is_positive_integer {
	[[ $1 =~ ^[0-9]+$ ]] || return
}

# or you if you already know it is an integer, you can just do: [[ $1 -lt 0 ]]
function __is_negative_integer {
	[[ $1 =~ ^-[0-9]+$ ]] || return
}

function __is_integer {
	[[ $1 =~ ^[-]?[0-9]+$ ]] || return
}

function __is_digit {
	[[ $1 =~ ^[0-9]$ ]] || return
}

function __is_array {
	local IS_ARRAY__reference="$1"
	if __is_reference "$IS_ARRAY__reference"; then
		IS_ARRAY__reference="$(__get_reference_value "$IS_ARRAY__reference")" || return
	fi
	[[ "$(declare -p "$IS_ARRAY__reference" 2>/dev/null || :)" == 'declare -a '* ]] || return
}

function __dump {
	local DUMP__reference DUMP__value DUMP__log=()
	for DUMP__reference in "$@"; do
		if __is_reference "$DUMP__reference"; then
			DUMP__reference="$(__get_reference_value "$DUMP__reference")" || return
		fi
		if __is_array "$DUMP__reference"; then
			local DUMP__index DUMP__total
			eval "DUMP__total=\${#${DUMP__reference}[@]}"
			if [[ $DUMP__total == 0 ]]; then
				DUMP__log+=(--bold="${DUMP__reference}[@]" ' = ' --dim+icon-nothing-provided --newline)
			else
				for ((DUMP__index = 0; DUMP__index < DUMP__total; ++DUMP__index)); do
					eval 'DUMP__value="${!DUMP__reference[DUMP__index]}"'
					DUMP__log+=(--bold="${DUMP__reference}[${DUMP__index}]" ' = ' --invert="$DUMP__value" --newline)
				done
			fi
		else
			DUMP__value="${!DUMP__reference}"
			DUMP__log+=(--bold="$DUMP__reference" ' = ' --invert="$DUMP__value" --newline)
		fi
	done
	echo-style --no-trail "${DUMP__log[@]}" || return
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
			LOGIN_USER="$(users)" || __return $? -- __print_lines "ERROR: ${FUNCNAME[0]}: Unable to fetch the username of the login user." >&2 || return
		fi
	fi
}
function __prepare_login_uid {
	if ! __is_var_set {LOGIN_UID}; then
		LOGIN_UID="${SUDO_UID-}"
		if [[ -z $LOGIN_UID ]]; then
			__prepare_login_user || return
			LOGIN_UID="$(id -u "$LOGIN_USER")" || __return $? -- __print_lines "ERROR: ${FUNCNAME[0]}: Unable to fetch the user ID of the login user." >&2 || return
		fi
	fi
}
function __prepare_login_group {
	if ! __is_var_set {LOGIN_GROUP}; then
		__prepare_login_uid || return
		# trunk-ignore(shellcheck/SC2034)
		LOGIN_GROUP="$(id -gn "$LOGIN_UID")" || __return $? -- __print_lines "ERROR: ${FUNCNAME[0]}: Unable to fetch the group name of the login user." >&2 || return
	fi
}
function __prepare_login_gid {
	if ! __is_var_set {LOGIN_GID}; then
		LOGIN_GID="${SUDO_GID-}"
		if [[ -z $LOGIN_GID ]]; then
			__prepare_login_uid
			LOGIN_GID="$(id -g "$LOGIN_UID")" || __return $? -- __print_lines "ERROR: ${FUNCNAME[0]}: Unable to fetch the group ID of the login user." >&2 || return
		fi
	fi
}
function __prepare_login_groups {
	if ! __is_var_set {LOGIN_GROUPS}; then
		__prepare_login_uid || return
		local groups
		groups="$(id -Gn "$LOGIN_UID")" || __return $? -- __print_lines "ERROR: ${FUNCNAME[0]}: Unable to fetch the groups of the login user." >&2
		__split {LOGIN_GROUPS} --delimiter=' ' -- "$groups" || return
	fi
}
function __prepare_login_gids {
	if ! __is_var_set {LOGIN_GIDS}; then
		__prepare_login_uid || return
		local groups
		groups="$(id -G "$LOGIN_UID")" || __return $? -- __print_lines "ERROR: ${FUNCNAME[0]}: Unable to fetch the groups IDs of the login user." >&2
		__split {LOGIN_GIDS} --delimiter=' ' -- "$groups" || return
	fi
}
function __prepare_current_user {
	if ! __is_var_set {CURRENT_USER}; then
		CURRENT_USER="${USER-}"
		if [[ -z $CURRENT_USER ]]; then
			# note that `dorothy` sets [USER] to the parent of the Dorothy installation, which is appropriate for its [cron] use case
			CURRENT_USER="$(id -un)" || __return $? -- __print_lines "ERROR: ${FUNCNAME[0]}: Unable to fetch the username of the current user." >&2 || return
		fi
	fi
}
function __prepare_current_uid {
	if ! __is_var_set {CURRENT_UID}; then
		CURRENT_UID="${UID-}"
		if [[ -z $CURRENT_UID ]]; then
			CURRENT_UID="$(id -u)" || __return $? -- __print_lines "ERROR: ${FUNCNAME[0]}: Unable to fetch the user ID of the current user." >&2 || return
		fi
	fi
}
function __prepare_current_group {
	if ! __is_var_set {CURRENT_GROUP}; then
		# trunk-ignore(shellcheck/SC2034)
		CURRENT_GROUP="$(id -gn)" || __return $? -- __print_lines "ERROR: ${FUNCNAME[0]}: Unable to fetch the group name of the current user." >&2 || return
	fi
}
function __prepare_current_gid {
	if ! __is_var_set {CURRENT_GID}; then
		# trunk-ignore(shellcheck/SC2034)
		CURRENT_GID="$(id -g)" || __return $? -- __print_lines "ERROR: ${FUNCNAME[0]}: Unable to fetch the group ID of the current user." >&2 || return
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
			groups="$(id -Gn)" || __return $? -- __print_lines "ERROR: ${FUNCNAME[0]}: Unable to fetch the groups of the current user." >&2
			__split {CURRENT_GROUPS} --delimiter=' ' -- "$groups" || return
		fi
	fi
}
function __prepare_current_gids {
	if ! __is_var_set {CURRENT_GIDS}; then
		local groups
		groups="$(id -G)" || __return $? -- __print_lines "ERROR: ${FUNCNAME[0]}: Unable to fetch the groups IDs of the current user." >&2
		__split {CURRENT_GIDS} --delimiter=' ' -- "$groups" || return
	fi
}

# see [commands/eval-helper --elevate] for details
function __elevate {
	# trim -- prefix
	if [[ ${1-} == '--' ]]; then
		shift
	fi
	# forward to [eval-helper --elevate] if it exists, as it is more detailed
	if __command_exists -- eval-helper; then
		eval-helper --elevate -- "$@" || return
		return
	elif __command_exists -- sudo; then
		# check if password is required
		if ! sudo --non-interactive -- true &>/dev/null; then
			# password is required, let the user know what they are being prompted for
			__print_lines 'Your password is required to momentarily grant privileges to execute the command:' >&2 || return
			__print_lines "sudo $*" >&2 || return
		fi
		sudo "$@" # eval
		return
	elif __command_exists -- doas; then
		if ! doas -n true &>/dev/null; then
			__print_lines 'Your password is required to momentarily grant privileges to execute the command:' >&2 || return
			__print_lines "doas $*" >&2 || return
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
# @todo replace this with fs-mkdir
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

# get the value at the index of the reference
# __at {<reference>} <index> | __at <index> {<reference>}
# __at <string> <index> | __at <index> <string>
function __at {
	local AT__reference AT__item AT__input='' AT__index='' AT__value AT__size AT__negative_size AT__eval_statement
	while [[ $# -ne 0 ]]; do
		AT__item="$1"
		shift
		if __is_integer "$AT__item"; then
			if [[ -n $AT__index ]]; then
				__print_lines "ERROR: ${FUNCNAME[0]}: Multiple indexes were provided, only one is allowed." >&2 || :
				return 22 # EINVAL 22 Invalid argument
			fi
			AT__index="$AT__item"
		else
			if [[ -n $AT__input ]]; then
				__print_lines "ERROR: ${FUNCNAME[0]}: Multiple inputs were provided, only one is allowed." >&2 || :
			fi
			AT__input="$AT__item"
		fi
	done
	if [[ -z $AT__index ]]; then
		__print_lines "ERROR: ${FUNCNAME[0]}: No index was provided." >&2 || :
		return 22 # EINVAL 22 Invalid argument
	fi
	if [[ -z $AT__input ]]; then
		__print_lines "ERROR: ${FUNCNAME[0]}: No input was provided." >&2 || :
		return 22 # EINVAL 22 Invalid argument
	fi
	if __is_reference "$AT__input"; then
		AT__reference="$(__get_reference_name "$AT__input")" || return
		if [[ $AT__reference == AT__* ]]; then
			__print_lines "ERROR: ${FUNCNAME[0]}: A variable reference cannot be named $AT__reference as it is used internally." >&2 || :
			return 22 # EINVAL 22 Invalid argument
		fi
		if ! __is_integer "$AT__index"; then
			__print_lines "ERROR: ${FUNCNAME[0]}: The index must be an integer, got: $AT__index" >&2 || :
			return 22 # EINVAL 22 Invalid argument
		fi
		if __is_array "$AT__reference"; then
			eval "AT__size=\${#${AT__reference}[@]}"
			AT__eval_statement="AT__value=\"\${${AT__reference}[\$AT__index]}\""
		else
			eval "AT__size=\${#${AT__reference}}"
			AT__eval_statement="AT__value=\"\${${AT__reference}:(\$AT__index):1}\""
		fi
	else
		AT__reference='AT__input'
		AT__size="${#AT__input}"
		AT__eval_statement="AT__value=\"\${${AT__reference}:(\$AT__index):1}\""
	fi
	AT__negative_size="$((AT__size * -1))"
	if [[ $AT__index -lt $AT__negative_size || $AT__index -ge $AT__size ]]; then
		__print_lines "ERROR: ${FUNCNAME[0]}: The index $AT__index was out of range $AT__negative_size (inclusive) to $AT__size (exclusive)." >&2 || :
		return 14 # EFAULT 14 Bad address
	elif [[ $AT__index -lt 0 ]]; then
		AT__index="$((AT__size + AT__index))"
	fi
	eval "$AT__eval_statement" || return
	__print_lines "$AT__value" || return
}

function __absolute {
	if __is_negative_integer "$1"; then
		# convert negative to positive
		__print_lines "$(($1 * -1))" || return
	else
		# leave positive as is
		__print_lines "$1" || return
	fi
}

# bash >= 5.2 supports negative indexes and negative lengths, via ${var: -3: -1} and ${var:(-3):(-1)} and ${var:"-3":"-1"} and ${var:$start:$length} and ${var:start:length}
# bash >= 4.2 supports negative start indexes and negative lengths, via ${var: -3: -1} or ${var:(-3):(-1)} and ${var:$start:$length} and ${var:start:length} BUT NOT via ${var:"-1"}
# bash >= 3.2 supports negative start indexes but not negative lengths, via ${var: -3: 1} or ${var:(-3):1} and ${var:$start:$length} and ${var:start:length} BUT NOT via ${var:"-1"}
# all bash versions return an empty string if negative start index is out of bounds, rather than the entire string, which is unintuitive; we change it to still function as a window
# all bash versions crash if the length is negative and is out of bounds; note that a positive length that is out of bounds does not crash; we change it to a no-op
# @todo support switching between --lengths and --indices for positive integers
# @note it's algorithm should be the same as __slice and __split
function __get_substring {
	# handle string
	if [[ -z $1 ]]; then
		return 0 # no-op, as the string is empty
	fi
	local string="$1"
	local -i start length size="${#string}" remaining
	# determine start
	if [[ -z ${2-} ]]; then
		start=0
	elif [[ $2 == '-0' ]]; then
		return 0 # no-op
	elif __is_integer "$2"; then
		start="$2"
		if __is_negative_integer "$start"; then
			start="$((size + start))" # note that size could be like 5, and start be like -10, which still results in -5
		fi
		if [[ $start -ge $size ]]; then
			return 0 # no-op, as start is beyond the end of the string
		fi
	else
		__print_lines "ERROR: ${FUNCNAME[0]}: The start index must be a positive or negative integer, got: $2" >&2 || :
		return 22 # EINVAL 22 Invalid argument
	fi
	# determine length
	if [[ -z ${3-} || $3 == '-0' ]]; then
		# no length specified, use the remaining length
		if [[ $start -le 0 ]]; then
			# if start is 0, we can just print the whole string
			__print_string "$string" || return
		else
			# if start is not 0, we can just print the substring from start to the end
			__print_string "${string:start}" || return
		fi
		return 0
	elif __is_integer "$3"; then
		length="$3"
		if __is_negative_integer "$length"; then
			if [[ $start -lt 0 ]]; then
				start=0
			fi
			length="$((size + length - start))" # note this could still result in a negative length, if size was 5, and length was -10
		elif [[ $start -lt 0 ]]; then
			if [[ "$((start + length))" -le 0 ]]; then
				return 0
			fi
			length="$((length + start))" # reduce the length by the out of the bounds negative start
			start=0
		fi
	else
		__print_lines "ERROR: ${FUNCNAME[0]}: The length must be a positive or negative integer, got: $3" >&2 || :
		return 22 # EINVAL 22 Invalid argument
	fi
	# start and length ought now be >= 0
	# determine window
	if [[ $length -lt 0 ]]; then
		return 0 # no-op, as there is no size left
	else
		remaining="$((size - start))"
		if [[ $length -ge $remaining ]]; then
			__print_string "${string:start}" || return
		else
			__print_string "${string:start:length}" || return
		fi
	fi
	return 0
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
		__print_lines "$result" || return
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
		__print_lines "$3" || return
		return 0
	else
		__print_lines "ERROR: ${FUNCNAME[0]}: Delimiter $delimiter was not found within: $string" >&2 || :
		return 1
	fi
}

# @todo replace all native occurrences with this self-documenting and less-error prone function
# __get_substring_before_last <string> <delimiter> [<fallback>]
function __get_substring_before_last {
	local string="$1" delimiter="$2" result
	result="${string%"$delimiter"*}"
	if [[ $result != "$string" ]]; then
		__print_lines "$result" || return
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
		__print_lines "$3" || return
		return 0
	else
		__print_lines "ERROR: ${FUNCNAME[0]}: Delimiter $delimiter was not found within: $string" >&2 || :
		return 1
	fi
}

# @todo replace all native occurrences with this self-documenting and less-error prone function
# __get_substring_after_first <string> <delimiter> [<fallback>]
function __get_substring_after_first {
	local string="$1" delimiter="$2" result
	result="${string#*"$delimiter"}"
	if [[ $result != "$string" ]]; then
		__print_lines "$result" || return
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
		__print_lines "$3" || return
		return 0
	else
		__print_lines "ERROR: ${FUNCNAME[0]}: Delimiter $delimiter was not found within: $string" >&2 || :
		return 1
	fi
}

# @todo replace all native occurrences with this self-documenting and less-error prone function
# __get_substring_after_last <string> <delimiter> [<fallback>]
function __get_substring_after_last {
	local string="$1" delimiter="$2" result
	result="${string##*"$delimiter"}"
	if [[ $result != "$string" ]]; then
		__print_lines "$result" || return
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
		__print_lines "$3" || return
		return 0
	else
		__print_lines "ERROR: ${FUNCNAME[0]}: Delimiter $delimiter was not found within: $string" >&2 || :
		return 1
	fi
}

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
		__print_lines "$input" || return
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
		trimmed="$(__split_shapeshifting -- "$input")" || return
		if [[ $input != "$trimmed" ]]; then
			return 0
		fi
	done
	return 1
}

# check if the input is a special target
function __is_special_file {
	local target="$1"
	case "$target" in
	1 | stdout | STDOUT | /dev/stdout | 2 | stderr | STDERR | /dev/stderr | tty | TTY | /dev/tty | null | NULL | /dev/null | [0-9]*) return 0 ;; # is a special file
	'')
		__print_lines "ERROR: ${FUNCNAME[0]}: An unrecognised target was provided: $target" >&2 || :
		return 22
		;;            # EINVAL 22 Invalid argument
	*) return 1 ;; # not a special file
	esac
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

# Open a file descriptor in a cross-bash compatible way
# alternative implementations at https://stackoverflow.com/q/8297415/130638
# __open_fd ...<{file_descriptor_reference}> ...<file_descriptor_number> <mode> <target>
function __open_fd {
	local OPEN_FD__item OPEN_FD__number OPEN_FD__numbers=() OPEN_FD__reference OPEN_FD__references=() OPEN_FD__references_count OPEN_FD__mode='' OPEN_FD__target_number='' OPEN_FD__target_file='' OPEN_FD__eval_statement_exec='' OPEN_FD__eval_statement_assignments=''
	function __validate_reference {
		local reference="$1"
		if [[ $reference == OPEN_FD__* ]]; then
			__print_lines "ERROR: ${FUNCNAME[0]}: A variable reference cannot be named $reference as it is used internally." >&2 || :
			return 22 # EINVAL 22 Invalid argument
		fi
		return 0
	}
	while [[ $# -ne 0 ]]; do
		OPEN_FD__item="$1"
		shift
		if [[ -z $OPEN_FD__mode ]]; then
			case "$OPEN_FD__item" in
			# file descriptor
			'{'*'}')
				OPEN_FD__reference="$(__get_reference_name "$OPEN_FD__item")" || return
				__validate_reference "$OPEN_FD__reference" || return
				OPEN_FD__references+=("$OPEN_FD__reference")
				;;
			[0-9]*) OPEN_FD__numbers+=("$OPEN_FD__item") ;;
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
	eval "exec $OPEN_FD__eval_statement_exec; $OPEN_FD__eval_statement_assignments" || return
}

# __close_fd ...<{file_descriptor_reference}> ...<file_descriptor_number>
function __close_fd {
	local CLOSE_FD__arg CLOSE_FD__number CLOSE_FD__reference CLOSE_FD__eval_statement_exec=''
	if [[ $# -eq 0 ]]; then
		__print_lines "ERROR: ${FUNCNAME[0]}: Too little arguments provided, expected a file descriptor number or reference." >&2 || :
		return 22 # EINVAL 22 Invalid argument
	fi
	for CLOSE_FD__arg in "$@"; do
		if __is_positive_integer "$CLOSE_FD__arg"; then
			CLOSE_FD__number="$CLOSE_FD__arg"
		else
			CLOSE_FD__reference="$(__get_reference_name "$CLOSE_FD__arg")"
			if [[ $CLOSE_FD__reference == CLOSE_FD__* ]]; then
				__print_lines "ERROR: ${FUNCNAME[0]}: A variable reference cannot be named $CLOSE_FD__reference as it is used internally." >&2 || :
				return 22 # EINVAL 22 Invalid argument
			fi
			if [[ $BASH_VERSION_MAJOR -ge 5 || ($BASH_VERSION_MAJOR -eq 4 && $BASH_VERSION_MINOR -ge 1) ]]; then
				# close via the file descriptor reference
				CLOSE_FD__eval_statement_exec+="{$CLOSE_FD__reference}>&- "
				continue
			else
				# get the file descriptor directly
				CLOSE_FD__number="${!CLOSE_FD__reference}"
			fi
		fi
		# close the file descriptor number
		CLOSE_FD__eval_statement_exec+="$CLOSE_FD__number>&- "
	done
	eval "exec $CLOSE_FD__eval_statement_exec" || return
}

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

# more detailed [set -x]
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
		'--invoke-only-on-failure') RETURN__invoke_only_on_failure=yes ;;
		'--')
			RETURN__invoke_command+=("$@")
			shift $#
			break
			;;
		[0-9]*)
			if [[ $RETURN__status -eq 0 ]]; then
				RETURN__status="$RETURN__item"
			fi
			;;
		*)
			__print_lines "ERROR: ${FUNCNAME[0]}: Invalid argument provided: $RETURN__item" >&2 || :
			return 22 # EINVAL 22 Invalid argument
			;;
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

# these aren't used anywhere yet:

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
# note that the curl pipefail 56 occurs because we pipe [curl] to [:], similar to how we cause another pipefail later by piping [yes] to [head -n 1], this is a contrived example to demonstrate the point
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

function __is_errexit {
	[[ $- == *e* ]] || return # explicit `|| return` required to prevent ERR trap from firing, which is important here as it is used within our ERR trap
}

function __is_not_errexit {
	[[ $- != *e* ]] || return # explicit `|| return` required to prevent ERR trap from firing, which is important here as it is used within our ERR trap
}

function __is_subshell_function {
	# don't assign $1 to a variable, as then that means the variable name could conflict with the evaluation from the declare
	# test "$(declare -f "$1")" == "$1"$' () \n{ \n    ('
	[[ "$(declare -f "$1")" == "$1"$' () \n{ \n    ('* ]] || return # explicit `|| return` required to prevent ERR trap from firing, which is important here as it is used within our ERR trap
}

function __get_function_inner {
	local GET_FUNCTION_INNER__function_code
	GET_FUNCTION_INNER__function_code="$(declare -f "$1")" || return
	# remove header and footer of function
	# this only works bash 5.2 and above:
	# code="${code#*$'\n{ \n'}"
	# code="${code%$'\n}'*}"
	# this works, but reveals the issue with the above is the escaping:
	# code="${code#*"$osb $newline"}"
	# code="${code%"$newline$csb"*}"
	# as such, use this wrapper, which is is clear to our intent:
	GET_FUNCTION_INNER__function_code="$(__get_substring_after_first "$GET_FUNCTION_INNER__function_code" $'{ \n')" || return
	GET_FUNCTION_INNER__function_code="$(__get_substring_before_last "$GET_FUNCTION_INNER__function_code" $'\n}')" || return
	__print_string "$GET_FUNCTION_INNER__function_code" || return
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
			if [[ ${fns[index]} == "$until" ]]; then
				__print_lines "$index" || return
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
		__print_lines "$fn" || return
		return 0
	done
	return 1
}

function __get_semlock {
	local context_id="$1" dir="${XDG_CACHE_HOME:-"$HOME/.cache"}/dorothy/semlocks" semlock wait pid=$$
	__mkdirp "$dir" || return
	# the lock file contains the process id that has the lock
	semlock="$dir/$context_id.lock"
	# wait for a exclusive lock
	while :; do
		# don't bother with a [[ -s "$semlock" ]] before [cat] as the semlock could have been removed between
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
# as to why use [__get_semaphore] instead of [mktemp], is that we want [dorothy test] to check if we cleaned everything up, furthermore, [mktemp] actually makes the files, so you have to do more expensive [-s] checks
function __get_semaphore {
	local context_id="${1:-"$RANDOM$RANDOM"}" dir="${XDG_CACHE_HOME:-"$HOME/.cache"}/dorothy/semaphores"
	__mkdirp "$dir" || return
	__print_lines "$dir/$context_id" || return
}

# overwrites instead of appends
function __get_semaphores {
	local GET_SEMAPHORES__reference="$1" GET_SEMAPHORES__context_id GET_SEMAPHORES__semaphores=()
	shift # trim reference
	GET_SEMAPHORES__reference="$(__get_reference_name "$GET_SEMAPHORES__reference")" || return
	if [[ $GET_SEMAPHORES__reference == GET_SEMAPHORES__* ]]; then
		__print_lines "ERROR: ${FUNCNAME[0]}: A variable reference cannot be named $HAS__reference as it is used internally." >&2 || :
		return 22 # EINVAL 22 Invalid argument
	fi
	# trim -- prefix
	if [[ $1 == '--' ]]; then
		shift
	fi
	for GET_SEMAPHORES__context_id in "$@"; do
		# get the semaphore file
		GET_SEMAPHORES__semaphores+=("$(__get_semaphore "$GET_SEMAPHORES__context_id")") || return
	done
	eval "$GET_SEMAPHORES__reference=(\"\${GET_SEMAPHORES__semaphores[@]}\")" || return
}

# As to why semaphores are even necessary,
# >( ... ) happens asynchronously, however the commands within >(...) happen synchronously, as such we can use this technique to know when they are done, otherwise on the very rare occasion the files may not exist or be incomplete by the time we get to to reading them: https://github.com/bevry/dorothy/issues/277
# Note that this waits forever on bash 4.1.0, as the [touch] commands that create our semaphore only execute after a [ctrl+c], other older and newer versions are fine
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

# =============================================================================
# Configure bash for Dorothy best practices.
# @todo move this section to the start

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
# @todo re-add samasama support for possible performance improvement: https://gist.github.com/balupton/32bfc21702e83ad4afdc68929af41c23
# @todo consider using [FD>&-] instead of [FD>/dev/null]
function __do {
	# 🧙🏻‍♀️ the power is yours, send donations to github.com/sponsors/balupton
	if [[ $# -eq 0 ]]; then
		__print_lines "ERROR: ${FUNCNAME[0]}: Arguments are required." >&2 || :
		return 22 # EINVAL 22 Invalid argument
	fi
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
	if [[ $DO__arg_value =~ ^(tty|TTY|/dev/tty)$ && ! ($TERMINAL_OUTPUT_TARGET =~ ^(tty|TTY|/dev/tty)$) ]]; then
		__do --right-to-left "$DO__arg_flag=$TERMINAL_OUTPUT_TARGET" "$@"
		return
	fi
	# process
	function __validate_reference {
		local reference="$1"
		if [[ $reference == DO__* ]]; then
			__print_lines "ERROR: ${FUNCNAME[0]}: A variable reference cannot be named $reference as it is used internally." >&2 || :
			return 22 # EINVAL 22 Invalid argument
		fi
	}
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

		# trim squigglies
		DO__reference="$(__get_reference_name "$DO__arg_value")" || return
		__validate_reference "$DO__reference" || return

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

		# trim squigglies
		DO__reference="$(__get_reference_name "$DO__arg_value")" || return
		__validate_reference "$DO__reference" || return

		# reset all var to prevent inheriting prior values of the same name if this one has a failure status which prevents updating the values
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
	# 	DO__code="$(__get_substring "$DO__arg_value" 1)" || return

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
		local DO__code DO__semaphore

		# trim starting ( and trailing ), converting (<code>) to <code>
		DO__code="$(__get_substring "$DO__arg_value" 1 -1)" || return

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
			__do --right-to-left "$@" >>/dev/tty
			return
			;;

		# redirect stdout to null
		null | NULL | /dev/null)
			__do --right-to-left "$@" >/dev/null
			return
			;;

		# redirect stdout to FD target
		[0-9]*)
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
		1 | stdout | STDOUT | /dev/stdout)
			# no-op
			__do --right-to-left "$@"
			return
			;;

		# copy stdout to stderr
		2 | stderr | STDERR | /dev/stderr)
			# prepare our semaphore files that will track the exit status of the process substitution
			local DO__semaphores DO__context="__do.copy-stdout-to-stderr.$RANDOM$RANDOM"
			__get_semaphores {DO__semaphores} -- "$DO__context.1" "$DO__context.2" || return

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
		tty | TTY | /dev/tty)
			# prepare our semaphore files that will track the exit status of the process substitution
			local DO__semaphores DO__context="__do.copy-stdout-to-tty.$RANDOM$RANDOM"
			__get_semaphores {DO__semaphores} -- "$DO__context.1" "$DO__context.2" || return

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
		null | NULL | /dev/null)
			# no-op
			__do --right-to-left "$@"
			return
			;;

		# copy stdout to FD target
		[0-9]*)
			# prepare our semaphore files that will track the exit status of the process substitution
			local DO__semaphores DO__context="__do.copy-stdout-to-fd.$RANDOM$RANDOM"
			__get_semaphores {DO__semaphores} -- "$DO__context.1" "$DO__context.2" || return

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
			__do --right-to-left "$@" 2>>/dev/tty
			return
			;;

		# redirect stderr to null
		null | NULL | /dev/null)
			__do --right-to-left "$@" 2>/dev/null
			return
			;;

		# redirect stderr to FD target
		[0-9]*)
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
		1 | stdout | STDOUT | /dev/stdout)
			# prepare our semaphore files that will track the exit status of the process substitution
			local DO__semaphores DO__context="__do.copy-stderr-to-stdout.$RANDOM$RANDOM"
			__get_semaphores {DO__semaphores} -- "$DO__context.1" "$DO__context.2" || return

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
		2 | stderr | STDERR | /dev/stderr)
			# no-op
			__do --right-to-left "$@"
			return
			;;

		# copy stderr to tty
		tty | TTY | /dev/tty)
			# prepare our semaphore files that will track the exit status of the process substitution
			local DO__semaphores DO__context="__do.copy-stderr-to-tty.$RANDOM$RANDOM"
			__get_semaphores {DO__semaphores} -- "$DO__context.1" "$DO__context.2" || return

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
		null | NULL | /dev/null)
			# no-op
			__do --right-to-left "$@"
			return
			;;

		# copy stderr to FD target
		[0-9]*)
			# prepare our semaphore files that will track the exit status of the process substitution
			local DO__semaphores DO__context="__do.copy-stderr-to-fd.$RANDOM$RANDOM"
			__get_semaphores {DO__semaphores} -- "$DO__context.1" "$DO__context.2" || return

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
		1 | stdout | STDOUT | /dev/stdout)
			__do --right-to-left "$@" 2>&1
			return
			;;

		# redirect stdout to stderr
		2 | stderr | STDERR | /dev/stderr)
			__do --right-to-left "$@" >&2
			return
			;;

		# redirect stderr to stdout, then stdout to tty, as `&>>` is not supported in all bash versions
		tty | TTY | /dev/tty)
			__do --right-to-left "$@" >>/dev/tty 2>&1
			return
			;;

		# redirect output to null
		null | NULL | /dev/null | no)
			__do --right-to-left "$@" &>/dev/null
			return
			;;

		# redirect stderr to stdout, such that and then, both stdout and stderr are redirected to the fd target
		[0-9]*)
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
		1 | stdout | STDOUT | /dev/stdout)
			# @todo implement this
			__print_lines "ERROR: ${FUNCNAME[0]}: A to be implemented flag was provided: $DO__arg" >&2 || :
			return 78 # NOSYS 78 Function not implemented
			;;

		# copy output to stderr, this behaviour is unspecified, as there is no way to send it back to output
		2 | stderr | STDERR | /dev/stderr)
			# @todo implement this
			__print_lines "ERROR: ${FUNCNAME[0]}: A to be implemented flag was provided: $DO__arg" >&2 || :
			return 78 # NOSYS 78 Function not implemented
			;;

		# copy output to tty, this behaviour is unspecified, as there is no way to send it back to output
		tty | TTY | /dev/tty)
			# @todo implement this
			__print_lines "ERROR: ${FUNCNAME[0]}: A to be implemented flag was provided: $DO__arg" >&2 || :
			return 78 # NOSYS 78 Function not implemented
			;;

		# copy stderr to null
		null | NULL | /dev/null)
			# no-op
			__do --right-to-left "$@"
			return
			;;

		# copy output to FD target, this behaviour is unspecified, as there is no way to send it back to output
		[0-9]*)
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
	# declare local variables
	local DOROTHY_TRY__item DOROTHY_TRY__reference=''
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
		{*}) DOROTHY_TRY__reference="$(__get_substring "$DOROTHY_TRY__item" 1 -1)" ;; # trim starting { and trailing }
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
	if [[ -n $DOROTHY_TRY__reference ]]; then
		eval "$DOROTHY_TRY__reference=${DOROTHY_TRY__STATUS:-0}"
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

# Bash >= 5, < 5
if [[ $BASH_VERSION_MAJOR -ge 5 ]]; then
	function __get_epoch_time {
		__print_lines "$EPOCHREALTIME" || return
	}
else
	function __get_epoch_time {
		__get_substring "$(date +%s.%N)" 0 -3 || return
	}
fi

# Bash >= 4, < 4
if [[ $BASH_VERSION_MAJOR -ge 4 ]]; then
	# bash >= 4
	# [read -i] only works if STDIN is open on terminal
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
		__print_lines "$1" || return
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
			__print_lines 1 || return
		else
			__print_lines "$1" || return
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
		__print_lines "${1@u}" || return
	}
	function __uppercase_string {
		# trim -- prefix
		if [[ ${1-} == '--' ]]; then
			shift
		fi
		# proceed
		__print_lines "${1@U}" || return
	}
	function __lowercase_string {
		# trim -- prefix
		if [[ ${1-} == '--' ]]; then
			shift
		fi
		# proceed
		__print_lines "${1@L}" || return
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
			__print_lines "${1^}" || return
		}
		function __uppercase_string {
			# trim -- prefix
			if [[ ${1-} == '--' ]]; then
				shift
			fi
			# proceed
			__print_lines "${1^^}" || return
		}
		function __lowercase_string {
			# trim -- prefix
			if [[ ${1-} == '--' ]]; then
				shift
			fi
			# proceed
			__print_lines "${1,,}" || return
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
			local first_char="${input:0:1}" rest="${input:1}" result
			result="$(tr '[:lower:]' '[:upper:]' <<<"$first_char")" || return
			__print_lines "$result$rest" || return
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

# bash >= 4.2
# p.  Negative subscripts to indexed arrays, previously errors, now are treated
#     as offsets from the maximum assigned index + 1.
# q.  Negative length specifications in the ${var:offset:length} expansion,
#     previously errors, are now treated as offsets from the end of the variable.
# [test -v varname] is not used as it behaviour is inconsistent to expectations and across versions
function __is_var_set {
	local reference fodder
	if [[ $# -eq 0 ]]; then
		__print_lines "ERROR: ${FUNCNAME[0]}: No variable references provided" >&2 || :
		return 22 # EINVAL 22 Invalid argument
	fi
	while [[ $# -ne 0 ]]; do
		reference="$(__get_reference_name "$1")" || return
		# bash 3.2 and 4.0 will have [local z; declare -p z] will result in [declare -- z=""], this is because on these bash versions, [local z] is actually [local z=] so the var is actually set
		# bash 4.2 will have [local z; declare -p z] will result in [declare: z: not found]
		# bash 4.4+ will have [local z; declare -p z] will result in [declare -- z]
		# [set -u] has no effect
		fodder="$(declare -p "$reference" 2>/dev/null)" || return 1
		[[ $fodder == *'='* ]] || return 1
		shift
	done
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
		dorothy-warnings add --code='mapfile' --bold=' has been deprecated in favor of ' --code='__split' || :
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
					'mapfile[shim]: usage: mapfile -t [-d delim] <array>' >&2
				return 2 # that's what native mapfile returns
				;;
			*)
				if [[ -z $MAPFILE__reference ]]; then
					MAPFILE__reference="$1"
				else
					__print_lines \
						"mapfile[shim]: unknown argument: $1" \
						'mapfile[shim]: usage: mapfile -t [-d delim] <array>' >&2
					return 2 # that's what native mapfile returns
				fi
				;;
			esac
		done
		if [[ -z $MAPFILE__reference ]]; then
			__print_lines \
				'mapfile[shim]: <array> is required in our bash v3 shim' \
				'mapfile[shim]: usage: mapfile -t [-d delim] <array>' >&2
			return 2 # that's what native mapfile returns
		fi
		if [[ $MAPFILE__reference == MAPFILE__* ]]; then
			__print_lines "ERROR: ${FUNCNAME[0]}: A variable reference cannot be named $MAPFILE__reference as it is used internally." >&2
			return 22 # EINVAL 22 Invalid argument
		fi
		if [[ $MAPFILE__t != 'yes' ]]; then
			__print_lines \
				'mapfile[shim]: -t is required in our bash v3 shim' \
				'mapfile[shim]: usage: mapfile -t [-d delim] <array>' >&2
			return 2 # that's what native mapfile returns
		fi
		shift
		eval "${MAPFILE__reference}=()" || return
		while IFS= read -rd "$MAPFILE__delim" MAPFILE__reply || [[ -n $MAPFILE__reply ]]; do
			eval "${MAPFILE__reference}+=(\"\${MAPFILE__reply}\")" || return
		done
	}
fi
BASH_ARRAY_CAPABILITIES+=' '

function __make_array {
	local MAKE_ARRAY__item MAKE_ARRAY__option_targets=() MAKE_ARRAY__option_size=0 MAKE_ARRAY__value='' MAKE_ARRAY__index MAKE_ARRAY__list='' MAKE_ARRAY__reference MAKE_ARRAY__eval_statement=''
	function __validate_reference {
		local reference="$1"
		if [[ $reference == MAKE_ARRAY__* ]]; then
			__print_lines "ERROR: ${FUNCNAME[0]}: A variable reference cannot be named $reference as it is used internally." >&2
			return 22 # EINVAL 22 Invalid argument
		fi
	}
	while [[ $# -ne 0 ]]; do
		MAKE_ARRAY__item="$1"
		shift
		case "$MAKE_ARRAY__item" in
		'{'*'}')
			MAKE_ARRAY__reference="$(__get_reference_name "$MAKE_ARRAY__item")" || return
			__validate_reference "$MAKE_ARRAY__reference" || return
			MAKE_ARRAY__option_targets+=("$MAKE_ARRAY__reference")
			;;
		'--size='*) MAKE_ARRAY__option_size="${MAKE_ARRAY__item#*=}" ;;
		# trunk-ignore(shellcheck/SC2034)
		'--value='*) MAKE_ARRAY__value="${MAKE_ARRAY__item#*=}" ;;
		--*)
			__print_lines "ERROR: ${FUNCNAME[0]}: An unrecognised flag was provided: $MAKE_ARRAY__item" >&2
			return 22 # EINVAL 22 Invalid argument
			;;
		*) MAKE_ARRAY__option_targets+=("$MAKE_ARRAY__item") ;;
		esac
	done
	if [[ ${#MAKE_ARRAY__option_targets[@]} -eq 0 ]]; then
		__print_lines "ERROR: ${FUNCNAME[0]}: A variable reference must be provided." >&2
		return 22 # EINVAL 22 Invalid argument
	fi
	# generate the array values
	for ((MAKE_ARRAY__index = 0; MAKE_ARRAY__index < MAKE_ARRAY__option_size; MAKE_ARRAY__index++)); do
		# the alternative would be using `{...@Q}` however that isn't available on all bash versions, but this is equally good, perhaps better
		MAKE_ARRAY__list+='"$MAKE_ARRAY__value" '
	done
	# apply the list to the target, while avoiding conflicts
	for MAKE_ARRAY__reference in "${MAKE_ARRAY__option_targets[@]}"; do
		# apply the list to the target
		MAKE_ARRAY__eval_statement+="$MAKE_ARRAY__reference=($MAKE_ARRAY__list); "
	done
	eval "$MAKE_ARRAY__eval_statement" || return
}

# split, unlike mapfile and readarray, supports multi-character delimiters, and multiple delimiters
# this is wrong:
# __split {arr} --no-zero-length < <(<output-command>)
# __split {arr} --no-zero-length <<< "$(<output-command>)"
# __split {arr} --no-zero-length < <(<output-command> | tr $'\t ,|' '\n')
# and this is right:
# fodder_to_respect_exit_status="$(<output-command>)"
# __split {arr} --no-zero-length --invoke -- <output-command> # this preserves trail
# __split {arr} --no-zero-length -- "$fodder_to_respect_exit_status"
# __split {arr} --no-zero-length -- "$fodder_to_respect_exit_status"
# __split {arr} --delimiters=$'\n\t ,|' --no-zero-length -- "$fodder_to_respect_exit_status"
# use --delimiter='<a multi character delimiter>' to specify a single multi-character delimiter
function __split {
	local SPLIT__item SPLIT__option_reference='' SPLIT__option_invoke='no' SPLIT__option_append='no' SPLIT__option_with_zero_length='yes' SPLIT__option_delimiters=() SPLIT__option_inputs=() \
	SPLIT__character_left_index SPLIT__last_slice_left_index SPLIT__string_length SPLIT__string_last SPLIT__delimiter SPLIT__delimiter_length \
	SPLIT__offsets=() SPLIT__offset SPLIT__delimiter_and_offset_index SPLIT__reply SPLIT__window SPLIT__character
	while [[ $# -ne 0 ]]; do
		SPLIT__item="$1"
		shift
		case "$SPLIT__item" in
		'{'*'}') SPLIT__option_reference="$(__get_reference_name "$SPLIT__item")" || return ;;
		'--append') SPLIT__option_append='yes' ;;
		'--no-zero-length') SPLIT__option_with_zero_length='no' ;;
		'--invoke') SPLIT__option_invoke='yes' ;;
		'--keep-zero-length') : ;; # no-op as already the case
		'--delimiter='*) SPLIT__option_delimiters+=("${SPLIT__item#*=}") ;;
		'--delimiters='*)
			SPLIT__item="${SPLIT__item#*=}"
			for ((SPLIT__character_left_index = 0, SPLIT__string_length = "${#SPLIT__item}"; SPLIT__character_left_index < SPLIT__string_length; SPLIT__character_left_index++)); do
				SPLIT__character="${SPLIT__item:SPLIT__character_left_index:1}"
				SPLIT__option_delimiters+=("$SPLIT__character")
			done
			;;
		--)
			if [[ $# -eq 0 ]]; then
				# there's no items, be a no-op if not appending, if appending then reset to nothing
				if [[ $SPLIT__option_append == 'no' ]]; then
					eval "${SPLIT__option_reference}=()" || return
				fi
				return 0
			fi
			if [[ $SPLIT__option_invoke == 'yes' ]]; then
				local SPLIT__fodder_to_respect_exit_status
				__do --redirect-stdout={SPLIT__fodder_to_respect_exit_status} -- "$@"
				SPLIT__option_inputs+=("$SPLIT__fodder_to_respect_exit_status")
			else
				SPLIT__option_inputs+=("$@")
			fi
			shift $#
			break
			;;
		--*)
			__print_lines "ERROR: ${FUNCNAME[0]}: An unrecognised flag was provided: $SPLIT__item" >&2
			return 22 # EINVAL 22 Invalid argument
			;;
		*)
			__print_lines "ERROR: ${FUNCNAME[0]}: An unrecognised argument was provided: $SPLIT__item" >&2
			return 22 # EINVAL 22 Invalid argument
			;;
		esac
	done
	if [[ -z $SPLIT__option_reference ]]; then
		__print_lines "ERROR: ${FUNCNAME[0]}: A variable reference must be provided." >&2
		return 22 # EINVAL 22 Invalid argument
	fi
	if [[ $SPLIT__option_reference == SPLIT__* ]]; then
		__print_lines "ERROR: ${FUNCNAME[0]}: A variable reference cannot be named $SPLIT__reference as it is used internally." >&2
		return 22 # EINVAL 22 Invalid argument
	fi
	# reset if not append
	if [[ $SPLIT__option_append == 'no' ]]; then
		eval "${SPLIT__option_reference}=()" || return
	fi
	# read everything from stdin
	if [[ ${#SPLIT__option_inputs[@]} -eq 0 ]]; then
		while LC_ALL=C IFS= read -rd '' SPLIT__reply || [[ -n $SPLIT__reply ]]; do
			SPLIT__option_inputs+=("$SPLIT__reply")
			SPLIT__reply=''
		done
	fi
	# cycle through it
	if [[ ${#SPLIT__option_delimiters[@]} -eq 0 ]]; then
		SPLIT__option_delimiters+=($'\n')
	fi
	for SPLIT__delimiter in "${SPLIT__option_delimiters[@]}"; do
		SPLIT__delimiter_length=${#SPLIT__delimiter}
		SPLIT__offset=$((SPLIT__delimiter_length * -1)) # variable needed for early bash versions
		SPLIT__offsets+=("$SPLIT__offset")
	done
	for SPLIT__item in "${SPLIT__option_inputs[@]}"; do
		# check if we even apply
		if [[ -z $SPLIT__item ]]; then
			# the item is empty, add it if desired
			if [[ $SPLIT__option_with_zero_length == 'yes' ]]; then
				eval "$SPLIT__option_reference+=('')"
			fi
			# move to the next item
			continue
		fi
		# reset the window for each argument
		SPLIT__window=''
		SPLIT__last_slice_left_index=-1
		SPLIT__string_length=${#SPLIT__item}
		SPLIT__string_last=$((SPLIT__string_length - 1))
		# process the argument
		for ((SPLIT__character_left_index = 0; SPLIT__character_left_index < SPLIT__string_length; SPLIT__character_left_index++)); do
			# add the character to the window, no need for __get_substring as it is a simple slice
			SPLIT__character="${SPLIT__item:SPLIT__character_left_index:1}"
			SPLIT__window+="$SPLIT__character"
			# cycle through the delimiters
			for SPLIT__delimiter_and_offset_index in "${!SPLIT__option_delimiters[@]}"; do
				SPLIT__delimiter="${SPLIT__option_delimiters[SPLIT__delimiter_and_offset_index]}"
				SPLIT__offset="${SPLIT__offsets[SPLIT__delimiter_and_offset_index]}"
				# does the window end with our delimiter?
				if [[ $SPLIT__window == *"$SPLIT__delimiter" ]]; then
					# remove the delimiter
					SPLIT__window="$(__get_substring "$SPLIT__window" 0 "$SPLIT__offset")" || return
					# do we want to add it?
					if [[ $SPLIT__option_with_zero_length == 'yes' || -n $SPLIT__window ]]; then
						eval "$SPLIT__option_reference+=(\"\$SPLIT__window\")" || return
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
			if [[ $SPLIT__option_with_zero_length == 'yes' || -n $SPLIT__window ]]; then
				eval "$SPLIT__option_reference+=(\"\${SPLIT__item}\")" || return
			fi
		elif [[ $SPLIT__last_slice_left_index -ne $SPLIT__string_last ]]; then
			# the delimiter was not the last character, so add the pending slice
			if [[ $SPLIT__option_with_zero_length == 'yes' || -n $SPLIT__window ]]; then
				eval "$SPLIT__option_reference+=(\"\${SPLIT__window}\")" || return
			fi
		elif [[ $SPLIT__last_slice_left_index -eq $SPLIT__string_last ]]; then
			# delimiter was the last character, so add a right-side slice, if zero-length is allowed
			if [[ $SPLIT__option_with_zero_length == 'yes' ]]; then
				eval "$SPLIT__option_reference+=('')" || return
			fi
		fi
	done
}

# join by the delimiter
# __join <delimiter> -- ...<element>
function __join {
	if [[ $# -lt 2 || $2 != '--' ]]; then
		return 1
	elif [[ $# -eq 2 ]]; then
		return 0
	fi
	local result='' i d="$1" a=("$@") l="$(($# - 1))"
	for ((i = 2; i < l; i++)); do
		result+="${a[i]}$d"
	done
	result+="${a[l]}"
	printf '%s' "$result" || return
}

# does the needle exist inside the array?
# has needle / is needle
# for strings, see __string_has_case_insensitive_substring
# __has {<array-var-name>} <needle>
# __has <needle> -- ...<element>
# @todo support index checks for bash associative arrays
# @todo support checking if an array has multiple needles with --any and --all support
function __has {
	if [[ $2 == '--' ]]; then
		# __has <needle> -- ...<element>
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
		# __has <array-var-name> <needle>
		# trunk-ignore(shellcheck/SC2034)
		local HAS__reference="$1" HAS__needle="$2" HAS__size HAS__index
		HAS__reference="$(__get_reference_name "$HAS__reference")" || return
		if [[ $HAS__reference == HAS__* ]]; then
			__print_lines "ERROR: ${FUNCNAME[0]}: A variable reference cannot be named $HAS__reference as it is used internally." >&2 || :
			return 22 # EINVAL 22 Invalid argument
		fi
		eval "HAS__size=\${#${HAS__reference}[@]}" || return
		for ((HAS__index = 0; HAS__index < HAS__size; ++HAS__index)); do
			if eval "[[ \$HAS__needle == \"\${${HAS__reference}[HAS__index]}\" ]]"; then
				return 0
			fi
		done
		return 1
	fi
}

# get the index of the needle
# __index {<array-var-name>} <needle>
# __index <needle> -- ...<element>
# doesn't print anything if index not found
# @todo support index checks for bash associative arrays and strings
function __index {
	if [[ $2 == '--' ]]; then
		# __has <needle> -- ...<element>
		local needle="$1" index=0
		shift # trim needle
		shift # trim --
		while [[ $# -ne 0 ]]; do
			local item="$1"
			shift # trim item
			if [[ $needle == "$item" ]]; then
				__print_lines "$index" || return
				return 0
			fi
			index="$((index + 1))"
		done
		return 0
	else
		# __has <array-var-name> <needle>
		# trunk-ignore(shellcheck/SC2034)
		local HAS__reference="$1" HAS__needle="$2" HAS__size HAS__index
		HAS__reference="$(__get_reference_name "$HAS__reference")" || return
		if [[ $HAS__reference == HAS__* ]]; then
			__print_lines "ERROR: ${FUNCNAME[0]}: A variable reference cannot be named $HAS__reference as it is used internally." >&2 || :
			return 22 # EINVAL 22 Invalid argument
		fi
		eval "HAS__size=\${#${HAS__reference}[@]}" || return
		for ((HAS__index = 0; HAS__index < HAS__size; ++HAS__index)); do
			if eval "[[ \$HAS__needle == \"\${${HAS__reference}[HAS__index]}\" ]]"; then
				__print_lines "$HAS__index" || return
			fi
		done
		return 0
	fi
}

# modify <array-var-name> to only the items between the <left> and <right> indices
# __slice <array-var-name> <left> [<right>] [<left> [<right>] ...]
# e.g. arr=(a b c d)
# __slice {arr} 0 1 # keeps a
# __slice {arr} 0 2 # keeps a b
# __slice {arr} 0 1 2 3 # keeps a c
# __slice {arr} 0 1 2 # keeps a c d
# @todo use [__is_array] to support strings as well as arrays
function __slice {
	local SLICE__item SLICE__option_append='' SLICE__option_inputs=() SLICE__option_indices=() SLICE__option_references=() SLICE__reference SLICE__eval_statement
	function __validate_reference {
		local reference="$1"
		if [[ $reference == SLICE__* ]]; then
			__print_lines "ERROR: ${FUNCNAME[0]}: A variable reference cannot be named $reference as it is used internally." >&2 || :
			return 22 # EINVAL 22 Invalid argument
		fi
	}
	while [[ $# -ne 0 ]]; do
		SLICE__item="$1"
		shift
		case "$SLICE__item" in
		'{'*'}')
			SLICE__reference="$(__get_reference_name "$SLICE__item")" || return
			__validate_reference "$SLICE__reference" || return
			SLICE__option_references+=("$SLICE__reference")
			;;
		'--append') SLICE__option_append='yes' ;;
		--)
			if [[ $# -eq 0 ]]; then
				# there's no items, be a no-op if not appending, if appending then reset to nothing
				if [[ $SLICE__option_append == 'no' ]]; then
					for SLICE__reference in "${SLICE__option_references[@]}"; do
						SLICE__eval_statement+="$SLICE__reference=(); "
					done
					eval "$SLICE__eval_statement" || return
				fi
				return 0
			fi
			SLICE__option_inputs+=("$@")
			shift $#
			break
			;;
		--*)
			__print_lines "ERROR: ${FUNCNAME[0]}: An unrecognised flag was provided: $SLICE__item" >&2 || :
			return 22 # EINVAL 22 Invalid argument
			;;
		*)
			if __is_integer "$SLICE__item"; then
				SLICE__option_indices+=("$SLICE__item")
			else
				__print_lines "ERROR: ${FUNCNAME[0]}: An unrecognised argument was provided: $SLICE__item" >&2 || :
				return 22 # EINVAL 22 Invalid argument
			fi
			;;
		esac
	done
	# there must always be at least one variable reference
	if [[ ${#SLICE__option_references[@]} -eq 0 ]]; then
		__print_lines "ERROR: ${FUNCNAME[0]}: A variable reference must be provided." >&2 || :
		return 22 # EINVAL 22 Invalid argument
	fi
	# if inputs, or if only a single target, then the first target remains a target
	# if no inputs, then the first array variable is the input
	if [[ ${#SLICE__option_inputs[@]} -eq 0 ]]; then
		SLICE__reference="${SLICE__option_references[0]}"
		eval "SLICE__option_inputs+=(\"\${${SLICE__reference}[@]}\")" || return
		if [[ ${#SLICE__option_references[@]} -ne 1 ]]; then
			# the first target is only an input, and not a target
			SLICE__option_references=("${SLICE__option_references[@]:1}")
		fi
	fi
	# if no indices, then do them all
	if [[ ${#SLICE__option_indices[@]} -eq 0 ]]; then
		SLICE__option_indices+=(0)
	fi
	# process indices
	local SLICE__left SLICE__right SLICE__length SLICE__size SLICE__negative_size SLICE__results=()
	SLICE__size="${#SLICE__option_inputs[@]}"
	SLICE__negative_size=$((SLICE__size * -1))
	# now that we have processed all our arguments, set the arguments to the indices
	set -- "${SLICE__option_indices[@]}"
	while [[ $# -ne 0 ]]; do
		SLICE__left="$1"
		shift
		if [[ $SLICE__left == '-0' ]]; then
			SLICE__left="$SLICE__size"
		elif [[ $SLICE__left -lt $SLICE__negative_size ]]; then
			# convert negative left to length, which is what bash uses
			SLICE__left=0
		fi
		# have right?
		if [[ $# -eq 0 ]]; then
			# no right, keep everything from left
			SLICE__results+=("${SLICE__option_inputs[@]:SLICE__left}")
		else
			# has right, keep everything from left to right
			# convert right to length, which is what bash uses
			SLICE__right="$1"
			shift
			if [[ $SLICE__right == '-0' ]]; then
				SLICE__right="$SLICE__size"
			fi
			SLICE__length="$((SLICE__right - SLICE__left))"
			SLICE__results+=("${SLICE__option_inputs[@]:SLICE__left:SLICE__length}")
		fi
	done
	# apply the results to the targets
	if [[ $SLICE__option_append == 'yes' ]]; then
		# append to the target
		for SLICE__reference in "${SLICE__option_references[@]}"; do
			SLICE__eval_statement+="$SLICE__reference+=(\"\${SLICE__results[@]}\"); "
		done
	else
		# replace the target with the SLICE__results
		for SLICE__reference in "${SLICE__option_references[@]}"; do
			SLICE__eval_statement+="$SLICE__reference=(\"\${SLICE__results[@]}\"); "
		done
	fi
	eval "$SLICE__eval_statement" || return
}

# push: add the last elements
# function __append { ... }
# just do: array+=("$@")

# unshift: add the first elements
# function __prepend { ... }
# just do: array=("$@" "${array[@]}")

# pop: remove the last elements
# function __remove_last { ... }

# shift: remove the first elements
# function __remove_first { ... }

# complement and intersect prototype also available at: https://gist.github.com/balupton/80d27cf1a9e193f8247ee4baa2ad8566
