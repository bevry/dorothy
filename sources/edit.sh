#!/usr/bin/env sh

eval "$(setup-editor-commands)"
edit () {
	if is-ssh; then
		eval "${TERMINAL_EDITOR:?TERMINAL_EDITOR must be configured}" "$@"
	else
		eval "${GUI_EDITOR:?GUI_EDITOR must be configured}" "$@"
	fi
}