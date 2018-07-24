#!/usr/bin/env sh

eval "$(setup-editor-commands)"
function edit {
	if is_ssh; then
		if test -z "$TERMINAL_EDITOR"; then
			echo "\$TERMINAL_EDITOR is undefined"
		else
			eval "$TERMINAL_EDITOR" "$@"
		fi
	else
		if test -z "$GUI_EDITOR"; then
			echo "\$GUI_EDITOR is undefined"
		else
			eval "$GUI_EDITOR" "$@"
		fi
	fi
}