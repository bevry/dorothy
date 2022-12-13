#!/usr/bin/env bash

# Thread that discusses and tracks bash version compatibility:
# https://github.com/bevry/dorothy/discussions/151

# -------------------------------------
# Version Extraction

if test -z "${BASH_VERSION_LATEST-}"; then
	# If there is ever a double digit version part, we can change this, until then, this is perfect
	BASH_VERSION_MAJOR="${BASH_VERSION:0:1}"
	BASH_VERSION_MINOR="${BASH_VERSION:2:1}"
	if test "$BASH_VERSION_MAJOR" = '5'; then
		BASH_VERSION_LATEST='yes' # any v5 version is good enough
	else
		BASH_VERSION_LATEST='no'
	fi

	function require_latest_bash {
		if test "$BASH_VERSION_LATEST" = 'no'; then
			echo-style \
				--code="$0" --error=" is incompatible with " --code="bash $BASH_VERSION" $'\n' \
				"Run " --bold="setup-util-bash" " to upgrade capabilities, then run the prior command again." >/dev/stderr
			return 95 # Operation not supported
		fi
	}
fi

# -------------------------------------
# Strict Mode

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
if shopt -s nullglob 2>/dev/null; then
	function require_nullglob {
		true
	}
else
	function require_nullglob {
		echo-style --error="Missing nullglob support:"
		require_latest_bash
	}
fi

# bash v2 huponexit If set, Bash will send SIGHUP to all jobs when an interactive login shell exits (see Signals).
shopt -s huponexit 2>/dev/null || :

# bash v4 globstar If set, the pattern ‘**’ used in a filename expansion context will match all files and zero or more directories and subdirectories. If the pattern is followed by a ‘/’, only directories and subdirectories match.
if shopt -s globstar 2>/dev/null; then
	function require_globstar {
		true
	}
else
	function require_globstar {
		echo-style --error="Missing globstar support:"
		require_latest_bash
	}
fi

# bash v4.4 inherit_errexit: If set, command substitution inherits the value of the errexit option, instead of unsetting it in the subshell environment. This option is enabled when POSIX mode is enabled.
shopt -s inherit_errexit 2>/dev/null || :

# bash v5 extglob If set, the extended pattern matching features described above (see Pattern Matching) are enabled.
if shopt -s extglob 2>/dev/null; then
	function require_extglob {
		true
	}
else
	function require_extglob {
		echo-style --error="Missing extglob support:"
		require_latest_bash
	}
fi

# disable completion (not needed in scripts) and failglob (nullglob is better)
# bash v2 progcomp If set, the programmable completion facilities (see Programmable Completion) are enabled. This option is enabled by default.
# bash v3 failglob If set, patterns which fail to match filenames during filename expansion result in an expansion error.
shopt -u progcomp 2>/dev/null || :
shopt -u failglob 2>/dev/null || :

# if test "$BASH_VERSION_MAJOR" -ge 5 || test "$BASH_VERSION_MAJOR" -eq 4 -a "$BASH_VERSION_MINOR" -ge 4; then

# CONSIDER
# lastpipe If set, and job control is not active, the shell runs the last command of a pipeline not executed in the background in the current shell environment.
# bash v5 localvar_inherit: If set, local variables inherit the value and attributes of a variable of the same name that exists at a previous scope before any new value is assigned. The nameref attribute is not inherited.
# shopt -s localvar_inherit 2>/dev/null || :

# TIPS
# if you wish to ignore the exit code under strict mode, do:
#     command || :
# if you wish to fetch the exit code under strict mode, do:
#     ec=0; command || ec="$?"

# -------------------------------------
# Shell Paramater Expansions

# https://www.gnu.org/software/bash/manual/bash.html#Shell-Parameter-Expansion
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

# -------------------------------------
# test a variable is defined: test -v

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

# -------------------------------------
# Arrays
# This was some amazing work by balupton, if you extract it, be sure to thank him

function has_array_support {
	for arg in "$@"; do
		if [[ $ARRAYS != *" $arg"* ]]; then
			return 1
		fi
	done
}

function require_array {
	if ! has_array_support "$@"; then
		echo-style --error="Array support insufficient, required: " --code="$*"
		require_latest_bash
	fi
}

ARRAYS=''
if test "$BASH_VERSION_MAJOR" -ge '5'; then
	ARRAYS+=' mapfile[native] readarray[native] empty[native]'
	if test "$BASH_VERSION_MINOR" -ge '1'; then
		ARRAYS+=' associative'
	fi
elif test "$BASH_VERSION_MAJOR" -ge '4'; then
	ARRAYS+=' mapfile[native] readarray[native]'
	if test "$BASH_VERSION_MINOR" -ge '4'; then
		ARRAYS+=' empty[native]'
	else
		ARRAYS+=' empty[shim]'
		set +u # disable nounset to prevent crashes on empty arrays
	fi
elif test "$BASH_VERSION_MAJOR" -ge '3'; then
	ARRAYS+=' mapfile[shim] empty[shim]'
	set +u # disable nounset to prevent crashes on empty arrays
	# bash v4 features:
	# - `readarray` and `mapfile`
	#     - our shim provides a workaround
	# - associative arrays
	#     - no workaround, you are out of luck
	# - iterating empty arrays:
	#     - broken: `arr=(); for item in "${arr[@]}"; do ...`
	#     - broken: `arr=(); for item in "${!arr[@]}"; do ...`
	#     - use: `test "${#array[@]}" -ne 0 && for ...`
	#     - or if you don't care for empty elements, use: `test -n "$arr" && for ...`
	function mapfile {
		# if you copy and paste this, please give credit:
		# written by Benjamin Lupton https://balupton.com
		# written for Dorothy https://github.com/bevry/dorothy
		local delim=$'\n' item
		if test "$1" = '-t'; then
			shift
		elif test "$1" = '-td'; then
			shift
			delim="$1"
			shift
		fi
		eval "$1=()"
		while IFS= read -rd "$delim" item || test -n "$item"; do
			eval "$1+=($(echo-quote "$item"))"
		done
	}
fi
ARRAYS+=' '
