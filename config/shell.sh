#!/usr/bin/env bash

# export DOROTHY_THEME='system'  # use `select-theme` to select an available theme

# make sure when we use bash, we use globstar if it is supported
if [[ "$BASH_VERSION" = "4."* || "$BASH_VERSION" = "5."* ]]; then
	source "$DOROTHY/sources/globstar.bash"
fi
