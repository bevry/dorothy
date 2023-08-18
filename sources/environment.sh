#!/usr/bin/env sh

# set the active shell as the detectected POSIX (.sh) shell
# do not export
if test -n "${ZSH_VERSION-}"; then
	ACTIVE_POSIX_SHELL='zsh'
elif test -n "${BASH_VERSION-}"; then
	ACTIVE_POSIX_SHELL='bash'
elif test -n "${KSH_VERSION-}"; then
	ACTIVE_POSIX_SHELL='ksh'
elif test -n "${FCEDIT-}"; then
	ACTIVE_POSIX_SHELL='ksh'
elif test -n "${PS3-}"; then
	ACTIVE_POSIX_SHELL='unknown'
else
	ACTIVE_POSIX_SHELL='sh'
fi

# set the environment variables
{
	eval "$("$DOROTHY/commands/setup-environment-commands" "$ACTIVE_POSIX_SHELL")"
} || {
	echo "Failed to setup environment, failed command was:"
	echo "$DOROTHY/commands/setup-environment-commands" "$ACTIVE_POSIX_SHELL"
	return 1
} >/dev/stderr
