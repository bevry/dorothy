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

# create the environment setup, passing over $$ such that a trap could be hooked that automatically refreshes on invalidation (not yet implemented)
DOROTHY_ENVIRONMENT_EVAL="$("$DOROTHY/commands/setup-environment-commands" --shell="$ACTIVE_POSIX_SHELL" --ppid=$$)" || {
	printf '%s\n' \
		"FAILED TO CREATE DOROTHY ENVIRONMENT SETUP WITH $?, RUN THESE TO DEBUG:" \
		"'$DOROTHY/commands/setup-environment-commands' --debug --shell='$ACTIVE_POSIX_SHELL'" \
		"bash -x '$DOROTHY/commands/setup-environment-commands' --shell='$ACTIVE_POSIX_SHELL'" >&2 || :
	if [ -n "${CI-}" ]; then
		exit 6 # ENXIO 6 Device not configured
	fi
}
# evaluate the environment setup
if [ -n "${DOROTHY_ENVIRONMENT_EVAL-}" ]; then
	eval "$DOROTHY_ENVIRONMENT_EVAL" || {
    printf '%s\n' \
		"FAILED TO EVALUATE DOROTHY ENVIRONMENT SETUP WITH $?, SETUP IS BELOW:" >&2 || :
    cat -vbn <<<"$DOROTHY_ENVIRONMENT_EVAL" >&2 || :
	if [ -n "${CI-}" ]; then
		exit 6 # ENXIO 6 Device not configured
	fi
  }
fi
