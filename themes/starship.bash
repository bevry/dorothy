#!/usr/bin/env bash

if command-missing -- starship; then
	setup-util-starship --dependency
fi

eval "$(starship init bash)"
