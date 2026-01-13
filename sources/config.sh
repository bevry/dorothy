#!/usr/bin/env sh

# for scripts and sources to load a configuration file
# load_dorothy_config [--first] [--silent] [--] ...<filename>
load_dorothy_config() {
	# process arguments
	LOAD_DOROTHY_CONFIG__only_first='no' LOAD_DOROTHY_CONFIG__optional='no'
	while [ "$#" -ne 0 ]; do
		case "$1" in
		'--first')
			shift
			# stop after the first found <filename> argument
			LOAD_DOROTHY_CONFIG__only_first='yes'
			;;
		'--optional')
			shift
			LOAD_DOROTHY_CONFIG__optional='yes'
			;;
		'--')
			shift
			break
			;;
		*) break ;;
		esac
	done

	# load the configuration
	LOAD_DOROTHY_CONFIG__loaded='no'
	# for each filename, try user/config.local otherwise user/config
	for LOAD_DOROTHY_CONFIG__filename in "$@"; do
		if [ -f "$DOROTHY/user/config.local/$LOAD_DOROTHY_CONFIG__filename" ]; then
			# load user/config.local/*
			. "$DOROTHY/user/config.local/$LOAD_DOROTHY_CONFIG__filename"
			LOAD_DOROTHY_CONFIG__loaded='yes'
		elif [ -f "$DOROTHY/user/config/$LOAD_DOROTHY_CONFIG__filename" ]; then
			# load user/config/*
			. "$DOROTHY/user/config/$LOAD_DOROTHY_CONFIG__filename"
			LOAD_DOROTHY_CONFIG__loaded='yes'
		fi
		if [ "$LOAD_DOROTHY_CONFIG__only_first" = 'yes' ] && [ "$LOAD_DOROTHY_CONFIG__loaded" = 'yes' ]; then
			break
		fi
	done
	# if no user-defined configuration was provided, try the same filenames, but in the default configuration
	if [ "$LOAD_DOROTHY_CONFIG__loaded" = 'no' ]; then
		for LOAD_DOROTHY_CONFIG__filename in "$@"; do
			if [ -f "$DOROTHY/config/$LOAD_DOROTHY_CONFIG__filename" ]; then
				# load default configuration
				. "$DOROTHY/config/$LOAD_DOROTHY_CONFIG__filename"
				LOAD_DOROTHY_CONFIG__loaded='yes'
			fi
			if [ "$LOAD_DOROTHY_CONFIG__only_first" = 'yes' ] && [ "$LOAD_DOROTHY_CONFIG__loaded" = 'yes' ]; then
				break
			fi
		done
	fi

	# if nothing was loaded, then fail
	if [ "$LOAD_DOROTHY_CONFIG__loaded" = 'no' ]; then
		if [ "$LOAD_DOROTHY_CONFIG__optional" = 'no' ]; then
			echo-style --stderr --error="Missing the configuration file: $*"
			return 2 # ENOENT 2 No such file or directory
		fi
	fi
	return 0
}
