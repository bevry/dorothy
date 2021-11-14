#!/usr/bin/env bash
# shellcheck disable=SC2034
# do not use `export` keyword in this file

# our editors in order of preference
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
