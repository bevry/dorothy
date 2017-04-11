#!/usr/bin/env bash

# Set the editor configuration
export LC_CTYPE=en_US.UTF-8

if command_exists micro; then
	export TERMINAL_EDITOR='micro'
	export TERMINAL_EDITOR_PROMPT='micro'
elif command_exists nano; then
	export TERMINAL_EDITOR='nano'
	export TERMINAL_EDITOR_PROMPT='nano'
elif command_exists vim; then
	export TERMINAL_EDITOR='vim'
	export TERMINAL_EDITOR_PROMPT='vim' # --noplugin -c "set nowrap"'
fi

if command_exists code; then
	export GUI_EDITOR='code'
	export GUI_EDITOR_PROMPT='code -w'
elif command_exists atom; then
	export GUI_EDITOR='atom'
	export GUI_EDITOR_PROMPT='atom -w'
elif command_exists subl; then
	export GUI_EDITOR='subl'
	export GUI_EDITOR_PROMPT='subl -w'
elif command_exists gedit; then
	export GUI_EDITOR='gedit'
	export GUI_EDITOR_PROMPT='gedit'
fi

# Always use terminal editor for prompts
# as GUI editors are too slow
export EDITOR=$TERMINAL_EDITOR_PROMPT
