#!/usr/bin/env sh

# for scripts and sources to load a configuration file
# <filename...>
load_dorothy_config() {
	dorothy_config_loaded='no'

	# if always load default, load the defaults
	dorothy_config_defaults_loaded='no'
	if test "$1" = '--defaults=always'; then
		dorothy_config_defaults_loaded='yes'
		shift
		for dorothy_config_filename in "$@"; do
			if test -f "$DOROTHY/config/$dorothy_config_filename"; then
				. "$DOROTHY/config/$dorothy_config_filename"
				dorothy_config_loaded='yes'
			fi
		done
	elif test "$1" = '--defaults=fallback'; then
		shift
	fi
	# ^ @todo, does this actually make sense?
	# shouldn't it be done via `update_dorothy_user_config --source-default`
	# instead? such that the user config file sources the default file?
	# that way, things like shell.* behave like hosts.bash
	# this is definitely a better approach, will do it tomorrow

	# for each filename, load a single config file
	for dorothy_config_filename in "$@"; do
		if test -f "$DOROTHY/user/config.local/$dorothy_config_filename"; then
			# load user/config.local/*
			. "$DOROTHY/user/config.local/$dorothy_config_filename"
			dorothy_config_loaded='yes'
		elif test -f "$DOROTHY/user/config/$dorothy_config_filename"; then
			# otherwise load user/config/*
			. "$DOROTHY/user/config/$dorothy_config_filename"
			dorothy_config_loaded='yes'
		elif test -f "$DOROTHY/config/$dorothy_config_filename"; then
			# otherwise load default configuration if we haven't already
			if test "$dorothy_config_defaults_loaded" = 'no'; then
				. "$DOROTHY/config/$dorothy_config_filename"
				dorothy_config_loaded='yes'
			fi
		fi
	done

	# if nothing was loaded, then fail
	if test "$dorothy_config_loaded" = 'no'; then
		echo-style --error="Missing the configuration file: $*" >/dev/stderr
		return 2 # No such file or directory
	fi
}
