#!/usr/bin/env sh

if test -n "${DOROTHY_THEME-}" -a "${DOROTHY_THEME}" != 'system'; then
	if test "$DOROTHY_THEME" = 'oz'; then
		if test "$ACTIVE_LOGIN_SHELL" = 'bash'; then
			. "$DOROTHY/themes/oz"
			PROMPT_COMMAND="oztheme bash \$?"
			# ^ don't export PROMPT_COMMAND, as it will be inherited in subshells
			# so: `select-shell bash`
			# then open a new terminal
			# then enter `bash -i`
			# will error with `bash: oztheme: command not found`
		elif test "$ACTIVE_LOGIN_SHELL" = 'zsh'; then
			. "$DOROTHY/themes/oz"
			precmd() {
				# shellcheck disable=SC3043
				local last_command_exit_status="$?"
				if test ! -d "$DOROTHY"; then
					echo 'DOROTHY has been moved, please re-open your shell'
					return 1
				fi
				# export DISABLE_AUTO_TITLE="true"
				# ^ @todo
				# ^ apparently, with oh-my-zsh this is necessary,
				# ^ however, I'm not a oh-my-zsh user, so I'm unsure if this is still necessary.
				# ^ via standard zsh usage, it is not necessary.
				oztheme zsh "$last_command_exit_status"
			}
		else
			echo "dorothy does not yet support the theme [$DOROTHY_THEME] on this shell" >/dev/stderr
		fi
	elif test "$DOROTHY_THEME" = 'starship'; then
		if test "$ACTIVE_LOGIN_SHELL" = 'bash'; then
			eval "$(starship init bash)"
		elif test "$ACTIVE_LOGIN_SHELL" = 'zsh'; then
			eval "$(starship init zsh)"
		else
			# https://starship.rs/guide/#🚀-installation
			echo "dorothy does not yet support the theme [$DOROTHY_THEME] on this shell" >/dev/stderr
		fi
	elif test "$DOROTHY_THEME" = 'trial'; then
		if test "$ACTIVE_LOGIN_SHELL" = 'bash'; then
			PROMPT_COMMAND="echo -n 'DorothyTrial> '"
			# ^ don't export PROMPT_COMMAND, as it will be inherited in subshells
		elif test "$ACTIVE_LOGIN_SHELL" = 'zsh'; then
			precmd() {
				printf 'DorothyTrial> '
			}
		else
			echo "dorothy does not yet support the theme [$DOROTHY_THEME] on this shell" >/dev/stderr
		fi
	else
		echo "dorothy does not understand the theme [$DOROTHY_THEME]" >/dev/stderr
	fi
fi
