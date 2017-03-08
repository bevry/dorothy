#!/bin/bash

if is_ssh; then
	alias edit="$TERMINAL_EDITOR"
else
	alias edit="$GUI_EDITOR"
fi
