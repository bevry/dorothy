#!/usr/bin/env sh

if test -f "$HOME/.scripts/users/$(whoami)/source.bash"; then
	source "$HOME/.scripts/users/$(whoami)/source.bash"
fi
