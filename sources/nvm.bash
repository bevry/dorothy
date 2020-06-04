#!/usr/bin/env bash

# NVM
if is-string "${NVM_DIR:-}"; then
	source "$NVM_DIR/nvm.sh"
fi
