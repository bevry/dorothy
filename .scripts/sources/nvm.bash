#!/usr/bin/env bash

# NVM
if test -n "$NVM_DIR"; then
	source "$NVM_DIR/nvm.sh"
else
	stderr echo "make sure nvm.bash is sourced once paths are sourced"
	exit 1
fi
