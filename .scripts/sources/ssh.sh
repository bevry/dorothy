#!/usr/bin/env sh

function addsshkey {
	eval "$(ssh-agent -s)"
	ssh-add -K "$HOME/.ssh/$1"
}

function addsshkeys {
	eval "$(ssh-agent -s)"
	ssh-add -A
}
