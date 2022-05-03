#!/usr/bin/env bash

# https://www.gnu.org/software/bash/manual/bash.html#Shell-Parameter-Expansion
# Bash version compatibility: https://github.com/bevry/dorothy/discussions/151

# If there is ever a double digit version part, we can change this, until then, this is perfect
BASH_MAJOR_VERSION="${BASH_VERSION:0:1}"
BASH_MINOR_VERSION="${BASH_VERSION:2:1}"

# ucf = upper case first letter
# lc  = lower case all
if test "$BASH_MAJOR_VERSION" -eq 5 -a "$BASH_MINOR_VERSION" -ge 1; then
	# >= bash v5.1
	function ucf {
		echo "${1@u}"
	}
	function lc {
		echo "${1@L}"
	}
elif test "$BASH_MAJOR_VERSION" -eq 4; then
	# >= bash v4.0
	function ucf {
		echo "${1^}"
	}
	function lc {
		echo "${1,,}"
	}
else
	# < bash v4.0
	function ucf {
		echo "$1" # not important, implement later
	}
	function lc {
		echo "$1" # not important, implement later
	}
fi

# testv = test variable is defined
if test "$BASH_MAJOR_VERSION" -ge 5 || test "$BASH_MAJOR_VERSION" -eq 4 -a "$BASH_MINOR_VERSION" -ge 2; then
	# >= bash v4.2
	function testv {
		test -v "$1"
	}
else
	# < bash v4.2
	function testv {
		test -n "${!1-}"
	}
fi
