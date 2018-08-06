#!/usr/bin/env sh

# Bash Completion
if test -n "$BASH_VERSION"; then
	if is-linux; then
		if is-file /etc/bash_completion; then
			source '/etc/bash_completion'
		fi
	elif is-mac; then
		if command-exists brew && is-file "$(brew --prefix)/etc/bash_completion"; then
			source "$(brew --prefix)/etc/bash_completion"
		fi
	fi
fi
