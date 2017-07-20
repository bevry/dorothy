#!/usr/bin/env zsh

if command_exists azure; then
	eval '<(azure --completion)'
fi