#!/usr/bin/env bash

# Bash Completion
if test -n "$BASH_VERSION"; then
	if command_exists brew; then
		if is_file "$(brew --prefix)/etc/bash_completion"; then
			source "$(brew --prefix)/etc/bash_completion"
		fi
	fi
fi
