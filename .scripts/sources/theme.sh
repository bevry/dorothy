#!/usr/bin/env sh

if is_equal "$THEME" "baltheme"; then
	. "$HOME/.scripts/themes/baltheme"
	if test -n "$BASH_VERSION"; then
		export PROMPT_COMMAND="baltheme bash $?"
	elif test -n "$ZSH_VERSION"; then
		function precmd {
			baltheme zsh $?
		}
	fi
fi
