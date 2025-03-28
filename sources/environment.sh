#!/usr/bin/env sh

# set the active shell as the detected POSIX (.sh) shell
# do not export
if [ -n "${BASH_VERSION-}" ]; then
	ACTIVE_POSIX_SHELL='bash'
elif [ -n "${ZSH_VERSION-}" ]; then
	ACTIVE_POSIX_SHELL='zsh'
elif [ "$0" = '-dash' ] || [ "$0" = 'dash' ]; then
	# dash does not define DASH_VERSION
	ACTIVE_POSIX_SHELL='dash'
elif [ -n "${KSH_VERSION-}" ]; then
	ACTIVE_POSIX_SHELL='ksh'
else
	ACTIVE_POSIX_SHELL='sh'
fi

# set the environment variables
eval "$("$DOROTHY/commands/setup-environment-commands" --shell="$ACTIVE_POSIX_SHELL" || {
	echo "DOROTHY FAILED TO SETUP ENVIRONMENT, RUN THIS TO DEBUG: bash -x '$DOROTHY/commands/setup-environment-commands' '$ACTIVE_POSIX_SHELL'" >/dev/stderr
	return 1
})"