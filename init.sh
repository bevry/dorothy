#!/usr/bin/env sh

# WHY: test -z "${DOROTHY_LOADED-}"
#
# sometimes bash_profile and bashrc are loaded on new terminals
# sometimes bash_profile is loaded at login, and bashrc is loaded on new terminals
# sometimes bash_profile will remember and export variables, but not functions
# zsh loads zprofile, and zshrc, but forgets functions
#
# As such, we need a way that will prevent double loads, but prevent inheritance.
# As functions in bash are sometimes forgotten, and functions in zsh are forgotten,
#   that rules out https://stackoverflow.com/a/14467452 for this purpose.
# And as exported variables will be inherited by subshells, that rules out exported variables.
# As such, checking for the existence of a non-global non-local variable will work for this case.
# Note that bash v3 does not support `test ! -v 'DOROTHY_LOADED'`, so have to use `test -z "${DOROTHY_LOADED-}"``

# WHY: "$0" != 'bash'
#
# Sometimes, non-login shell invocations will attempt to load this script:
# - `bash -c -- 'echo $BASH_VERSION'`
# - `zsh -c -- 'echo $BASH_VERSION'`
#
# Whereas only true login shells should, as well as manual login shell invocations:
# - `bash -lc -- 'echo $BASH_VERSION'`
# - `zsh -lc -- 'echo $BASH_VERSION'`
#
# As such, we need to detect this difference, here are the samples:
#
# A true bash login shell (v3):
# - `$0` is `-bash`
# - `$-` is `himBH` via this script and manully, or if v5 then `himBHs` manually
# - `shopt -qp login_shell` returns `0`
#
# Manual invocation `bash -il` (v5):
# - `$0` is `bash`
# - `$-` is `himBH` via this script, then `himBHs` manually
# - `shopt -qp login_shell` returns `0`
#
# Manual invocation `/bin/bash -il` (v3) and `/usr/local/bin/bash -il` (v5):
# - `$0` is bash location: `/bin/bash`
# - `$-` is "himBH" via this script and manually
# - `shopt -qp login_shell` returns `0`
#
# A true zsh login shell:
# - `$0` is `-zsh`
# - `$-` is `569XZilm` via this script, then `569XZilms` manually
# - `[[ -o login ]]` returns `0`
#
# Manual invocation of zsh login shell via `/bin/zsh -il`:
# - `$0` is current script then zsh location
# - `$-` is `569XZilm` via this script, then `569XZilms` manually
# - `[[ -o login ]]` returns `0`
#
# Manual invocation of zsh non-login shell via `/bin/zsh -i`:
# - `$0` is current script then zsh location
# - `$-` is `569XZim` via this script, then `569XZims` manually
# - `[[ -o login ]]` returns `0`

# set -x # <debug>
# printf '$0 = %s\n$- = %s\n' "$0" "$-"
DOROTHY_LOAD='no'
if test -z "${DOROTHY_LOADED-}"; then
	if test "$0" = '-bash' -o "$0" = '-zsh'; then
		DOROTHY_LOAD='yes'
	elif test -n "${BASH_VERSION-}"; then
		# shellcheck disable=SC3044
		if shopt -qp login_shell; then
			DOROTHY_LOAD='yes'
		fi
	elif test -n "${ZSH_VERSION-}"; then
		# shellcheck disable=SC3010
		if [[ -o login ]]; then
			DOROTHY_LOAD='yes'
		fi
	else
		# bash v3 does not set l in $-
		# zsh does, however zsh we have a definite option earlier
		# so this is for the alternative posix shells
		case $- in *l*) DOROTHY_LOAD='yes' ;; esac
	fi
fi
# printf '$DOROTHY_LOAD = %s\n' "$DOROTHY_LOAD"
# set +x # </debug>

if test "$DOROTHY_LOAD" = 'yes'; then
	# shellcheck disable=SC2034
	DOROTHY_LOADED='yes'
	# ^ do not export this, as that will interfere with the case where:
	#   bash_profile loads at login, then bashrc loads on new terminals

	# this should be consistent with:
	# $DOROTHY/init.fish
	# $DOROTHY/init.sh
	# $DOROTHY/commands/dorothy
	if test -z "${DOROTHY-}"; then
		# https://stackoverflow.com/a/246128
		# https://stackoverflow.com/a/14728194
		export DOROTHY
		# shellcheck disable=SC3028
		DOROTHY="$(dirname "${BASH_SOURCE:-"$0"}")"
	fi

	. "$DOROTHY/sources/init.sh"
	. "$DOROTHY/sources/shell.sh"
fi
