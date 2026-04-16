#!/usr/bin/env zsh

if command-missing -- starship; then
	setup-util-starship dependency
fi

eval "$(starship init zsh)"
