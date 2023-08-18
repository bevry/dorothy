#!/usr/bin/env fish

# load each filename
# passes if one or more were loaded
# fails if none were loaded (all were missing)
# autocomplete... provides:
# AUTOCOMPLETE_1PASSWORD_CLI
# AUTOCOMPLETE_AZURE
# AUTOCOMPLETE_TEA
# AUTOCOMPLETE_VSCODE
load_dorothy_config 'autocomplete.fish' 'autocomplete.sh'

# 1Password CLI
# https://developer.1password.com/docs/cli/get-started#shell-completion
if test "$AUTOCOMPLETE_1PASSWORD_CLI" != 'no' && command-exists op
	op completion fish | source
end

# Microsoft Azure
if test "$AUTOCOMPLETE_AZURE" != 'no' && command-exists azure
	azure --completion-fish | source
end

# Tea
# https://docs.tea.xyz/features/magic#using-magic-in-shell-scripts
# https://github.com/teaxyz/setup/blob/034d006136f423357f17eab90a51c04696582f4a/install.sh#L423-L451
if test "$AUTOCOMPLETE_TEA" != 'no' && command-exists tea
	tea --magic=fish --silent | source
end

# Visual Studio Code Terminal Shell Integration
# https://code.visualstudio.com/docs/terminal/shell-integration#_manual-installation
if test "$AUTOCOMPLETE_VSCODE" != 'no' -a "$TERM_PROGRAM" = "vscode"
	. (code --locate-shell-integration-path fish)
end
