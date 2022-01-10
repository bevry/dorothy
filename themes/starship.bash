#!/usr/bin/env bash

if command-missing starship; then
	setup-util-starship
fi

eval "$(starship init bash)"
