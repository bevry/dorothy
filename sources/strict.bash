#!/usr/bin/env bash
source "$DOROTHY/sources/bash.bash"

# -E  ERR trap is inherited by shell functions.
#     https://stackoverflow.com/q/25378845/130638
# -e  Exit immediately if a command exits with a non-zero status.
# -u  Treat unset variables as an error when substituting.
# -o  pipefail    the return value of a pipeline is the status of
#                 the last command to exit with a non-zero status,
#                 or zero if no command exited with a non-zero status
#
# https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html
# http://redsymbol.net/articles/unofficial-bash-strict-mode/

set -Eeuo pipefail

# inherit_errexit: If set, command substitution inherits the value of the errexit option, instead of unsetting it in the subshell environment. This option is enabled when POSIX mode is enabled.
#
# https://www.gnu.org/software/bash/manual/html_node/The-Shopt-Builtin.html
# https://github.com/koalaman/shellcheck/wiki/SC2311

if test "$BASH_VERSION_MAJOR" -ge 5 || test "$BASH_VERSION_MAJOR" -eq 4 -a "$BASH_VERSION_MINOR" -ge 4; then
	# https://github.com/bminor/bash/blob/9439ce094c9aa7557a9d53ac7b412a23aa66e36b/CHANGES#L1771-L1773
	# >= bash v4.4
	shopt -s inherit_errexit
fi

# failglob: If set, patterns which fail to match filenames during filename expansion result in an expansion error.
# ^ consider this, as without it, failed expansions turning into arrays of length 1 and empty string has caught me offguard

# if you wish to ignore the exit code under strict mode, do:
# command || :

# if you wish to fetch the exit code under strict mode, do:
# ec=0; command || ec="$?"
