#!/usr/bin/env bash

# https://www.gnu.org/software/bash/manual/html_node/The-Shopt-Builtin.html
# globstar: If set, the pattern ‘**’ used in a filename expansion context will match all files and zero or more directories and subdirectories. If the pattern is followed by a ‘/’, only directories and subdirectories match.

# Globstar came in bash v4, as such is not available on bash v3 that is provided by macOS
# https://github.com/bminor/bash/blob/master/CHANGES
# This document details the changes between this version, bash-4.0-alpha,
# and the previous version, bash-3.2-release.
#
# w.  There is a new shell option: `globstar'.  When enabled, the globbing code
#     treats `**' specially -- it matches all directories (and files within
#     them, when appropriate) recursively.

shopt -s globstar || {
	echo-style \
		--error="Missing globstar support." $'\n' \
		--bold="$0" " is incompatible with " --bold="bash $BASH_VERSION" $'\n' \
		"Run " --bold="setup-util-bash" " to upgrade capabilities, then run the prior command again." >/dev/stderr
	return 95 # Operation not supported
}
