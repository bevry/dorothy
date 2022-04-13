#!/usr/bin/env sh
# setup-environment-commands may have set: NVM_DIR

# check that:
# that NVM_DIR possibly exists
# that nvm.sh is a non-empty file
if test -z "${NVM_DIR-}"; then
	export NVM_DIR="$HOME/.nvm"
fi
if test -s "${NVM_DIR}/nvm.sh"; then
	# trunk-ignore(shellcheck/SC1091)
	. "$NVM_DIR/nvm.sh"
else
	rm -Rf "${NVM_DIR:-"$HOME/.nvm"}"
fi
