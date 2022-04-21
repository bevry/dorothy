#!/usr/bin/env sh

# scripts in here are especially unnecessary for commands, and are often slow
# they are generally only useful for user interactive environments
# if a command does need one of these, then the command can source it directly

# export the active shell as the active login shell
export ACTIVE_LOGIN_SHELL
ACTIVE_LOGIN_SHELL="$(get_active_shell)"

# additional extras for an interactive shell
. "$DOROTHY/sources/config.sh"
if test "$ACTIVE_LOGIN_SHELL" = 'sh'; then
	load_dorothy_config 'shell.sh'
else
	# load each filename
	# passes if one or more were loaded
	# fails if none were loaded (all were missing)
	load_dorothy_config "shell.$ACTIVE_LOGIN_SHELL" 'shell.sh'
fi

# dorothy theme override, which is used for trial mode
if test -n "${DOROTHY_THEME_OVERRIDE-}"; then
	DOROTHY_THEME="$DOROTHY_THEME_OVERRIDE"
fi

# continue with the shell extras
. "$DOROTHY/sources/nvm.sh"
. "$DOROTHY/sources/edit.sh"
. "$DOROTHY/sources/history.sh"
. "$DOROTHY/sources/theme.sh"
. "$DOROTHY/sources/ssh.sh"
