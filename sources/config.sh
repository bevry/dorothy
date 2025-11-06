#!/usr/bin/env sh

# for scripts and sources to load a configuration file
# load_dorothy_config [--first] [--silent] [--] ...<filename>
load_dorothy_config() {
	# process arguments
	load_dorothy_config__only_first='no' load_dorothy_config__optional='no'
	while [ "$#" -ne 0 ]; do
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
		if [ -f "$DOROTHY/user/config.local/$load_dorothy_config__filename" ]; then
			# load user/config.local/*
			. "$DOROTHY/user/config.local/$load_dorothy_config__filename"
			load_dorothy_config__loaded='yes'
		elif [ -f "$DOROTHY/user/config/$load_dorothy_config__filename" ]; then
			# load user/config/*
			. "$DOROTHY/user/config/$load_dorothy_config__filename"
			load_dorothy_config__loaded='yes'
		fi
		if [ "$load_dorothy_config__only_first" = 'yes' ] && [ "$load_dorothy_config__loaded" = 'yes' ]; then
			break
		fi
	done
	# if no user-defined configuration was provided, try the same filenames, but in the default configuration
	if [ "$load_dorothy_config__loaded" = 'no' ]; then
		for load_dorothy_config__filename in "$@"; do
			if [ -f "$DOROTHY/config/$load_dorothy_config__filename" ]; then
				# load default configuration
				. "$DOROTHY/config/$load_dorothy_config__filename"
				load_dorothy_config__loaded='yes'
			fi
			if [ "$load_dorothy_config__only_first" = 'yes' ] && [ "$load_dorothy_config__loaded" = 'yes' ]; then
				break
			fi
		done
	fi

	# if nothing was loaded, then fail
	if [ "$load_dorothy_config__loaded" = 'no' ]; then
		if [ "$load_dorothy_config__optional" = 'no' ]; then
			echo-style --stderr --error="Missing the configuration file: $*"
			return 2 # ENOENT 2 No such file or directory
		fi
	fi
	return 0
}
