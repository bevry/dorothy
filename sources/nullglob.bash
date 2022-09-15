#!/usr/bin/env bash

# bash v1 nullglob If set, Bash allows filename patterns which match no files to expand to a null string, rather than themselves.
shopt -s nullglob || {
	echo-style --error="Missing nullglob support:"
	source "$DOROTHY/sources/bash.bash"
	require_latest_bash
}
