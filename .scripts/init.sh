#!/usr/bin/env bash

# Don't check mail
export MAILCHECK=0

# Paths
if test -n "$ZSH_VERSION"; then
	source "$HOME/.scripts/sources/var.zsh"
else
	source "$HOME/.scripts/sources/var.bash"
fi
source "$HOME/.scripts/sources/user.sh"
source "$HOME/.scripts/sources/paths.sh"

# Editor
eval "$(setup-editor-commands)"
function edit {
	if is_ssh; then
		if test -z "$TERMINAL_EDITOR"; then
			echo "\$TERMINAL_EDITOR is undefined"
		else
			eval "$TERMINAL_EDITOR" "$@"
		fi
	else
		if test -z "$GUI_EDITOR"; then
			echo "\$GUI_EDITOR is undefined"
		else
			eval "$GUI_EDITOR" "$@"
		fi
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
source "$HOME/.scripts/sources/ssh.sh"
source "$HOME/.scripts/sources/gcloud.sh"
source "$HOME/.scripts/sources/secure.sh"

if test -n "$ZSH_VERSION"; then
	source "$HOME/.scripts/sources/zsh.zsh"
	source "$HOME/.scripts/sources/azure.zsh"
else
	source "$HOME/.scripts/sources/azure.bash"
fi

if is_file "$HOME/.scripts/env.sh"; then
	source "$HOME/.scripts/env.sh"
fi

# Theme
if is_equal "$THEME" "baltheme"; then
	source "$HOME/.scripts/themes/baltheme"
	if test -n "$BASH_VERSION"; then
		export PROMPT_COMMAND="baltheme bash $?"
	elif test -n "$ZSH_VERSION"; then
		function precmd {
			baltheme zsh $?
		}
	fi
fi
