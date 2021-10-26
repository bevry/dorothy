#!/usr/bin/env sh

# for scripts that configure the configuration file
get_dorothy_local_config () {
	echo "$DOROTHY_USER_HOME/config.local/$1"
}
get_dorothy_user_config () {
	echo "$DOROTHY_USER_HOME/config/$1"
}
get_dorothy_config () {
	if test -f "$DOROTHY_USER_HOME/config.local/$1"; then
		echo "$DOROTHY_USER_HOME/config.local/$1"
	else
		echo "$DOROTHY_USER_HOME/config/$1"
	fi
}
get_dorothy_default_config () {
	echo "$DOROTHY/config/$1"
}

# for scripts that load the configuration file

# zsh
# user/config.local/shell.sh
# user/config/shell.zsh

load_dorothy_config () {
	found='no'

	# load user/config.local
	for filename in "$@"; do
		if test -f "$DOROTHY_USER_HOME/config.local/$filename"; then
			. "$DOROTHY_USER_HOME/config.local/$filename"
			found='yes'
		fi
	done

	# load user/config
	for filename in "$@"; do
		if test -f "$DOROTHY_USER_HOME/config/$filename"; then
			. "$DOROTHY_USER_HOME/config/$filename"
			found='yes'
		fi
	done

	# load default if no user config was found
	if test "$found" = 'no'; then
		for filename in "$@"; do
			if test -f "$DOROTHY_USER_HOME/config/$filename"; then
				. "$DOROTHY/config/$filename"
			fi
		done
	fi
}
