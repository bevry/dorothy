#!/usr/bin/env sh

# Bash Completions
if test "$ACTIVE_SHELL" = 'bash'; then
	# trunk-ignore(shellcheck/SC3044)
	shopt -s progcomp # enable completions

	# default completions
	if test -f /etc/bash_completion; then
		# trunk-ignore(shellcheck/SC1091)
		. '/etc/bash_completion'
	fi

	# homebrew completions
	if test -n "${HOMEBREW_PREFIX-}" -a -f "${HOMEBREW_PREFIX-}/etc/bash_completion"; then
		# trunk-ignore(shellcheck/SC1091)
		. "$HOMEBREW_PREFIX/etc/bash_completion"
	fi
fi

# 1Password
# https://developer.1password.com/docs/cli/get-started#shell-completion
if command-exists op; then
	if test "$ACTIVE_SHELL" = 'bash'; then
		eval "$(op completion bash)"
	elif test "$ACTIVE_SHELL" = 'zsh'; then
		eval "$(op completion zsh)"
		compdef _op op
	fi
fi

# Microsoft Azure
if command-exists azure; then
	eval '<(azure --completion)'
fi

# Google Cloud SDK
# https://cloud.google.com/functions/docs/quickstart
# brew cask install google-cloud-sdk
# gcloud components install beta
# gcloud init
if test -n "${HOMEBREW_PREFIX-}"; then
	GDIR="${HOMEBREW_PREFIX}/Caskroom/google-cloud-sdk"
	if test -d "$GDIR"; then
		if test "$ACTIVE_SHELL" = 'bash'; then
			# trunk-ignore(shellcheck/SC1091)
			. "$GDIR/latest/google-cloud-sdk/path.bash.inc"
			# trunk-ignore(shellcheck/SC1091)
			. "$GDIR/latest/google-cloud-sdk/completion.bash.inc"
		elif test "$ACTIVE_SHELL" = 'zsh'; then
			# trunk-ignore(shellcheck/SC1091)
			. "$GDIR/latest/google-cloud-sdk/path.zsh.inc"
			# trunk-ignore(shellcheck/SC1091)
			. "$GDIR/latest/google-cloud-sdk/completion.zsh.inc"
		fi
	fi
fi

# Firebase SDK
# https://firebase.google.com/docs/functions/get-started
# npm install -g firebase-tools
# firebase init
