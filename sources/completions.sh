#!/usr/bin/env sh

# Bash Completion
if test -n "${BASH_VERSION-}"; then
	if is-linux; then
		if is-file /etc/bash_completion; then
			. '/etc/bash_completion'
		fi
	elif is-mac; then
		if is-file "${HOMEBREW_PREFIX-}/etc/bash_completion"; then
			. "${HOMEBREW_PREFIX-}/etc/bash_completion"
		fi
	fi
fi
