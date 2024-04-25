#!/usr/bin/env sh

# for scripts and sources to load a configuration file
# load_dorothy_config [--first] [--silent] [--] ...<filename>
load_dorothy_config() {
	# process arguments
	load_dorothy_config__only_first='no' load_dorothy_config__optional='no'
	while test "$#" -ne 0; do
		case "$1" in
		'--first')
			shift
			load_dorothy_config__only_first='yes'
			;;
		'--optional')
			shift
			load_dorothy_config__optional='yes'
			;;
		'--')
			shift
			break
			;;
		*) break ;;
		esac
	done

	# load the configuration
	load_dorothy_config__loaded='no'
	# for each filename, try user/config.local otherwise user/config
	for load_dorothy_config__filename in "$@"; do
		if test -f "$DOROTHY/user/config.local/$load_dorothy_config__filename"; then
			# load user/config.local/*
			. "$DOROTHY/user/config.local/$load_dorothy_config__filename"
			load_dorothy_config__loaded='yes'
		elif test -f "$DOROTHY/user/config/$load_dorothy_config__filename"; then
			# load user/config/*
			. "$DOROTHY/user/config/$load_dorothy_config__filename"
			load_dorothy_config__loaded='yes'
		fi
		if test "$load_dorothy_config__only_first" = 'yes' -a "$load_dorothy_config__loaded" = 'yes'; then
			break
		fi
	done
	# if no user-defined configuration was provided, try the same filenames, but in the default configuration
	if test "$load_dorothy_config__loaded" = 'no'; then
		for load_dorothy_config__filename in "$@"; do
			if test -f "$DOROTHY/config/$load_dorothy_config__filename"; then
				# load default configuration
				. "$DOROTHY/config/$load_dorothy_config__filename"
				load_dorothy_config__loaded='yes'
			fi
			if test "$load_dorothy_config__only_first" = 'yes' -a "$load_dorothy_config__loaded" = 'yes'; then
				break
			fi
		done
	fi

	# if nothing was loaded, then fail
	if test "$load_dorothy_config__loaded" = 'no'; then
		if test "$load_dorothy_config__optional" = 'no'; then
			echo-style --error="Missing the configuration file: $*" >/dev/stderr
			return 2 # ENOENT 2 No such file or directory
		fi
	fi
	return 0
}
