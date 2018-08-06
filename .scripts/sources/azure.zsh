#!/usr/bin/env zsh

if command-exists azure; then
	eval '<(azure --completion)'
fi