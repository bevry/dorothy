#!/bin/fish

# Don't check mail
export MAILCHECK=0

# Path
set PATH $PATH $HOME/.scripts/commands
pathinit

# Editor
editorinit

# Extras
source "$HOME/.scripts/sources/aliases.sh"

if is_file "$HOME/.scripts/env.sh"
	source "$HOME/.scripts/env.sh"
end

# SSH Keys silently
silent addsshkeys
