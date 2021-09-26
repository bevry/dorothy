#!/usr/bin/env bash

# -E  ERR trap is inherited by shell functions.
#     https://stackoverflow.com/q/25378845/130638
# -e  Exit immediately if a command exits with a non-zero status.
# -u  Treat unset variables as an error when substituting.
# -o  pipefail    the return value of a pipeline is the status of
#                 the last command to exit with a non-zero status,
#                 or zero if no command exited with a non-zero status
# https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html
# http://redsymbol.net/articles/unofficial-bash-strict-mode/

set -Eeuo pipefail

# the below functions are essential to prevent nested functions that check for exit codes
# from having their set -e negate a parent set +e, which would cause a return 1 on the function call
# to cause to the program to exit immediately, as the parents set +e was negated by the child's set -e
# as such, the below returns the state of the current e status, and restores to it

# strict_e_pause; local eo="$?"
# ... command ...
# local ec="$?"; strict_e_restore "$eo"
# if test "$ec" -ne 0; then

# alternatively you don't need to do this, you can just do this
# local ec=0; command || ec="$?"
# if test "$ec" -ne 0; then
#
# note, don't do ( var= ) or ( read ) because the vars won't escape the subshell

function strict_e_pause () {
	if [[ "$-" = *e* ]]; then
		set +e
		return 1
	else
		set +e
		return 0
	fi
}

function strict_e_restore () {
	if test "$1" -eq 1; then
		set -e
	fi
}
