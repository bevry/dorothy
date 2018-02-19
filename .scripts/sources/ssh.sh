#!/usr/bin/env sh

function startssh {
	# http://rabexc.org/posts/pitfalls-of-ssh-agents
	if test -z "$SSH_AUTH_SOCK"; then
		eval "$(ssh-agent -s)"
	fi
}

function addsshkey {
	startssh
	ssh-add -K "$HOME/.ssh/$1"
}

function addsshkeys {
	startssh
	ssh-add -A
	echo 'If your keys were not added, you may need to re-add them to the keychain via: addsshkey <name>'
}
