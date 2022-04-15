#!/usr/bin/env bash

# https://www.gnu.org/software/bash/manual/html_node/The-Shopt-Builtin.html
# extglob: If set, the extended pattern matching features described above (see Pattern Matching) are enabled.

shopt -s extglob || {
	echo-style \
		--error="Missing extglob support." $'\n' \
		--bold="$0" " is incompatible with " --bold="bash $BASH_VERSION" $'\n' \
		"Run " --bold="setup-util-bash" " to upgrade capabilities, then run the prior command again." >/dev/stderr
	return 95 # Operation not supported
}
