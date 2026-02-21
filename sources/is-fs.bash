#!/usr/bin/env bash
source "$DOROTHY/sources/bash.bash"

function __is_fs__options {
	local elevate="${1-}" elevate_description=''
	if [[ -n $elevate ]]; then
		elevate_description=$'\n'"    Defaults to \`$elevate\` which will elevate privileges if necessary."
	fi
	# If <optional>, do not require any <path>s to be successful.
	cat <<-EOF || return $?
		...<path> | --path=...<path> | --- ...<path>
			The <path>s to perform the operation on.
			! \`--path=~\` will not interpolate the tilde as \`\$HOME\`. Use \`[--] ...<path>\` for tilde-as-home interpolation. This is a shell convention, not a Dorothy convention.

		--first
		    If enabled, stop on the first successful <path>. Cannot be used with <all>.
		--optional | --any | --all | --need=<need:optional|any|all>
		    If <any>, the default if <first>, require at least one <app> to be successful. Unless <first> is specified, continue to output details for all if not <quiet>.
		    If <all>, the default if not <first>, require all <app>s to be successful.
		    ! If an invalid or <inaccessible <path> is encountered, it will disregard <need>, however, <first> is still respected.

		--[no-]verbose | --[no-]quiet
			If <verbose>, output to STDERR the <path> failure and how it failed.

		--elevated=<elevated>
		--elevate=<elevate>$elevate_description
		--user=<user>
		--group=<group>
		--reason=<reason>
			Forwarded to \`eval-helper\`.
	EOF
}

# trunk-ignore(shellcheck/SC2168)
local item option_inputs=() option_first='' option_need='' option_quiet='' option_elevated='' option_elevate='' option_user='' option_group='' option_reason=''
function __is_fs__args {
	while [[ $# -ne 0 ]]; do
		item="$1"
		shift
		case "$item" in
		'--help' | '-h') __help || return $? ;;
		'--no-verbose'* | '--verbose'*) __flag --source={item} --target={option_quiet} --non-affirmative || return $? ;;
		'--no-quiet'* | '--quiet'*) __flag --source={item} --target={option_quiet} --affirmative || return $? ;;
		'--no-first'* | '--first'*) __flag --source={item} --target={option_first} --affirmative || return $? ;;
		# '--optional' | '--need=optional') option_need='optional' ;;
		'--any' | '--need=any') option_need='any' ;;
		'--all' | '--need=all') option_need='all' ;;
		'--need=') : ;;
		# <elevate>
		'--elevated='*) option_elevated="${item#*=}" ;;
		'--no-elevate'* | '--elevate'* | '--no-sudo'* | '--sudo'*) __flag --source={item} --target={option_elevate} --affirmative || return $? ;;
		'--user='*) option_user="${item#*=}" ;;
		'--group='*) option_group="${item#*=}" ;;
		'--reason='*) option_reason="${item#*=}" ;;
		# </elevate>
		'--path='*) option_inputs+=("${item#*=}") ;;
		'--')
			option_inputs+=("$@")
			shift $#
			break
			;;
		'--'*) __help 'An unrecognised flag was provided: ' --variable-value={item} || return $? ;;
		*) option_inputs+=("$item") ;;
		esac
	done

	# verify
	if [[ ${#option_inputs[@]} -eq 0 ]]; then
		__help --help='No <input>s provided.' || return $?
	fi
	if [[ $option_need == 'all' && $option_first == 'yes' ]]; then
		__help --help="Cannot use <all> with <first> as that doesn't make sense, it would just return whatever the first result is, success or failure, which if you want that, then just do that." || return $?
	fi
}

# trunk-ignore(shellcheck/SC2168)
local fs_status fs_failures="$TMPDIR/is-fs--failures--$RANDOM"
function __is_fs__invoke {
	# execute once for all, capturing the failed path
	# failed paths are output to a fixed path because there is no simple way to separate the failed paths from other stdout and stderr output when using sudo in in-no tty mode, as sudo will be using stderr for its own output, and fs-owner.bash outputs to stdout
	# and passing an argument is ugly for the prompt, and doing it via an env var is also complicated for doas, and will also result in the same ugly prompt
	local item command=() command_args=() do_args=() elevate=''
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
				__unrecognised_argument "$item" || return $?
			fi
			;;
		esac
	done
	: >"$fs_failures" || return $? # touch/reset failures here, so we have access to it; if we leave it up to to the operation to create, then it could be created with elevated permissions, in which we won't be able to access it
	command+=("--failures=$fs_failures")
	if [[ -n $option_first ]]; then
		command+=("--first=$option_first")
	fi
	if [[ -n $option_need ]]; then
		command+=("--need=$option_need")
	fi
	if [[ ${#command_args[@]} -eq 0 ]]; then
		command+=(-- "${option_inputs[@]}")
	else
		# custom invocation
		command+=("${command_args[@]}")
	fi
	# execute the command
	__do --redirect-status={fs_status} "${do_args[@]}" -- \
		eval-helper --inherit --elevated="$option_elevated" --elevate="$elevate $option_elevate" --user="$option_user" --group="$option_group" --reason="$option_reason" -- \
		"${command[@]}" || return $?
}

# This only outputs the appropriate error message, and return status is based on whether that output of the error message (if applicable) was successful
# You still need to finish your script with `return "$fs_status"` to return the appropriate status
function __is_fs__error {
	# if optional, adjust the exit status <-- however, optional doesn't make any sense in this context
	# if [[ $option_need == 'optional' && $fs_status -ne 0 && $fs_status -ne 13 && $fs_status -ne 22 ]]; then
	# 	fs_status=0
	# fi

	# skip contextual failure unless verbose AND failure
	if [[ $option_quiet != 'no' || $fs_status -eq 0 ]]; then
		return 0
	fi

	# trunk-ignore(shellcheck/SC2034)
	local path_status path args=("$@") arg arg_status message
	if [[ -s $fs_failures ]]; then
		# trunk-ignore(shellcheck/SC2034)
		while IFS=$'\t' read -rd $'\n' path_status path; do
			message=''
			for arg in "${args[@]}"; do
				arg_status="${arg%%=*}"
				if [[ $arg_status == "$path_status" ]]; then
					message="${arg#*=}"
					break
				fi
			done
			if [[ -z $message ]]; then
				case "$path_status" in
				# ENOENT 2 No such file or directory
				2) message="The <path> was missing:" ;;
				# EBADF 9 Bad file descriptor
				9) message="The <path> was a broken symlink:" ;;
				# EACCES 13 Permission denied
				13) message="The <path> was not accessible:" ;;
				# NOTDIR 20 Not a directory
				20) message="The <path> was present, but was not a directory nor an unbroken symlink to directory:" ;;
				# EISDIR 21 Is a directory
				21) message="The <path> was a directory, or an unbroken symlink to a directory:" ;;
				# EINVAL 22 Invalid argument
				22) message="The <path> was not a valid argument:" ;;
				# EFBIG 27 File too large
				27) message="The <path> was a file, or an unbroken symlink to a file, but was not empty:" ;;
				# ENOTEMPTY 66 Directory not empty
				66) message="The <path> was a directory, or an unbroken symlink to a directory, but was not empty:" ;;
				# Custom <exit-status>
				[0-9]+) message="Encountered the failure exit status of [$path_status] when processing the <path>:" ;;
				# Other
				*) exit 14 ;; # EFAULT 14 Bad address
				esac
			fi
			__print_error --help="$message" --=' ' --variable-value+path={path} || return $?
		done <"$fs_failures"
	elif [[ $fs_status -ne 0 ]]; then
		# trunk-ignore(shellcheck/SC2034)
		local paths
		message="Encountered the failure exit status of [$fs_status] when processing the <path>s:"
		__print_error --help="$message" --newline --variable-value={option_inputs} || return $?
	fi
}
