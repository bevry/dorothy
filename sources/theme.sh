#!/usr/bin/env sh

if ! test -z "${DOROTHY_THEME-}" -o "${DOROTHY_THEME}" = 'system'; then
	if test "${DOROTHY_THEME}" = 'oz'; then
		if test -n "${BASH_VERSION-}"; then
			. "$DOROTHY/themes/oz"
			export PROMPT_COMMAND="oztheme bash \$?"
		elif test -n "${ZSH_VERSION-}"; then
			. "$DOROTHY/themes/oz"
			precmd () {
				oztheme zsh "$?"
			}
		else
			stderr echo "dorothy does not yet support the theme [$DOROTHY_THEME] on this shell"
		fi
	elif test "${DOROTHY_THEME}" = 'starship'; then
		if test -n "${BASH_VERSION-}"; then
			eval "$(starship init bash)"
		elif test -n "${ZSH_VERSION-}"; then
			eval "$(starship init zsh)"
		else
			# https://starship.rs/guide/#🚀-installation
			stderr echo "dorothy does not yet support the theme [$DOROTHY_THEME] on this shell"
		fi
	elif test "${DOROTHY_THEME}" = 'trial'; then
		if test -n "${BASH_VERSION-}"; then
			export PROMPT_COMMAND="echo -n 'DorothyTrial> '"
		elif test -n "${ZSH_VERSION-}"; then
			precmd () {
				echo -n 'DorothyTrial> '
			}
		else
			stderr echo "dorothy does not yet support the theme [$DOROTHY_THEME] on this shell"
		fi
	else
		stderr echo "dorothy does not understand the theme [$DOROTHY_THEME]"
	fi
fi
