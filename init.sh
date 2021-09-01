#!/usr/bin/env sh

# sometimes bash_profile and bashrc are loaded on new terminals
# sometimes bash_profile is loaded at login, and bashrc is loaded on new terminals
# sometimes bash_profile will remember and export variables, but not functions
# as such, expose a function and check if it is loaded, to prevent the case where both bash_profile and bashrc are doing the same thing
# https://stackoverflow.com/a/14467452
if [ "$(command -v "${is_dorothy_loaded-}")x" = "x" ]; then
	is_dorothy_loaded () {
		echo 'y'
	}

	if test -z "${DOROTHY-}"; then
		# https://stackoverflow.com/a/246128
		# https://stackoverflow.com/a/14728194
		export DOROTHY
		# shellcheck disable=SC3028
		DOROTHY="$(dirname "${BASH_SOURCE:-"$0"}")"
	fi

	. "$DOROTHY/sources/essentials.sh"
	. "$DOROTHY/sources/extras.sh"
fi
