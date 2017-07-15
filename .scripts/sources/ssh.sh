#!/usr/bin/env sh

function addsshkey {
	eval "$(ssh-agent -s)"
	ssh-add -K "$HOME/.ssh/$1"
}

function addsshkeys {
	eval "$(ssh-agent -s)"
	ssh-add -A
	echo 'If your keys were not added, you may need to re-add them to the keychain via: addsshkey <name>'
}
