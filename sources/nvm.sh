#!/usr/bin/env sh
# setup-environment-commands may have set: NVM_DIR

# check that:
# that NVM_DIR possibly exists
# that nvm.sh is a non-empty file
if ! command which node >/dev/null 2>&1; then
	# workaround that can happen when the node version changes in the host shell, and nvm is no longer able to detect it, as [command which node] is what it uses
	. "$DOROTHY/sources/environment.sh"
fi
if [ -z "${NVM_DIR-}" ]; then
	export NVM_DIR="$HOME/.nvm"
fi
if [ -s "${NVM_DIR}/nvm.sh" ]; then
	. "$NVM_DIR/nvm.sh"
else
	fs-rm --quiet --no-confirm --optional -- "${NVM_DIR:-"$HOME/.nvm"}"
fi
