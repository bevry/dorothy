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
load_dorothy_config () {
	if test -f "$DOROTHY_USER_HOME/config.local/$1"; then
		# source user local configuration
		. "$DOROTHY_USER_HOME/config.local/$1"
	elif test -f "$DOROTHY_USER_HOME/config/$1"; then
		# source user standard configuration
		. "$DOROTHY_USER_HOME/config/$1"
	else
		# source default configuration
		. "$DOROTHY/config/$1"
	fi
}
