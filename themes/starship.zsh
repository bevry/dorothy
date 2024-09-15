#!/usr/bin/env zsh

if command-missing -- starship; then
	setup-util-starship --quiet
fi

eval "$(starship init zsh)"
