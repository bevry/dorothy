#!/usr/bin/env sh

# todo
# if test \"\$(get-hostname)\" = '$(get-hostname)'; then

# for scripts to update the correct configuration file
# update_dorothy_user_config [--prefer=local] <filename> -- <--find=., replace>...
#
# if there are multiple config files, prompt the user which one to use
# if there are no configuration files, then use --prefer=... if available
# otherwise use standard
# when creating a config file, copy the default one
update_dorothy_user_config() {
	# --prefer=local
	dorothy_config_prefer_local='no'
	if test "$1" = '--prefer=local'; then
		dorothy_config_prefer_local='yes'
		shift
	fi

	# <filename>
	dorothy_config_filename="$1"
	shift

	# check for existing
	if test -f "$DOROTHY/user/config.local/$dorothy_config_filename"; then
		dorothy_config_filepath="$DOROTHY/user/config.local/$dorothy_config_filename"
	elif test -f "$DOROTHY/user/config/$dorothy_config_filename"; then
		dorothy_config_filepath="$DOROTHY/user/config/$dorothy_config_filename"
	else
		# neither exist, return a path to create
		if test "$dorothy_config_prefer_local" = 'yes'; then
			dorothy_config_filepath="$DOROTHY/user/config.local/$dorothy_config_filename"
		else
			dorothy_config_filepath="$DOROTHY/user/config/$dorothy_config_filename"
		fi
	fi

	# if it is missing, create it
	if test ! -f "$dorothy_config_filepath"; then
		if test -f "$DOROTHY/config/$dorothy_config_filename"; then
			# copy over the default
			cp "$DOROTHY/config/$dorothy_config_filename" "$dorothy_config_filepath"
		else
			# create one of the extension
			dorothy_config_extension="$(fs-extension "$dorothy_config_filepath")"
			if "$dorothy_config_extension" != "json"; then
				cat <<-EOF >"$dorothy_config_filepath"
					#!/usr/bin/env $dorothy_config_extension
					# shellcheck disable=SC2034
					# do not use \`export\` keyword in this file

				EOF
			else
				# unsupported extension, create empty file
				touch "$dorothy_config_filepath"
			fi
		fi
	fi

	# now that the file exists, update it if we have values to update it
	if test "${1-}" = '--'; then
		config-helper --file="$dorothy_config_filepath" "$@"
	fi
}

# for scripts to get the correct configuration file for logging
# [--prefer=local] <filename>
get_dorothy_user_config() {
	dorothy_config_prefer_local='no'
	if test "$1" = '--prefer=local'; then
		dorothy_config_prefer_local='yes'
		shift
	fi
	# check for existing
	if test -f "$DOROTHY/user/config.local/$1"; then
		echo "$DOROTHY/user/config.local/$1"
	elif test -f "$DOROTHY/user/config/$1"; then
		echo "$DOROTHY/user/config/$1"
	else
		# neither exist, return a path to create
		if test "$dorothy_config_prefer_local" = 'yes'; then
			echo "$DOROTHY/user/config.local/$1"
		else
			echo "$DOROTHY/user/config/$1"
		fi
	fi
}

# for scripts to know what configuration file was loaded
# <filename...>
get_dorothy_config() {
	# output each provided filename, that actualy exists at a configuration location
	for dorothy_config_filename in "$@"; do
		if test -f "$DOROTHY/user/config.local/$dorothy_config_filename"; then
			echo "$DOROTHY/user/config.local/$dorothy_config_filename"
		elif test -f "$DOROTHY/user/config/$dorothy_config_filename"; then
			echo "$DOROTHY/user/config/$dorothy_config_filename"
		elif test -f "$DOROTHY/config/$dorothy_config_filename"; then
			echo "$DOROTHY/config/$dorothy_config_filename"
		fi
	done
}

# for scripts to load a configuration file
# <filename...>
load_dorothy_config() {
	dorothy_config_filepaths="$(get_dorothy_config "$@")"
	if test -z "$dorothy_config_filepaths"; then
		# echo "Missing at least one of these configuration files: $*" >/dev/stderr
		return 2 # No such file or directory
	fi
	# fails in zsh: `for dorothy_config_filepath in $dorothy_config_filepaths; do``
	# fails in bash v3: `while ... do <()``
	# `<<<` is not POSIX compliant, but they work in: zsh, bash v3+
	# so when a Dorothy user reports a problem with smoething it doesn't work in, then figure something out
	# shellcheck disable=SC3011
	while IFS= read -r dorothy_config_filepath; do
		. "${dorothy_config_filepath}"
	done <<<"$dorothy_config_filepaths"
}
