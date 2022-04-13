#!/usr/bin/env sh

# for scripts and sources to load a configuration file
# load_dorothy_config <filename>...
load_dorothy_config() {
	dorothy_config_loaded='no'

	# for each filename, load a single config file
	for dorothy_config_filename in "$@"; do
		if test -f "$DOROTHY/user/config.local/$dorothy_config_filename"; then
			# load user/config.local/*
			# trunk-ignore(shellcheck/SC1090)
			. "$DOROTHY/user/config.local/$dorothy_config_filename"
			dorothy_config_loaded='yes'
		elif test -f "$DOROTHY/user/config/$dorothy_config_filename"; then
			# otherwise load user/config/*
			# trunk-ignore(shellcheck/SC1090)
			. "$DOROTHY/user/config/$dorothy_config_filename"
			dorothy_config_loaded='yes'
		elif test -f "$DOROTHY/config/$dorothy_config_filename"; then
			# otherwise load default configuration
			# trunk-ignore(shellcheck/SC1090)
			. "$DOROTHY/config/$dorothy_config_filename"
			dorothy_config_loaded='yes'
		fi
	done

	# if nothing was loaded, then fail
	if test "$dorothy_config_loaded" = 'no'; then
		echo-style --error="Missing the configuration file: $*" >/dev/stderr
		return 2 # No such file or directory
	fi
}
