#!/usr/bin/env sh

. "$DOROTHY/sources/get_active_shell.sh"
eval "$("$DOROTHY/commands/setup-editor-commands" "$(get_active_shell)")"
edit() {
	if is-ssh; then
		eval "${TERMINAL_EDITOR:?"TERMINAL_EDITOR must be configured"}" "$@"
	else
		eval "${GUI_EDITOR:?"GUI_EDITOR must be configured"}" "$@"
	fi
}
