#!/usr/bin/env sh

# for scripts to create and update the correct configuration file
get_dorothy_config() {
	if test -f "$DOROTHY/user/config.local/$1"; then
		echo "$DOROTHY/user/config.local/$1"
	else
		echo "$DOROTHY/user/config/$1"
	fi
}

# for scripts to know what configuration file was loaded
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
load_dorothy_config() {
	dorothy_config_filepaths="$(get_dorothy_config "$@")"
	if test -z "$dorothy_config_filepaths"; then
		echo "Missing at least one of these configuration files: $*" >/dev/stderr
		return 2 # No such file or directory
	fi
	# doesn't support spaces in paths, but that's ok
	# alternative would be bash v4: while ... do <()
	# or bash v4: mapfile
	# but neither are cross compat
	for dorothy_config_filepath in $dorothy_config_filepaths; do
		. "$dorothy_config_filepath"
	done
}
