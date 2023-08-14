#!/usr/bin/env zsh

if command-missing starship; then
	setup-util-starship
fi

eval "$(starship init zsh)"
