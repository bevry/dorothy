#!/usr/bin/env sh

# start the ssh agent
if is-empty-string "${SSH_AUTH_SOCK-}"; then
	eval "$(ssh-agent -s)"
	# ssh-add-all
fi

# kill it when our cli ends
function finish {
	# killall ssh-agent
	eval "$(ssh-agent -k)"
}
trap finish EXIT