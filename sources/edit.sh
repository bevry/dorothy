#!/usr/bin/env sh

eval "$(env -i DOROTHY="$DOROTHY" DOROTHY_USER_HOME="$DOROTHY_USER_HOME" USER="$USER" HOME="$HOME" PATH="$PATH" "$DOROTHY/commands/setup-editor-commands")"
edit() {
	if is-ssh; then
		eval "${TERMINAL_EDITOR:?"TERMINAL_EDITOR must be configured"}" "$@"
	else
		eval "${GUI_EDITOR:?"GUI_EDITOR must be configured"}" "$@"
	fi
}
