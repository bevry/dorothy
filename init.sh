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
# "$0" will be prefixed with '-' if {zsh,bash} login shell, so if it is {bash,zsh} it is not a login shell and should be skipped

if test -z "${DOROTHY_LOADED-}" -a "$0" != 'bash' -a "$0" != 'zsh'; then
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
