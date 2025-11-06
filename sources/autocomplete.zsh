#!/usr/bin/env zsh
# Imports ACTIVE_POSIX_SHELL

# load each filename
# passes if one or more were loaded
# fails if none were loaded (all were missing)
# autocomplete... provides:
# AUTOCOMPLETE_VSCODE
load_dorothy_config "autocomplete.$ACTIVE_POSIX_SHELL" 'autocomplete.sh'

# Enable Completions
autoload -Uz compinit
compinit

# Visual Studio Code Terminal Shell Integration
# https://code.visualstudio.com/docs/terminal/shell-integration#_manual-installation
if [[ "${AUTOCOMPLETE_VSCODE-}" != 'no' && "${TERM_PROGRAM-}" = 'vscode' ]] && command-exists -- code; then
	source "$(code --locate-shell-integration-path "$ACTIVE_POSIX_SHELL")"
fi

# Carapace
# https://carapace-sh.github.io/carapace-bin/setup.html#zsh
if command-exists -- carapace; then
	zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
	source <(carapace _carapace zsh)
fi
