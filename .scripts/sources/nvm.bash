#!/bin/bash

# NVM
if is_dir "$HOME/.nvm"; then
	export NVM_DIR="$HOME/.nvm"
	# shellcheck disable=SC1090
	source "$NVM_DIR/nvm.sh"
fi