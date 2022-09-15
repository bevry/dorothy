#!/usr/bin/env bash
source "$DOROTHY/sources/bash.bash"

# https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html
# https://www.gnu.org/software/bash/manual/html_node/The-Shopt-Builtin.html
# https://github.com/bminor/bash/blob/master/CHANGES

# http://redsymbol.net/articles/unofficial-bash-strict-mode/
# https://stackoverflow.com/q/25378845/130638
# -E  errtrace    ERR trap is inherited by shell functions.
# -e  errexit     Exit immediately if a command exits with a non-zero status.
# -u  nounset     Treat unset variables as an error when substituting.
# -o  pipefail    The return value of a pipeline is the status of
#                 the last command to exit with a non-zero status,
#                 or zero if no command exited with a non-zero status
set -Eeuo pipefail

# bash v1 nullglob If set, Bash allows filename patterns which match no files to expand to a null string, rather than themselves.
# bash v2 huponexit If set, Bash will send SIGHUP to all jobs when an interactive login shell exits (see Signals).
# bash v4 globstar If set, the pattern ‘**’ used in a filename expansion context will match all files and zero or more directories and subdirectories. If the pattern is followed by a ‘/’, only directories and subdirectories match.
# bash v4.4 inherit_errexit: If set, command substitution inherits the value of the errexit option, instead of unsetting it in the subshell environment. This option is enabled when POSIX mode is enabled.
# bash v5 extglob If set, the extended pattern matching features described above (see Pattern Matching) are enabled.
shopt -s nullglob huponexit 2>/dev/null || :
shopt -s globstar 2>/dev/null || :
shopt -s inherit_errexit 2>/dev/null || :
shopt -s extglob 2>/dev/null || :

# disable completion (not needed in scripts) and failglob (nullglob is better)
# bash v2 progcomp If set, the programmable completion facilities (see Programmable Completion) are enabled. This option is enabled by default.
# bash v3 failglob If set, patterns which fail to match filenames during filename expansion result in an expansion error.
shopt -u progcomp 2>/dev/null || :
shopt -u failglob 2>/dev/null || :

# if test "$BASH_VERSION_MAJOR" -ge 5 || test "$BASH_VERSION_MAJOR" -eq 4 -a "$BASH_VERSION_MINOR" -ge 4; then

# CONSIDER
# lastpipe If set, and job control is not active, the shell runs the last command of a pipeline not executed in the background in the current shell environment.

# TIPS
# if you wish to ignore the exit code under strict mode, do:
#     command || :
# if you wish to fetch the exit code under strict mode, do:
#     ec=0; command || ec="$?"
