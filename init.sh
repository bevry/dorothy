#!/usr/bin/env sh

# WHY: test -z "${DOROTHY_LOADED-}"
#
# sometimes bash_profile and bashrc are loaded on new terminals
# sometimes bash_profile is loaded at login, and bashrc is loaded on new terminals
# sometimes bash_profile will remember and export variables, but not functions
# ^ so can't check for exported variables, ruling export `export DOROTHY_LOADED=yes`
# zsh loads zprofile, and zshrc, but forgets functions
# ^ so can't check for functions, ruling out https://stackoverflow.com/a/14467452
# so considering all that, define a normal (non global, non local) variable, and check for its existence
# no bash v3 support: if test ! -v 'DOROTHY_LOADED'; then

# WHY: "$0" != 'bash'
#
# `bash -c -- 'echo $BASH_VERSION'` was loading this script, when it shouldn't
# only `bash -lc -- 'echo $BASH_VERSION'` should attempt to load this script
# as otherwise we are loading aliases, ssh agents, and all the reset for scripts instead of login shell
# as such, we need to detect this difference
#
# if actual login shell, then for bash $0="-bash", and for zsh $0="-zsh"
# `bash -il` invocation will be $0="bash" however `shopt -qp login_shell` will return 0
# `/bin/bash -il` invocation will be $0="/bin/bash" however `shopt -qp login_shell` will return 0
# `/bin/zsh -il` invocation will be $0="/Users/balupton/.dorothy/init.sh" however [[ -o login ]] will return 0

# set -x # <debug>
DOROTHY_LOAD='no'
if test -z "${DOROTHY_LOADED-}"; then
	if test "$0" = '-bash' -o "$0" = '-zsh'; then
		DOROTHY_LOAD='yes'
	elif test "${BASH_VERISON-}"; then
		# shellcheck disable=SC3044
		if shopt -qp login_shell; then
			DOROTHY_LOAD='yes'
		fi
	elif test "${ZSH_VERSION-}"; then
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
# set +x # </debug>

if test "$DOROTHY_LOAD" = 'yes'; then
	# shellcheck disable=SC2034
	DOROTHY_LOADED='yes'
	# ^ do not export this, as that will interfere with the case where:
	#   bash_profile loads at login, then bashrc loads on new terminals

	# this should be consistent with:
	# $DOROTHY/init.fish
	# $DOROTHY/init.sh
	# $DOROTHY/commands/setup-dorothy
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
