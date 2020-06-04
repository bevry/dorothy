#!/usr/bin/env sh

if test -n "$BASH_VERSION" -a -f "$HOME/.scripts/env.bash"; then
	. "$HOME/.scripts/env.bash"
elif test -n "$ZSH_VERSION" -a -f "$HOME/.scripts/env.zsh"; then
	. "$HOME/.scripts/env.zsh"
elif test -f "$HOME/.scripts/env.sh"; then
	. "$HOME/.scripts/env.sh"
fi

if test -n "$BASH_VERSION" -a -f "$HOME/.scripts/users/$(whoami)/source.bash"; then
	. "$HOME/.scripts/users/$(whoami)/source.bash"
elif test -n "$ZSH_VERSION" -a -f "$HOME/.scripts/users/$(whoami)/source.zsh"; then
	. "$HOME/.scripts/users/$(whoami)/source.zsh"
elif test -f "$HOME/.scripts/users/$(whoami)/source.sh"; then
	. "$HOME/.scripts/users/$(whoami)/source.sh"
fi
