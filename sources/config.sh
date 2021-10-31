#!/usr/bin/env sh

# for scripts that configure the configuration file
get_dorothy_local_config () {
	echo "$DOROTHY/user/config.local/$1"
}
get_dorothy_user_config () {
	echo "$DOROTHY/user/config/$1"
}
get_dorothy_config () {
	if test -f "$DOROTHY/user/config.local/$1"; then
		echo "$DOROTHY/user/config.local/$1"
	else
		echo "$DOROTHY/user/config/$1"
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
	loaded_at_least_one_filename='no'
	last_filename=''

	# load each provided filename
	for filename in "$@"; do
		# skip in the non-fish shell case, where the arguments may be:
		# shell.sh shell.sh
		if test "$filename" = "$last_filename"; then
			continue
		fi
		last_filename="$filename"

		# check config files
		if test -f "$DOROTHY/user/config.local/$filename"; then
			# load user/config.local
			. "$DOROTHY/user/config.local/$filename"
			loaded_at_least_one_filename='yes'
		elif test -f "$DOROTHY/user/config/$filename"; then
			# otherwise load user/config
			. "$DOROTHY/user/config/$filename"
			loaded_at_least_one_filename='yes'
		elif test -f "$DOROTHY/config/$filename"; then
			# otherwise load default
			. "$DOROTHY/config/$filename"
			loaded_at_least_one_filename='yes'
		fi
		# otherwise try next filename
	done

	# if no filename was loaded, then fail and report
	if test "$loaded_at_least_one_filename" = 'no'; then
		echo "configuration file $filename was not able to be found" >&2  # stderr
		return 2  # No such file or directory
	fi
}
