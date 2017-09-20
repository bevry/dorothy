#!/usr/bin/env bash

# Bash Completion
if test -n "$BASH_VERSION"; then
	if command_exists brew; then
		if is_file "$(brew --prefix)/etc/bash_completion"; then
			# shellcheck disable=SC1090
			source "$(brew --prefix)/etc/bash_completion"
		fi
	fi
fi
