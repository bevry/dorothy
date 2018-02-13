#!/usr/bin/env sh

if test -f "$HOME/.scripts/users/$(whoami).sh"; then
	source "$HOME/.scripts/users/$(whoami).sh"
fi
