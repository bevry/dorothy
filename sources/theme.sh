#!/usr/bin/env sh

if is-equal "${THEME:-}" "baltheme"; then
	. "$BDIR/themes/baltheme"
	if is-string "${BASH_VERSION:-}"; then
		export PROMPT_COMMAND="baltheme bash $?"
	elif is-string "${ZSH_VERSION:-}"; then
		function precmd {
			baltheme zsh "$?"
		}
	fi
fi
