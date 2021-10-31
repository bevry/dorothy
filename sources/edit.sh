#!/usr/bin/env sh

eval "$("$DOROTHY/commands/setup-editor-commands" "$ACTIVE_SHELL")"
edit() {
	if is-ssh; then
		eval "${TERMINAL_EDITOR:?"TERMINAL_EDITOR must be configured"}" "$@"
	else
		eval "${GUI_EDITOR:?"GUI_EDITOR must be configured"}" "$@"
	fi
}
