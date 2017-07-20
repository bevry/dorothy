#!/usr/bin/env bash

if command_exists azure; then
	eval "$(azure --completion)"
fi