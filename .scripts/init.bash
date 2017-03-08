#!/bin/bash
set -e

# Don't check mail
export MAILCHECK=0

# Path
export PATH=$HOME/.scripts/commands:$PATH
"$HOME/.scripts/commands/pathinit"

# Editor
"$HOME/.scripts/commands/editorinit"

# Extras
source "$HOME/.scripts/sources/nvm.bash"
source "$HOME/.scripts/sources/edit.bash"
source "$HOME/.scripts/sources/aliases.sh"
source "$HOME/.scripts/sources/cleaners.bash"
source "$HOME/.scripts/sources/gcloud.bash"
source "$HOME/.scripts/sources/install.bash"

if is_zsh; then
	source "$HOME/.scripts/sources/zsh.zsh"
fi

if is_file "$HOME/.scripts/env.sh"; then
	source "$HOME/.scripts/env.sh"
fi

if is_equal "$THEME" "baltheme"; then
	source "$HOME/.scripts/baltheme.sh"
fi

# SSH Keys silently
silent addsshkeys
