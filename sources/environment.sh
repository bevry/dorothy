#!/usr/bin/env sh

# don't export
if test -n "${ZSH_VERSION-}"; then
	ACTIVE_SHELL='zsh'
elif test -n "${BASH_VERSION-}"; then
	ACTIVE_SHELL='bash'
elif test -n "${FISH_VERSION-}"; then
	ACTIVE_SHELL='fish'
elif test -n "${KSH_VERSION-}"; then
	ACTIVE_SHELL='ksh'
elif test -n "${FCEDIT-}"; then
	ACTIVE_SHELL='ksh'
elif test -n "${PS3-}"; then
	ACTIVE_SHELL='unknown'
else
	ACTIVE_SHELL='sh'
fi

{
	eval "$("$DOROTHY/commands/setup-environment-commands" "$ACTIVE_SHELL")"
} || {
	echo "Failed to setup environment, failed command was:"
	echo "$DOROTHY/commands/setup-environment-commands" "$ACTIVE_SHELL"
	return 1
} >/dev/stderr
