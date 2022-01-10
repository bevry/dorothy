#!/usr/bin/env sh

edit() {
	if is-ssh; then
		("${TERMINAL_EDITOR:?"TERMINAL_EDITOR must be configured"}" "$@")
	else
		("${GUI_EDITOR:?"GUI_EDITOR must be configured"}" "$@")
	fi
}

sudo_edit() {
	if is-ssh; then
		sudo-inherit -- "${TERMINAL_EDITOR:?"TERMINAL_EDITOR must be configured"}" "$@"
	else
		sudo-inherit -- "${GUI_EDITOR:?"GUI_EDITOR must be configured"}" "$@"
	fi
}
