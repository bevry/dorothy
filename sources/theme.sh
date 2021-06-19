#!/usr/bin/env sh

if test "${DOROTHY_THEME-}" = "oz"; then
	. "$DOROTHY/themes/oz"
	if is-string "${BASH_VERSION-}"; then
		export PROMPT_COMMAND="oztheme bash $?"
	elif is-string "${ZSH_VERSION-}"; then
		function precmd {
			oztheme zsh "$?"
		}
	fi
fi
