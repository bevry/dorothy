#!/usr/bin/env bash

# Don't check mail
export MAILCHECK=0

# Paths
source "$HOME/.scripts/sources/paths.sh"

# Editor
eval "$(editor_commands)"
function edit {
	if is_ssh; then
		eval "$TERMINAL_EDITOR" "$@"
	else
		eval "$GUI_EDITOR" "$@"
	fi
}

# Extras
if is_mac; then
	source "$HOME/.scripts/sources/mac.sh"
	source "$HOME/.scripts/sources/mac.bash"
elif is_linux; then
	source "$HOME/.scripts/sources/linux.sh"
	source "$HOME/.scripts/sources/linux.bash"
fi
source "$HOME/.scripts/sources/nvm.bash"
source "$HOME/.scripts/sources/aliases.sh"
source "$HOME/.scripts/sources/gcloud.bash"
source "$HOME/.scripts/sources/ssh.sh"

if is_zsh; then
	source "$HOME/.scripts/sources/zsh.zsh"
fi

if is_file "$HOME/.scripts/env.sh"; then
	source "$HOME/.scripts/env.sh"
fi

# Theme
if is_equal "$THEME" "baltheme"; then
	source "$HOME/.scripts/themes/baltheme"
	if is_bash; then
		export PROMPT_COMMAND="baltheme bash"
	elif is_zsh; then
		function precmd {
			baltheme zsh
		}
	fi
fi

# SSH Keys silently
silent addsshkeys
