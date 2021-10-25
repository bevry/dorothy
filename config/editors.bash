#!/usr/bin/env bash

# our editors in order of preference
export TERMINAL_EDITORS=(
	nano
	vim # --noplugin -c "set nowrap"'
	micro
)
export GUI_EDITORS=(
	"code -w"
	"atom -w"
	"subl -w"
	gedit
)
