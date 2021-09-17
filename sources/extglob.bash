#!/usr/bin/env bash

# https://www.gnu.org/software/bash/manual/html_node/The-Shopt-Builtin.html
# extglob: If set, the extended pattern matching features described above (see Pattern Matching) are enabled.

if [[ "$BASH_VERSION" = "4."* || "$BASH_VERSION" = "5."* ]]; then
	export EXTGLOB='yes'
	shopt -s extglob
else
	export EXTGLOB='no'
	stderr echo 'bash version is too old for extglob'
fi
