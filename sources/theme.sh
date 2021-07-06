#!/usr/bin/env sh

if test "${DOROTHY_THEME-}" = 'oz'; then
	if is-string "${BASH_VERSION-}"; then
		export PROMPT_COMMAND="oztheme bash $?"
	elif is-string "${ZSH_VERSION-}"; then
		. "$DOROTHY/themes/oz"
		precmd () {
			oztheme zsh "$?"
		}
	else
		stderr echo 'dorothy does not yet support the oz theme on this shell'
	fi
elif test "${DOROTHY_THEME-}" = 'starship'; then
	if is-string "${BASH_VERSION-}"; then
		eval "$(starship init bash)"
	elif is-string "${ZSH_VERSION-}"; then
		eval "$(starship init zsh)"
	else
		# https://starship.rs/guide/#🚀-installation
		stderr echo 'dorothy does not yet support the starship theme on this shell'
	fi
fi
