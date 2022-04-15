#!/usr/bin/env sh

. "$DOROTHY/sources/get_active_shell.sh"
{
	eval "$("$DOROTHY/commands/setup-environment-commands" "$(get_active_shell)")"
} || {
	echo "Failed to setup environment, failed command was:"
	echo "$DOROTHY/commands/setup-environment-commands" "$(get_active_shell)"
	return 1
} >/dev/stderr
