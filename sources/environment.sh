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
    'DOROTHY FAILED TO CREATE ENVIRONMENT SETUP, RUN THESE TO DEBUG:' \
    "'$DOROTHY/commands/setup-environment-commands' --debug --shell='$ACTIVE_POSIX_SHELL'" \
    "bash -x '$DOROTHY/commands/setup-environment-commands' --shell='$ACTIVE_POSIX_SHELL'" >&2 || :
}
# evaluate the environment setup
if [ -n "${DOROTHY_ENVIRONMENT_EVAL-}" ]; then
	eval "$DOROTHY_ENVIRONMENT_EVAL" || {
    printf '%s\n' "\
      EVALUATION OF THIS DOROTHY ENVIRONMENT SETUP WITH $?:" >&2 || :
    cat -vbn <<<"$DOROTHY_ENVIRONMENT_EVAL" >&2 || :
  }
fi
