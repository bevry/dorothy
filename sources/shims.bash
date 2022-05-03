#!/usr/bin/env bash
source "$DOROTHY/sources/bash.bash"

# https://www.gnu.org/software/bash/manual/bash.html#Shell-Parameter-Expansion
# Bash version compatibility: https://github.com/bevry/dorothy/discussions/151

# ucf = upper case first letter
# lc  = lower case all
if test "$BASH_VERSION_MAJOR" -eq 5 -a "$BASH_VERSION_MINOR" -ge 1; then
	# >= bash v5.1
	function ucf {
		echo "${1@u}"
	}
	function lc {
		echo "${1@L}"
	}
elif test "$BASH_VERSION_MAJOR" -eq 4; then
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
if test "$BASH_VERSION_MAJOR" -ge 5 || test "$BASH_VERSION_MAJOR" -eq 4 -a "$BASH_VERSION_MINOR" -ge 2; then
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
