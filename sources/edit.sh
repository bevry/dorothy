#!/usr/bin/env sh

edit() {
	if is-ssh; then
		("${TERMINAL_EDITOR:?"TERMINAL_EDITOR must be configured"}" "$@")
	else
		("${GUI_EDITOR:?"GUI_EDITOR must be configured"}" "$@")
	fi
}
