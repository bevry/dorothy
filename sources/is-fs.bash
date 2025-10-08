#!/usr/bin/env bash
source "$DOROTHY/sources/bash.bash"

function __is_fs__options {
	local elevate="${1-}"
	if [[ -n $elevate ]]; then
		cat <<-EOF || return
			--verbose | --no-quiet | --quiet=no
			    If affirmative, output to STDERR the first <path> that failed and how it failed.

			--elevated=<elevated>
			--elevate=<elevate>
			    Defaults to \`$elevate\` which will elevate privileges if necessary.
			--user=<user>
			--group=<group>
			--reason=<reason>
			    Forwarded to \`eval-helper\`.
		EOF
	else
		cat <<-EOF || return
			--verbose | --no-quiet | --quiet=no
			    If affirmative, output to STDERR the first <path> that failed and how it failed.

			--elevated=<elevated>
			--elevate=<elevate>
			--user=<user>
			--group=<group>
			--reason=<reason>
			    Forwarded to \`eval-helper\`.
		EOF
	fi
}

# trunk-ignore(shellcheck/SC2034)
# trunk-ignore(shellcheck/SC2168)
local item option_inputs=() option_quiet='' option_elevated='' option_elevate='' option_user='' option_group='' option_reason=''
function __is_fs__args {
	while [[ $# -ne 0 ]]; do
		item="$1"
		shift
		case "$item" in
		'--help' | '-h') __help || return ;;
		'--no-verbose'* | '--verbose'*) __flag --source={item} --target={option_quiet} --non-affirmative || return ;;
		'--no-quiet'* | '--quiet'*) __flag --source={item} --target={option_quiet} --affirmative || return ;;
		# <elevate>
		'--elevated='*) option_elevated="${item#*=}" ;;
		'--no-elevate'* | '--elevate'* | '--no-sudo'* | '--sudo'*) __flag --source={item} --target={option_elevate} --affirmative || return ;;
		'--user='*) option_user="${item#*=}" ;;
		'--group='*) option_group="${item#*=}" ;;
		'--reason='*) option_reason="${item#*=}" ;;
		# </elevate>
		'--')
			option_inputs+=("$@")
			shift $#
			break
			;;
		'--'*) __help 'An unrecognised flag was provided: ' --variable-value={item} || return ;;
		*) option_inputs+=("$item") ;;
		esac
	done

	# verify
	if [[ ${#option_inputs[@]} -eq 0 ]]; then
		__help 'No <input>s provided.' || return
	fi
}

# trunk-ignore(shellcheck/SC2168)
local fs_status fs_failed_path
function __is_fs__invoke {
	# execute once for all, capturing the failed path
	# failed paths are output to a fixed path because there is no simple way to separate the failed paths from other stdout and stderr output when using sudo in in-no tty mode, as sudo will be using stderr for its own output, and fs-owner.bash outputs to stdout
	# and passing an argument is ugly for the prompt, and doing it via an env var is also complicated for doas, and will also result in the same ugly prompt
	local item command=() command_args=() do_args=() elevate='' failures="$XDG_CACHE_HOME/is-fs-failed-paths" # this is serial
	while [[ $# -ne 0 ]]; do
		item="$1"
		shift
		case "$item" in
		'--command='*) command+=("${item#*=}") ;;
		'--elevate='*) elevate="${item#*=}" ;;
		'--discard-'* | '--copy-'* | '--redirect-'*) do_args+=("$item") ;;
		--)
			command_args+=("$@")
			shift $#
			;;
		*)
			if [[ ${#command[@]} -eq 0 ]]; then
				command+=("$item")
			elif [[ -z $elevate ]]; then
				elevate="$item"
			else
				__unrecognised_argument "$item" || return
			fi
			;;
		esac
	done
	if [[ ${#command_args[@]} -eq 0 ]]; then
		command+=(-- "${option_inputs[@]}")
	else
		command+=("${command_args[@]}")
	fi
	# reset failures
	: >"$failures" || return
	# execute the command
	__do --redirect-status={fs_status} "${do_args[@]}" -- \
		eval-helper --inherit --elevated="$option_elevated" --elevate="$elevate $option_elevate" --user="$option_user" --group="$option_group" --reason="$option_reason" -- \
		"${command[@]}" || return
	# check for new failures
	if [[ -s $failures ]]; then
		fs_failed_path="$(<"$failures")" || return # at some point, properly support multiple failed paths rather than just the first
	else
		fs_failed_path=''
	fi
}

# This only outputs the appropriate error message, and return status is based on whether that output of the error message (if applicable) was successful
# You still need to finish your script with `return "$fs_status"` to return the appropriate status
function __is_fs__error {
	local error="${1:-"$fs_status"}" label='path' was_were='was' spacer=' ' paths="$fs_failed_path"
	# skip contextual failure unless verbose AND failure
	if [[ $option_quiet != 'no' || $error == 0 ]]; then
		return 0
	fi
	# format paths
	if [[ -z $paths ]]; then
		paths="$(__print_lines "${option_inputs[@]}")" || return
	fi
	# pluralise
	if [[ $paths == *$'\n'* ]]; then
		label='paths'
		was_were='were'
		spacer=$'\n'
	fi
	# output
	case "$error" in
	# ENOENT 2 No such file or directory
	2) __print_style --stderr --error1="The $label $was_were missing:" --="$spacer" --path="$paths" || return ;;
	# EBADF 9 Bad file descriptor
	9) __print_style --stderr --error1="The $label $was_were a broken symlink:" --="$spacer" --path="$paths" || return ;;
	# EACCES 13 Permission denied
	13) __print_style --stderr --error1="The $label $was_were not accessible:" --="$spacer" --path="$paths" || return ;;
	# NOTDIR 20 Not a directory
	20) __print_style --stderr --error1="The $label $was_were present, but $was_were not a directory nor an unbroken symlink to directory:" --="$spacer" --path="$paths" || return ;;
	# EISDIR 21 Is a directory
	21) __print_style --stderr --error1="The $label $was_were a directory, or an unbroken symlink to a directory:" --="$spacer" --path="$paths" || return ;;
	# EINVAL 22 Invalid argument
	22) __print_style --stderr --error1="The $label $was_were not a valid argument:" --="$spacer" --path="$paths" || return ;;
	# EFBIG 27 File too large
	27) __print_style --stderr --error1="The $label $was_were a file, or an unbroken symlink to a file, but $was_were not empty:" --="$spacer" --path="$paths" || return ;;
	# ENOTEMPTY 66 Directory not empty
	66) __print_style --stderr --error1="The $label $was_were a directory, or an unbroken symlink to a directory, but $was_were not empty:" --="$spacer" --path="$paths" || return ;;
	# Custom <exit-status>
	[0-9]+) __print_style --stderr --error1='Encountered the failure exit status of ' --code-error1="$error" --error1=" when processing the $label:" --="$spacer" --path="$paths" || return ;;
	# Custom <error>
	*)
		# pluralise error message
		error="${error//"<path>"/"$label"}"
		error="${error//"was"/"$was_were"}"
		if [[ $error != *: ]]; then
			error="$error:"
		fi
		# output
		__print_style --stderr --error1="$error" --="$spacer" --path="$paths" || return
		;;
	esac
}
