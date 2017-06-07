#!/usr/bin/env bash

# Bash Autocompletion
if is_bash; then
	if is_file /etc/bash_completion; then
		# shellcheck disable=SC1091
		source /etc/bash_completion
	fi
fi