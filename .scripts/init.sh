#!/usr/bin/env bash

# Don't check mail
export MAILCHECK=0

# Paths
source "$HOME/.scripts/sources/var.sh"
var_add PATH "$HOME/.scripts/commands"
function paths_init {
	eval "$(paths_commands)"
}
paths_init

# Extras
eval "$(editor_commands)"
source "$HOME/.scripts/sources/mac.bash"
source "$HOME/.scripts/sources/linux.bash"
source "$HOME/.scripts/sources/nvm.bash"
source "$HOME/.scripts/sources/aliases.sh"
source "$HOME/.scripts/sources/gcloud.bash"
source "$HOME/.scripts/sources/install.bash"

if is_zsh; then
	source "$HOME/.scripts/sources/zsh.zsh"
fi

if is_file "$HOME/.scripts/env.sh"; then
	source "$HOME/.scripts/env.sh"
fi

if is_equal "$THEME" "baltheme"; then
	source "$HOME/.scripts/themes/baltheme"
	if is_bash; then
		export PROMPT_COMMAND="baltheme"
	elif is_zsh; then
		function precmd {
			baltheme
		}
	fi
fi

# SSH Keys silently
silent addsshkeys
