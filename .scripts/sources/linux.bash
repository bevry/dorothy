#!/usr/bin/env bash

# Bash Autocompletion
if test -n "$BASH_VERSION"; then
	if is_file /etc/bash_completion; then
		# shellcheck disable=SC1091
		source /etc/bash_completion
	fi
fi