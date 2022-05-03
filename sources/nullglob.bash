#!/usr/bin/env bash

# https://www.gnu.org/software/bash/manual/html_node/The-Shopt-Builtin.html
# nullglob: If set, Bash allows filename patterns which match no files to expand to a null string, rather than themselves.

# https://github.com/bminor/bash/blob/master/CHANGES
# nullglob is not referenced inside the changelog, so must be very old
# and thus widely supported

shopt -s nullglob || {
	echo-style --error="Missing nullglob support:"
	source "$DOROTHY/sources/bash.bash"
	require_latest_bash
}
