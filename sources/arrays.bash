#!/usr/bin/env bash

# https://tldp.org/LDP/abs/html/bashver4.html
# mapfile, and arrays landed in Bash version 4

if [[ "$BASH_VERSION" = "4."* || "$BASH_VERSION" = "5."* ]]; then
	export ARRAYS='yes'
else
	export ARRAYS='no'
	stderr echo 'bash version is too old for non-trivial arrays'
fi
