#!/usr/bin/env sh
# setup-environment-commands may have set: NVM_DIR

# check that:
# we aren't running inside fish
# that NVM_DIR possibly exists
# that nvm.sh is a non-empty file
if test -z "${FISH_VERSION-}"; then
	if test -z "${NVM_DIR-}" -a -s "$HOME/.nvm/nvm.sh"; then
		export NVM_DIR="$HOME/.nvm"
		. "$NVM_DIR/nvm.sh"
	elif test -n "${NVM_DIR-}" -a -s "${NVM_DIR-}/nvm.sh"; then
		. "$NVM_DIR/nvm.sh"
	fi
fi
