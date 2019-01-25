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