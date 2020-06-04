#!/usr/bin/env bash

# https://www.gnu.org/software/bash/manual/html_node/The-Shopt-Builtin.html
# nullglob: If set, Bash allows filename patterns which match no files to expand to a null string, rather than themselves.

if [[ "$BASH_VERSION" = "4."* || "$BASH_VERSION" = "5."* ]]; then
	shopt -s nullglob
else
	"$BDIR/commands/stderr" echo 'bash version is too old for nullglob'
	exit 1
fi