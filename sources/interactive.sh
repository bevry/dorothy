#!/usr/bin/env sh
# Imports ACTIVE_SHELL

# Scripts in here are generally intended only for interactive login shells, are generally slow, and are generally not useful for commands
# If a command does need one of them, then it can source it directly

# Source our ability to load configuration files
. "$DOROTHY/sources/config.sh"

# Load the configuration for interactive shells
if test "$ACTIVE_SHELL" = 'sh'; then
	load_dorothy_config 'interactive.sh'
else
	# load each filename
	# passes if one or more were loaded
	# fails if none were loaded (all were missing)
	load_dorothy_config "interactive.$ACTIVE_SHELL" 'interactive.sh'
fi

# dorothy theme override, which is used for trial mode
if test -n "${DOROTHY_THEME_OVERRIDE-}"; then
	DOROTHY_THEME="$DOROTHY_THEME_OVERRIDE"
fi

# continue with the shell extras
. "$DOROTHY/sources/nvm.sh"
. "$DOROTHY/sources/history.sh"
. "$DOROTHY/sources/theme.sh"
. "$DOROTHY/sources/ssh.sh"

# bash adn zsh extensions
if test "$ACTIVE_SHELL" = 'bash' -o "$ACTIVE_SHELL" = 'zsh'; then
	# github copilot cli
	# https://www.npmjs.com/package/@githubnext/github-copilot-cli
	if command-exists github-copilot-cli; then
		eval "$(github-copilot-cli alias -- "$ACTIVE_SHELL")"
	fi

	# vscode terminal integration
	# https://code.visualstudio.com/docs/terminal/shell-integration#_manual-installation
	if test "$TERM_PROGRAM" = "vscode"; then
		. "$(code --locate-shell-integration-path "$ACTIVE_SHELL")"
	fi
fi
