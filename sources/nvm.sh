#!/usr/bin/env sh
# setup-environment-commands may have set: NVM_DIR

# check that:
# that NVM_DIR possibly exists
# that nvm.sh is a non-empty file
if [ -z "${NVM_DIR-}" ]; then
	export NVM_DIR="$HOME/.nvm"
fi
if [ -s "${NVM_DIR}/nvm.sh" ]; then
	. "$NVM_DIR/nvm.sh"
else
	fs-rm --quiet --no-confirm --optional -- "${NVM_DIR:-"$HOME/.nvm"}"
fi
