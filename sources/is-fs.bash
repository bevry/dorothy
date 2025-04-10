#!/usr/bin/env bash
source "$DOROTHY/sources/bash.bash"

function is_fs_options {
	local elevate="${1-}"
	if [[ -n $elevate ]]; then
		cat <<-EOF
			--verbose | --no-quiet | --quiet=no
				If affirmative, output to STDERR the first path that failed and how it failed.

			--elevated=<elevated>
			--elevate=<elevate>
				Defaults to [$elevate] which will elevate privileges if necessary.
			--user=<user>
			--group=<group>
			--reason=<reason>
				Forwarded to [eval-helper].
		EOF
	else
		cat <<-EOF
			--verbose | --no-quiet | --quiet=no
				If affirmative, output to STDERR the first path that failed and how it failed.

			--elevated=<elevated>
			--elevate=<elevate>
			--user=<user>
			--group=<group>
			--reason=<reason>
				Forwarded to [eval-helper].
		EOF
	fi
}

# trunk-ignore(shellcheck/SC2168)
local item option_inputs=() option_quiet='' option_elevated='' option_elevate='' option_user='' option_group='' option_reason=''
function is_fs_args {
	while [[ $# -ne 0 ]]; do
		item="$1"
		shift
		case "$item" in
		'--help' | '-h') help ;;
		'--no-verbose'* | '--verbose'*)
			option_quiet="$(get-flag-value --non-affirmative --fallback="$option_quiet" -- "$item")"
			;;
		'--no-quiet'* | '--quiet'*)
			option_quiet="$(get-flag-value --affirmative --fallback="$option_quiet" -- "$item")"
			;;
		# <elevate>
		'--elevated='*) option_elevated="${item#*=}" ;;
		'--no-elevate'* | '--elevate'* | '--no-sudo'* | '--sudo'*)
			option_elevate+="$(get-flag-value --affirmative --fallback-on-empty --fallback="$option_elevate" -- "$item")"
			;;
		'--user='*) option_user="${item#*=}" ;;
		'--group='*) option_group="${item#*=}" ;;
		'--reason='*) option_reason="${item#*=}" ;;
		# </elevate>
		'--')
			option_inputs+=("$@")
			shift $#
			break
			;;
		'--'*) help "An unrecognised flag was provided: $item" ;;
		*) option_inputs+=("$item") ;;
		esac
	done

	# verify
	if [[ ${#option_inputs[@]} -eq 0 ]]; then
		help 'No <input>s provided.'
	fi
}

# trunk-ignore(shellcheck/SC2168)
local fs_status fs_failed_path
function is_fs_invoke {
	# execute once for all, capturing the failed path
	# failed paths are output to a fixed path because there is no simple way to separate the failed paths from other stdout and stderr output when using sudo in in-no tty mode, as sudo will be using stderr for its own output, and fs-owner.bash outputs to stdout
	# and passing an argument is ugly for the prompt, and doing it via an env var is also complicated for doas, and will also result in the same ugly prompt
	local command="$1" elevations="${2-}" failures="$XDG_CACHE_HOME/is-fs-failed-paths" # this is serial
	__print_line >"$failures"                                        # reset
	__try {fs_status} -- \
		eval-helper --inherit --elevated="$option_elevated" --elevate="$elevations $option_elevate" --user="$option_user" --group="$option_group" --reason="$option_reason" -- \
		"$command" -- "${option_inputs[@]}"
	if [[ -s $failures ]]; then
		fs_failed_path="$(<"$failures")" # at some point, properly support multiple failed paths rather than just the first
	else
		fs_failed_path=''
	fi
}

function is_fs_unknown_error {
	if [[ -z $fs_failed_path ]]; then
		echo-style --stderr --error1='Encountered the failure exit status of ' --code-error1="$fs_status" --error1=' when processing the paths:' --newline --code-error1="$(__print_lines "${option_inputs[@]}")"
	else
		echo-style --stderr --error1='The path ' --code-error1="$fs_failed_path" --error1=' encountered error ' --code-error1="$fs_status"
	fi
}
