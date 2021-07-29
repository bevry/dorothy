#!/usr/bin/env sh

# check that:
# we aren't running inside fish
# that NVM_DIR exists
# that nvm.sh is a non-empty file
if test -z "${FISH_VERSION-}" -a -n "${NVM_DIR-}" -a -s "${NVM_DIR-}/nvm.sh"; then
	# source it
	. "$NVM_DIR/nvm.sh"
fi
