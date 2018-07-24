#!/usr/bin/env sh

# Bash Completion
if test -n "$BASH_VERSION"; then
	if is_linux; then
		if is_file /etc/bash_completion; then
			source '/etc/bash_completion'
		fi
	elif is_mac; then
		if command_exists brew && is_file "$(brew --prefix)/etc/bash_completion"; then
			source "$(brew --prefix)/etc/bash_completion"
		fi
	fi
fi
