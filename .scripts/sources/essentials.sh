#!/usr/bin/env sh

# Don't check mail
export MAILCHECK=0

# Essential
if test -n "$ZSH_VERSION"; then
	. "$HOME/.scripts/sources/var.zsh"
else
	. "$HOME/.scripts/sources/var.bash"
fi
. "$HOME/.scripts/sources/user.sh"
. "$HOME/.scripts/sources/paths.sh"
. "$HOME/.scripts/sources/nvm.bash"
. "$HOME/.scripts/sources/edit.sh"
