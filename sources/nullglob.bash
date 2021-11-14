#!/usr/bin/env bash

# https://www.gnu.org/software/bash/manual/html_node/The-Shopt-Builtin.html
# nullglob: If set, Bash allows filename patterns which match no files to expand to a null string, rather than themselves.

shopt -s nullglob || {
	echo-color \
		--error="Missing nullglob support." $'\n' \
		--bold="$0" " is incompatible with " --bold="bash $BASH_VERSION" $'\n' \
		"Run " --bold="setup-util-bash" " to upgrade capabilities, then run the prior command again." >/dev/stderr
	exit 95 # Operation not supported
}
