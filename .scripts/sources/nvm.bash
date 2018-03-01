#!/usr/bin/env bash

# NVM
if is_dir "$HOME/.nvm"; then
	export NVM_DIR="$HOME/.nvm"
	source "$NVM_DIR/nvm.sh"
fi