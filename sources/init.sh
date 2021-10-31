#!/usr/bin/env sh

# don't check mail
export MAILCHECK=0

# shell
if test -n "${ZSH_VERSION-}"; then
	export ACTIVE_SHELL='zsh'
elif test -n "${BASH_VERSION-}"; then
	export ACTIVE_SHELL='bash'
elif test -n "${FISH_VERSION-}"; then
	export ACTIVE_SHELL='fish'
elif test -n "${KSH_VERSION-}"; then
	export ACTIVE_SHELL='ksh'
elif test -n "${FCEDIT-}"; then
	export ACTIVE_SHELL='ksh'
elif test -n "${PS3-}"; then
	export ACTIVE_SHELL='unknown'
else
	export ACTIVE_SHELL='sh'
fi

# essential
. "$DOROTHY/sources/environment.sh"
