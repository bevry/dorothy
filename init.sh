#!/usr/bin/env sh

if test -z "${BDIR-}"; then
	# https://stackoverflow.com/a/246128
	# https://stackoverflow.com/a/14728194
	export BDIR; BDIR="$(dirname "${BASH_SOURCE:-$0}")"
fi

. "$BDIR/sources/essentials.sh"
. "$BDIR/sources/extras.sh"
