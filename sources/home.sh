#!/usr/bin/env sh

# busted env fix, happened on a fresh install of dorothy on a ubuntu 21.04 raspbery pi 400
if test -z "${USER-}"; then
	export USER
	USER="$(whoami 2>/dev/null || users 2>/dev/null || echo 'unknown')"
fi
if test -z "${HOME-}"; then
	export HOME
	if test -d "/home/$USER"; then
		HOME="/home/$USER"
	elif test -d "/$USER"; then
		HOME="/$USER"
	else
		HOME="$(mktemp -d)"
	fi
fi
