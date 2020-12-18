#!/usr/bin/env sh

function ssh-start-helper {
	# http://rabexc.org/posts/pitfalls-of-ssh-agents
	if is-empty-string "${SSH_AUTH_SOCK-}"; then
		eval "$(ssh-agent -s)"
	fi
}
