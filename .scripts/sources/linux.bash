#!/usr/bin/env bash

# Bash Autocompletion
if test -n "$BASH_VERSION"; then
	if is_file /etc/bash_completion; then
		source '/etc/bash_completion'
	fi
fi