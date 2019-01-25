#!/usr/bin/env bash

# https://www.gnu.org/software/bash/manual/html_node/The-Shopt-Builtin.html
# extglob: If set, the extended pattern matching features described above (see Pattern Matching) are enabled.

if [[ "$BASH_VERSION" = "4."* || "$BASH_VERSION" = "5."* ]]; then
	shopt -s extglob
else
	stderr echo 'bash version is too old'
	exit 1
fi