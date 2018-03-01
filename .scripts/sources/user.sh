#!/usr/bin/env sh

if test -f "$HOME/.scripts/users/$(whoami)/source.sh"; then
	. "$HOME/.scripts/users/$(whoami)/source.sh"
fi

if test -n "$BASH_VERSION"; then
	if test -f "$HOME/.scripts/users/$(whoami)/source.bash"; then
		. "$HOME/.scripts/users/$(whoami)/source.bash"
	fi
fi
