#!/usr/bin/env bash
source "$DOROTHY/sources/bash.bash"

function __is_fs__options {
	local item option_elevate='' option_echo='' elevate_description='' echo_description=''
	while [[ $# -ne 0 ]]; do
		item="$1"
		shift
		case "$item" in
		'--no-echo'* | '--echo'*) __flag --source={item} --target={option_echo} --affirmative --coerce || return $? ;;
		'--elevate'*) __flag --source={item} --target={option_elevate} --affirmative --no-coerce || return $? ;;
		'--'*) __unrecognised_flag "$item" || return $? ;;
		*) __unrecognised_argument "$item" || return $? ;;
		esac
	done
	if [[ -n $option_elevate ]]; then
		elevate_description=$'\n'"    Defaults to \`$option_elevate\` which will elevate privileges if necessary."
	fi
	if [[ $option_echo != 'no' ]]; then
		echo_description=$'\n--[no-]echo\n    If <echo>, output to STDOUT any <path> that was successful.'
	fi
	cat <<-EOF || return $?
		...<path> | --path=...<path> | --- ...<path>
		    The <path>s to perform the operation on.
		    ! \`--path=~\` will not interpolate the tilde as \`\$HOME\`. Use \`[--] ...<path>\` for tilde-as-home interpolation. This is a shell convention, not a Dorothy convention.

		--first
		    If enabled, stop on the first successful <path>.
		        ! Cannot be used with <all>.
		--<optional|none> | --any | --<all|required> | --<need|require>=<need:<optional|none>|any|<all|required>>
		    If <optional>, do not require any <path>s to be successful.
		        ! Empty <path>s and no <path>s will still report [22] failure.
		    If <any>, the default if <first>, require at least one <app> to be successful. Unless <first> is specified, continue to output details for all if not <quiet>.
		    If <all>, the default if not <first>, require all <app>s to be successful.
		    ! Exit statuses of [13] and [22] will always be reported, irrespective of <need>.

		--[no-]verbose | --[no-]quiet
		    If <verbose>, output to STDERR any <path> that failed and how it failed.$echo_description

		--elevated=<elevated>
		--elevate=<elevate>$elevate_description
		--user=<user>
		--group=<group>
		--reason=<reason>
		    Forwarded to \`eval-helper\`.
	EOF
}

# trunk-ignore(shellcheck/SC2168)
local option_inputs=() option_echo='' option_first='' option_need='' option_quiet='' option_elevated='' option_elevate='' option_user='' option_group='' option_reason=''
function __is_fs__args {
	local item
	while [[ $# -ne 0 ]]; do
		item="$1"
		shift
		case "$item" in
		'--help' | '-h') __help || return $? ;;
		'--no-verbose'* | '--verbose'*) __flag --source={item} --target={option_quiet} --non-affirmative --coerce || return $? ;;
		'--no-quiet'* | '--quiet'*) __flag --source={item} --target={option_quiet} --affirmative --coerce || return $? ;;
		'--no-echo'* | '--echo'*) __flag --source={item} --target={option_echo} --affirmative --coerce || return $? ;;
		'--no-first'* | '--first'*) __flag --source={item} --target={option_first} --affirmative --coerce || return $? ;;
		'--none' | '--need=none' | '--require=none' | '--optional' | '--need=optional' | '--require=optional') option_need='none' ;;
		'--any' | '--need=any' | '--require=any') option_need='any' ;;
		'--all' | '--need=all' | '--require=all' | '--required' | '--need=required' | '--require=required') option_need='all' ;;
		'--need=') : ;;
		# <elevate>
		'--elevated='*) option_elevated="${item#*=}" ;;
		'--no-elevate'* | '--elevate'* | '--no-sudo'* | '--sudo'*) __flag --source={item} --target={option_elevate} --affirmative --no-coerce || return $? ;;
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
local -i fs_status=0
# trunk-ignore(shellcheck/SC2168)
local fs_failures="$TMPDIR/is-fs--failures--$RANDOM"
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
		'--')
			command_args+=("$@")
			shift $#
			;;
		*) __unrecognised_argument "$item" || return $? ;;
		esac
	done
	: >"$fs_failures" || return $? # touch/reset failures here, so we have access to it; if we leave it up to to the operation to create, then it could be created with elevated permissions, in which we won't be able to access it
	command+=("--failures=$fs_failures" "--echo=$option_echo" "--first=$option_first" "--need=$option_need")
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
	# adjust the exit status
	if [[ $option_need == 'none' && $fs_status -ne 0 && $fs_status -ne 13 && $fs_status -ne 22 ]]; then
		fs_status=0
	fi
}

# This only outputs the appropriate error message, and return status is based on whether that output of the error message (if applicable) was successful
# You still need to finish your script with `return "$fs_status"` to return the appropriate status
function __is_fs__error {
	# trunk-ignore(shellcheck/SC2034)
	local -i path_status arg_status
	local path args=("$@") arg message
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
			# if not verbose, and not invalid argument, then skip
			if [[ $path_status -ne 22 && $option_quiet != 'no' ]]; then
				continue
			fi
			# if it wasn't a custom code and message, then use a default message
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
