#!/usr/bin/env sh
# Imports ACTIVE_POSIX_SHELL

# Load the configuration for interactive shells
if test "$ACTIVE_POSIX_SHELL" = 'sh'; then
	load_dorothy_config 'autocomplete.sh'
else
	# load each filename
	# passes if one or more were loaded
	# fails if none were loaded (all were missing)
	# autocomplete... provides:
	# AUTOCOMPLETE_1PASSWORD_CLI
	# AUTOCOMPLETE_AZURE
	# AUTOCOMPLETE_BASH
	# AUTOCOMPLETE_GCLOUD
	# AUTOCOMPLETE_GITHUB_COPILOT_CLI
	# AUTOCOMPLETE_TEA
	# AUTOCOMPLETE_VSCODE
	load_dorothy_config "autocomplete.$ACTIVE_POSIX_SHELL" 'autocomplete.sh'
fi

# 1Password CLI
# https://developer.1password.com/docs/cli/get-started#shell-completion
if test "${AUTOCOMPLETE_1PASSWORD_CLI-}" != 'no' && command-exists op; then
	if test "$ACTIVE_POSIX_SHELL" = 'bash'; then
		eval "$(op completion bash)"
	elif test "$ACTIVE_POSIX_SHELL" = 'zsh'; then
		eval "$(op completion zsh)"
		compdef _op op
	fi
fi

# Microsoft Azure
if test "${AUTOCOMPLETE_AZURE-}" != 'no' && command-exists azure; then
	eval "$(azure --completion)"
fi

# Bash Completions
if test "${AUTOCOMPLETE_BASH-}" != 'no' -a "$ACTIVE_POSIX_SHELL" = 'bash'; then
	# enable completions
	# trunk-ignore(shellcheck/SC3044)
	shopt -s progcomp # enable bash completions feature

	# load bash default completions
	if test -f /etc/bash_completion; then
		. '/etc/bash_completion'
	fi

	# load installed bash-completions
	if test -n "${HOMEBREW_PREFIX-}" -a -f "${HOMEBREW_PREFIX-}/etc/bash_completion"; then
		. "$HOMEBREW_PREFIX/etc/bash_completion"
	elif test -f '/etc/profile.d/bash_completion.sh'; then
		. '/etc/profile.d/bash_completion.sh'
	fi

	# apt utility completions go to /usr/share, e.g.
	# /usr/share/bash-completion/completions/fd.bash
	# @todo add support for all of these somehow
fi

# Google Cloud SDK
# https://cloud.google.com/functions/docs/quickstart
# brew cask install google-cloud-sdk
# gcloud components install beta
# gcloud init
if test "${AUTOCOMPLETE_GCLOUD-}" != 'no' -a -n "${HOMEBREW_PREFIX-}"; then
	GDIR="${HOMEBREW_PREFIX}/Caskroom/google-cloud-sdk"
	if test -d "$GDIR"; then
		if test "$ACTIVE_POSIX_SHELL" = 'bash'; then
			. "$GDIR/latest/google-cloud-sdk/path.bash.inc"
			. "$GDIR/latest/google-cloud-sdk/completion.bash.inc"
		elif test "$ACTIVE_POSIX_SHELL" = 'zsh'; then
			. "$GDIR/latest/google-cloud-sdk/path.zsh.inc"
			. "$GDIR/latest/google-cloud-sdk/completion.zsh.inc"
		fi
	fi
fi

# GitHub Copilot CLI
# https://www.npmjs.com/package/@githubnext/github-copilot-cli
if test "${AUTOCOMPLETE_GITHUB_COPILOT_CLI-}" != 'no' && command-exists github-copilot-cli; then
	eval "$(github-copilot-cli alias -- "$ACTIVE_POSIX_SHELL")"
fi

# Tea
# https://docs.tea.xyz/features/magic#using-magic-in-shell-scripts
# https://github.com/teaxyz/setup/blob/034d006136f423357f17eab90a51c04696582f4a/install.sh#L423-L451
if test "${AUTOCOMPLETE_TEA-}" != 'no' && command-exists tea; then
	if test "$ACTIVE_POSIX_SHELL" = 'zsh' -o "$ACTIVE_POSIX_SHELL" = 'bash'; then
		eval "$(tea --magic="$ACTIVE_POSIX_SHELL" --silent)"
	fi
fi

# Visual Studio Code Terminal Shell Integration
# https://code.visualstudio.com/docs/terminal/shell-integration#_manual-installation
if test "${AUTOCOMPLETE_VSCODE-}" != 'no' -a "$TERM_PROGRAM" = "vscode"; then
	. "$(code --locate-shell-integration-path "$ACTIVE_POSIX_SHELL")"
fi
