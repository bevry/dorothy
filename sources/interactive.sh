#!/usr/bin/env sh
# Imports ACTIVE_POSIX_SHELL

# Scripts in here are generally intended only for interactive login shells, are generally slow, and are generally not useful for commands
# If a command does need one of them, then it can source it directly

# Source our ability to load configuration files
. "$DOROTHY/sources/config.sh"

# Load the configuration for interactive shells
if [ "$ACTIVE_POSIX_SHELL" = 'sh' ]; then
	load_dorothy_config --first --optional -- 'interactive.sh'
else
	load_dorothy_config --first --optional -- "interactive.$ACTIVE_POSIX_SHELL" 'interactive.sh'
fi

# Continue with the shell extras
if [ "$ACTIVE_POSIX_SHELL" != 'ksh' ]; then
	# nvm.sh is not compatible with ksh
	. "$DOROTHY/sources/nvm.sh"
fi
. "$DOROTHY/sources/history.sh"
. "$DOROTHY/sources/theme.sh"
. "$DOROTHY/sources/ssh.sh"
if [ "$ACTIVE_POSIX_SHELL" = 'bash' ] || [ "$ACTIVE_POSIX_SHELL" = 'zsh' ]; then
	. "$DOROTHY/sources/autocomplete.$ACTIVE_POSIX_SHELL"
fi

# Shoutouts
if command-exists -- shuf; then
	shuf -n1 "$DOROTHY/sources/shoutouts.txt"
fi
dorothy-warnings warn
