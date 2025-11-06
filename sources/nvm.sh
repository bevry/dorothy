#!/usr/bin/env sh

# ensure NVM_DIR, always set as always applicable right now
if [ -z "${NVM_DIR-}" ]; then
	export NVM_DIR="$HOME/.nvm"
fi

# check nvm is non-empty
if [ -s "$NVM_DIR/nvm.sh" ]; then
	# we have nvm
	# check if we can access node
	if ! command which node >/dev/null 2>&1; then
		# then reload the environment, as this occurs when the node version changes in the host environment, as such nvm is no longer able to detect it via its [command which node]
		. "$DOROTHY/sources/environment.sh"
	fi
	# we have nvm, and should now have node, so load nvm
	. "$NVM_DIR/nvm.sh"
elif [ -d "$NVM_DIR" ]; then
	# we have nvm, but it is corrupted, so remove it
	fs-remove --quiet --no-confirm -- "$NVM_DIR"
fi
