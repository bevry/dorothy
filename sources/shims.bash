#!/usr/bin/env bash

# https://www.gnu.org/software/bash/manual/bash.html#Shell-Parameter-Expansion

# Bash v5.1 and up
# dd. New `U', `u', and `L' parameter transformations to convert to uppercase,
#     convert first character to uppercase, and convert to lowercase,
#     respectively.
# https://github.com/bminor/bash/blob/9439ce094c9aa7557a9d53ac7b412a23aa66e36b/CHANGES#L562-L564

# Bash v4.2 and up
# f.  test/[/[[ have a new -v variable unary operator, which returns success if
#     `variable' has been set.
# https://github.com/bminor/bash/blob/9439ce094c9aa7557a9d53ac7b412a23aa66e36b/CHANGES#L3642-L3643

# Bash v4.0 and up
# hh. There are new case-modifying word expansions: uppercase (^[^]) and
#     lowercase (,[,]).  They can work on either the first character or
#     array element, or globally.  They accept an optional shell pattern
#     that determines which characters to modify.  There is an optionally-
#     configured feature to include capitalization operators.
# https://github.com/bminor/bash/blob/9439ce094c9aa7557a9d53ac7b412a23aa66e36b/CHANGES#L4710-L4714

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
