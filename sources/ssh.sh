#!/usr/bin/env sh

# we are in posix, so can't use bash's &> shortcut

# silent is done to prevent rsync ssh failures
# https://fixyacloud.wordpress.com/2020/01/26/protocol-version-mismatch-is-your-shell-clean/

# only work on environments that have an ssh-agent
if command-exists ssh-agent; then
	# start the ssh agent
	if test -z "${SSH_AUTH_SOCK-}"; then
		eval "$(ssh-agent -s)" >/dev/null 2>&1
		# ssh-add-all
	fi

	# kill it when our cli ends
	finish() {
		# killall ssh-agent
		eval "$(ssh-agent -k)" >/dev/null 2>&1
	}
	trap finish EXIT
fi
