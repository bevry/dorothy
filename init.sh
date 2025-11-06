#!/usr/bin/env sh

# WHY: -z "${DOROTHY_LOADED-}"
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
# Note that bash v3 does not support `! [ -v 'DOROTHY_LOADED'`], so have to use `[ -z "${DOROTHY_LOADED-}"]`

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
# - `$-` is `himBH` via this script and manually, or if v5 then `himBHs` manually
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

if [ -n "${DOROTHY_FORCE_LOAD-}" ]; then
	DOROTHY_LOAD="$DOROTHY_FORCE_LOAD"
else
	DOROTHY_LOAD='no' # this must be outside the below if, to ensure DOROTHY_LOAD is reset, and DOROTHY_LOADED is respected, otherwise posix shells may double load due to cross-compat between dotfiles (.profile along with whatever they support)
	if [ -z "${DOROTHY_LOADED_SHARED_SCOPE-}" ]; then
		# `-dash` is macos login shell, `dash` is manual `dash -l` invocation (as $- doesn't include l in dash)
		# NVIM here because it sets $0 as whichever shell invoked Neovim: https://github.com/bevry/dorothy/pull/279$0
		if [ "$0" = '-bash' ] || [ "$0" = '-zsh' ] || [ "$0" = '-dash' ] || [ "$0" = 'dash' ] || [ -n "${NVIM-}" ]; then
			DOROTHY_LOAD='yes'
		elif [ -n "${BASH_VERSION-}" ]; then
			# trunk-ignore(shellcheck/SC3044)
			if shopt -qp login_shell; then
				DOROTHY_LOAD='yes'
			elif [ "$-" = 'himBH' ] && [ "${DOROTHY_LOADED_EXPORT_SCOPE-}" != 'yes' ]; then
				case "${GIO_LAUNCHED_DESKTOP_FILE-}" in *lxterminal*) DOROTHY_LOAD='yes' ;; esac
			fi
		elif [ -n "${ZSH_VERSION-}" ]; then
			# trunk-ignore(shellcheck/SC3010)
			# trunk-ignore(shellcheck/SC3062)
			if [[ -o login ]]; then
				DOROTHY_LOAD='yes'
			fi
		elif [ -z "$-" ] && [ -z "$*" ] && [ "${CI-}" = 'true' ]; then
			DOROTHY_LOAD='yes' # dash on github ci, in which [$-] and [$*] are empty, and $0 = /home/runner....
		else
			# bash v3 and dash do not set l in $-
			# zsh does, however zsh we have a definite option earlier
			# so this is for the alternative posix shells
			case $- in *l*) DOROTHY_LOAD='yes' ;; esac
		fi
	fi
fi

# if your login shell is failing identification,
# then make sure your terminal preferences has login shell enabled
if [ "${DOROTHY_LOAD-}" = 'yes' ]; then
	# non-exported scope, used to prevent case where bash_profile loads at login then bashrc loads on new terminal
	DOROTHY_LOADED_SHARED_SCOPE='yes'
	# exported scope, used to prevent our workaround for non-login-terminal-applications from loading dorothy in manual non-login bash invocations
	export DOROTHY_LOADED_EXPORT_SCOPE
	DOROTHY_LOADED_EXPORT_SCOPE='yes'

	# this should be consistent with:
	# $DOROTHY/init.fish
	# $DOROTHY/init.sh
	# $DOROTHY/commands/dorothy
	if [ -z "${DOROTHY-}" ]; then
		# https://stackoverflow.com/a/246128
		# https://stackoverflow.com/a/14728194
		# if true login shell on macos, then $0 is [-bash], [-zsh], [-dash], etc.
		export DOROTHY
		# this should somewhat coincide with [prepare_dorothy] in [dorothy]
		if [ -n "${XDG_DATA_HOME-}" ] && [ -d "$XDG_DATA_HOME/dorothy" ]; then
			DOROTHY="$XDG_DATA_HOME/dorothy"
		else
			DOROTHY="$HOME/.local/share/dorothy"
		fi
	fi

	# init dorothy's environment for the login shell
	. "$DOROTHY/sources/login.sh"

	# if the login shell is also interactive, then init dorothy for the interactive login shell
	# [-t 0] and [-s] are true despite [env -i bash -lc ...]
	case $- in *i*) . "$DOROTHY/sources/interactive.sh" ;; esac
fi
