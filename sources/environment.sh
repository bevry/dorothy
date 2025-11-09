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

# set the environment variables, passing over $$ such that a trap could be hooked that automatically refreshes on invalidation (not yet implemented)
DOROTHY_ENVIRONMENT_EVAL_STATUS=0
DOROTHY_ENVIRONMENT_EVAL="$("$DOROTHY/commands/setup-environment-commands" --shell="$ACTIVE_POSIX_SHELL" --ppid=$$)" || DOROTHY_ENVIRONMENT_EVAL_STATUS=$?
if [ "$DOROTHY_ENVIRONMENT_EVAL_STATUS" = 0 ]; then
	eval "$DOROTHY_ENVIRONMENT_EVAL" || DOROTHY_ENVIRONMENT_EVAL_STATUS=$?
fi
if [ "$DOROTHY_ENVIRONMENT_EVAL_STATUS" != 0 ]; then
	printf '%s\n' 'DOROTHY FAILED TO SETUP ENVIRONMENT, RUN THIS TO DEBUG:' "bash -x '$DOROTHY/commands/setup-environment-commands' --debug --shell='$ACTIVE_POSIX_SHELL'" >&2 || :
	if [ -n "${CI-}" ]; then
		bash -x "$DOROTHY/commands/setup-environment-commands" --debug --shell="$ACTIVE_POSIX_SHELL" >&2 || :
	fi
	return "$DOROTHY_ENVIRONMENT_EVAL_STATUS"
fi
