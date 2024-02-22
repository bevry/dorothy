#!/usr/bin/env sh
# Imports ACTIVE_POSIX_SHELL

# Scripts in here are generally intended only for interactive login shells, are generally slow, and are generally not useful for commands
# If a command does need one of them, then it can source it directly

# Source our ability to load configuration files
. "$DOROTHY/sources/config.sh"

# Load the configuration for interactive shells
if test "$ACTIVE_POSIX_SHELL" = 'sh'; then
	load_dorothy_config 'interactive.sh'
else
	# load each filename
	# passes if one or more were loaded
	# fails if none were loaded (all were missing)
	load_dorothy_config "interactive.$ACTIVE_POSIX_SHELL" 'interactive.sh'
fi

# Continue with the shell extras
if test "$ACTIVE_POSIX_SHELL" != 'ksh'; then
	# nvm.sh is not compatible with ksh
	. "$DOROTHY/sources/nvm.sh"
fi
. "$DOROTHY/sources/history.sh"
. "$DOROTHY/sources/theme.sh"
. "$DOROTHY/sources/ssh.sh"
if test "$ACTIVE_POSIX_SHELL" = 'bash' -o "$ACTIVE_POSIX_SHELL" = 'zsh'; then
	. "$DOROTHY/sources/autocomplete.$ACTIVE_POSIX_SHELL"
fi

# Shoutouts
if command-exists shuf; then
	shuf -n1 "$DOROTHY/sources/shoutouts.txt"
fi
