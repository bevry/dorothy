#!/usr/bin/env sh

function ssh-start {
	# http://rabexc.org/posts/pitfalls-of-ssh-agents
	if test -z "$SSH_AUTH_SOCK"; then
		eval "$(ssh-agent -s)"
	fi
}

function ssh-add-one {
	ssh-start
	ssh-add -K "$HOME/.ssh/$1"
}

function ssh-add-all {
	ssh-start
	ssh-add -A
	echo 'If your keys were not added, you may need to re-add them to the keychain via: ssh-add <name>'
}
