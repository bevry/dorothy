#!/usr/bin/env sh

# busted env fix, happened on a fresh install of dorothy on a ubuntu 21.04 raspbery pi 400
if test -z "${USER-}"; then
	export USER; USER="$(whoami 2> /dev/null || users 2> /dev/null || echo 'unknown')"
fi
if test -z "${HOME-}"; then
	if test -d "/home/$USER"; then
		export HOME; HOME="/home/$USER"
	elif test -d "/$USER"; then
		export HOME; HOME="/$USER"
	else
		export HOME; HOME="$(mktemp -d)"
	fi
fi
