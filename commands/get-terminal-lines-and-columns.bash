#!/usr/bin/env bash

if [[ -n ${BASH_SUBSHELL-} && $BASH_SUBSHELL -ne 0 ]]; then
	# checkwinsize does not work inside subshells, so if running in a subshell then invoke to avoid subshell
	get-terminal-lines-and-columns.bash "$@" || exit
	exit
else
	# checkwinsize: If set, Bash checks the window size after each external (non-builtin) command and, if necessary, updates the values of LINES and COLUMNS. This option is enabled by default.
	shopt -s checkwinsize || :
	(:) # noop subshell which updates LINES and COLUMNS
	if [[ -n ${LINES-} && -n ${COLUMNS-} ]]; then
		printf '%s\n' "$LINES" "$COLUMNS" || exit
	else
		exit 19 # ENODEV 19 Operation not supported by device
	fi
fi
