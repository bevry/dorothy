#!/usr/bin/env sh

# only work on environments that have an ssh-agent
if command-exists ssh-agent; then
	# start the ssh agent
	if is-empty-string "${SSH_AUTH_SOCK-}"; then
		eval "$(ssh-agent -s)"
		# ssh-add-all
	fi

	# kill it when our cli ends
	finish () {
		# killall ssh-agent
		eval "$(ssh-agent -k)"
	}
	trap finish EXIT
fi
