#!/usr/bin/env bash

# https://www.gnu.org/software/bash/manual/html_node/The-Shopt-Builtin.html
# globstar: If set, the pattern ‘**’ used in a filename expansion context will match all files and zero or more directories and suDOROTHYectories. If the pattern is followed by a ‘/’, only directories and suDOROTHYectories match.

if [[ "$BASH_VERSION" = "4."* || "$BASH_VERSION" = "5."* ]]; then
	shopt -s globstar
else
	"$DOROTHY/commands/stderr" echo 'bash version is too old for globstar'
	# exit 1
fi