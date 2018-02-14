#!/usr/bin/env sh

if test -f "$HOME/.scripts/users/$(whoami)/source.sh"; then
	source "$HOME/.scripts/users/$(whoami)/source.sh"
fi
