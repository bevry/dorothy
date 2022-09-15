#!/usr/bin/env bash

# bash v4 globstar If set, the pattern ‘**’ used in a filename expansion context will match all files and zero or more directories and subdirectories. If the pattern is followed by a ‘/’, only directories and subdirectories match.
shopt -s globstar || {
	echo-style --error="Missing globstar support:"
	source "$DOROTHY/sources/bash.bash"
	require_latest_bash
}
