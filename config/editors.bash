#!/usr/bin/env bash
# shellcheck disable=SC2034
# do not use `export` keyword in this file

# Used by `setup-environment-commands`

# Our editors in order of preference
TERMINAL_EDITORS=(
	nano
	vim # --noplugin -c "set nowrap"'
	micro
)
GUI_EDITORS=(
	"code -w"
	"atom -w"
	"subl -w"
	gedit
)
