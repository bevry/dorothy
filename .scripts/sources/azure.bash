#!/usr/bin/env bash

if command-exists azure; then
	eval "$(azure --completion)"
fi