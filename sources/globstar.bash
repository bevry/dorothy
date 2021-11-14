#!/usr/bin/env bash

# https://www.gnu.org/software/bash/manual/html_node/The-Shopt-Builtin.html
# globstar: If set, the pattern ‘**’ used in a filename expansion context will match all files and zero or more directories and subdirectories. If the pattern is followed by a ‘/’, only directories and subdirectories match.

shopt -s globstar || {
	echo-color \
		--error="Missing globstar support." $'\n' \
		--bold="$0" " is incompatible with " --bold="bash $BASH_VERSION" $'\n' \
		"Run " --bold="setup-util-bash" " to upgrade capabilities, then run the prior command again." >/dev/stderr
	exit 95 # Operation not supported
}
