#!/usr/bin/env sh

# bash
if test "$ACTIVE_LOGIN_SHELL" = 'bash'; then
	if test -f /etc/bash_completion; then
		. '/etc/bash_completion'
	elif test -n "${HOMEBREW_PREFIX-}" -a -f "${HOMEBREW_PREFIX-}/etc/bash_completion"; then
		. "$HOMEBREW_PREFIX/etc/bash_completion"
	fi
fi

# azure
if command-exists azure; then
	eval '<(azure --completion)'
fi

# Google Cloud SDK
# https://cloud.google.com/functions/docs/quickstart
# brew cask install google-cloud-sdk
# gcloud components install beta
# gcloud init
#
# Firebase SDK
# https://firebase.google.com/docs/functions/get-started
# npm install -g firebase-tools
# firebase init
#
if test -n "${HOMEBREW_PREFIX-}"; then
	GDIR="${HOMEBREW_PREFIX}/Caskroom/google-cloud-sdk"
	if test -d "$GDIR"; then
		if test "$ACTIVE_LOGIN_SHELL" = 'bash'; then
			. "$GDIR/latest/google-cloud-sdk/path.bash.inc"
			. "$GDIR/latest/google-cloud-sdk/completion.bash.inc"
		elif test "$ACTIVE_LOGIN_SHELL" = 'zsh'; then
			. "$GDIR/latest/google-cloud-sdk/path.zsh.inc"
			. "$GDIR/latest/google-cloud-sdk/completion.zsh.inc"
		fi
	fi
fi
