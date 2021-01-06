#!/usr/bin/env sh

if test -z "${DOROTHY-}"; then
	# https://stackoverflow.com/a/246128
	# https://stackoverflow.com/a/14728194
	export DOROTHY; DOROTHY="$(dirname "${BASH_SOURCE:-$0}")"
fi

. "$DOROTHY/sources/essentials.sh"
. "$DOROTHY/sources/extras.sh"
