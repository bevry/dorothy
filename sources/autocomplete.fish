#!/usr/bin/env fish

# load each filename
# passes if one or more were loaded
# fails if none were loaded (all were missing)
# autocomplete... provides:
# AUTOCOMPLETE_TEA
# AUTOCOMPLETE_VSCODE
load_dorothy_config 'autocomplete.fish' 'autocomplete.sh'

# Visual Studio Code Terminal Shell Integration
# https://code.visualstudio.com/docs/terminal/shell-integration#_manual-installation
if test "$AUTOCOMPLETE_VSCODE" != 'no' -a "$TERM_PROGRAM" = 'vscode' && command-exists -- code
	. (code --locate-shell-integration-path fish)
end

# Carapace
# https://carapace-sh.github.io/carapace-bin/setup.html#fish
if command-exists -- carapace
	carapace _carapace fish | source
end
