#!/usr/bin/env bash
# Imports ACTIVE_POSIX_SHELL

# load each filename
# passes if one or more were loaded
# fails if none were loaded (all were missing)
# autocomplete... provides:
# AUTOCOMPLETE_GITHUB_COPILOT_CLI
# AUTOCOMPLETE_TEA
# AUTOCOMPLETE_VSCODE
load_dorothy_config "autocomplete.$ACTIVE_POSIX_SHELL" 'autocomplete.sh'

# Enable Completions
shopt -s progcomp

# GitHub Copilot CLI
# https://www.npmjs.com/package/@githubnext/github-copilot-cli
if [[ ${AUTOCOMPLETE_GITHUB_COPILOT_CLI-} != 'no' ]] && command-exists -- github-copilot-cli; then
	eval "$(github-copilot-cli alias -- "$ACTIVE_POSIX_SHELL")"
fi

# Tea
# https://docs.tea.xyz/features/magic#using-magic-in-shell-scripts
# https://github.com/teaxyz/setup/blob/034d006136f423357f17eab90a51c04696582f4a/install.sh#L423-L451
if [[ ${AUTOCOMPLETE_TEA-} != 'no' ]] && command-exists -- tea; then
	eval "$(tea --magic="$ACTIVE_POSIX_SHELL" --silent)"
fi

# Visual Studio Code Terminal Shell Integration
# https://code.visualstudio.com/docs/terminal/shell-integration#_manual-installation
if [[ ${AUTOCOMPLETE_VSCODE-} != 'no' && ${TERM_PROGRAM-} == 'vscode' ]] && command-exists -- code; then
	. "$(code --locate-shell-integration-path "$ACTIVE_POSIX_SHELL")"
fi

# Carapace
if command-exists -- carapace; then
	# https://rsteube.github.io/carapace-bin/setup.html#bash
	. <(carapace _carapace bash)
fi
