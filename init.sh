#!/usr/bin/env sh

# under some environments
# only bashrc is loaded
# only bash_profile is loaded
# both bashrc and bash_profile is loaded
# as such, avoid double-loads
if test -z "${DOROTHY_INIT-}"; then
	export DOROTHY_INIT='y'

	if test -z "${DOROTHY-}"; then
		# https://stackoverflow.com/a/246128
		# https://stackoverflow.com/a/14728194
		export DOROTHY; DOROTHY="$(dirname "${BASH_SOURCE:-$0}")"
	fi

	. "$DOROTHY/sources/essentials.sh"
	. "$DOROTHY/sources/extras.sh"
fi
