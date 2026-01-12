#!/usr/bin/env bash

if command-missing -- starship; then
	setup-util-starship --quiet
fi

eval "$(starship init bash)"
