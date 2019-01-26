#!/usr/bin/env sh

function getshell {
	if is-string "${ZSH_VERSION:-}"; then
		echo 'zsh'
	elif is-string "${FISH_VERSION:-}"; then
		echo 'fish'
	elif is-string "${BASH_VERSION:-}"; then
		echo 'bash'
	elif is-string "${KSH_VERSION:-}"; then
		echo 'ksh'
	elif is-string "${FCEDIT:-}"; then
		echo 'ksh'
	elif is-string "${PS3:-}"; then
		echo 'unknown'
	else
		echo 'sh'
	fi
}