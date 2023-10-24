#!/usr/bin/env fish

# load each filename
# passes if one or more were loaded
# fails if none were loaded (all were missing)
# autocomplete... provides:
# AUTOCOMPLETE_TEA
# AUTOCOMPLETE_VSCODE
load_dorothy_config 'autocomplete.fish' 'autocomplete.sh'

# Tea
# https://docs.tea.xyz/features/magic#using-magic-in-shell-scripts
# https://github.com/teaxyz/setup/blob/034d006136f423357f17eab90a51c04696582f4a/install.sh#L423-L451
if test "$AUTOCOMPLETE_TEA" != 'no' && command-exists tea
	tea --magic=fish --silent | source
end

# Visual Studio Code Terminal Shell Integration
# https://code.visualstudio.com/docs/terminal/shell-integration#_manual-installation
if test "$AUTOCOMPLETE_VSCODE" != 'no' -a "$TERM_PROGRAM" = 'vscode' && command-exists code
	. (code --locate-shell-integration-path fish)
end

# https://rsteube.github.io/carapace-bin/setup.html#fish
if command-exists carapace
	carapace _carapace fish | source
end
