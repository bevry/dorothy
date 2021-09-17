#!/usr/bin/env sh

get_shell () {
	if test -n "${ZSH_VERSION-}"; then
		echo 'zsh'
	elif test -n "${FISH_VERSION-}"; then
		echo 'fish'
	elif test -n "${BASH_VERSION-}"; then
		echo 'bash'
	elif test -n "${KSH_VERSION-}"; then
		echo 'ksh'
	elif test -n "${FCEDIT-}"; then
		echo 'ksh'
	elif test -n "${PS3-}"; then
		echo 'unknown'
	else
		echo 'sh'
	fi
}