#!/usr/bin/env sh

# set the active shell as the detectected POSIX (.sh) shell
# do not export
if test -n "${BASH_VERSION-}"; then
	ACTIVE_POSIX_SHELL='bash'
elif test -n "${ZSH_VERSION-}"; then
	ACTIVE_POSIX_SHELL='zsh'
elif test "$0" = '-dash' -o "$0" = 'dash'; then
	# dash does not define DASH_VERSION
	ACTIVE_POSIX_SHELL='dash'
elif test -n "${KSH_VERSION-}"; then
	ACTIVE_POSIX_SHELL='ksh'
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
