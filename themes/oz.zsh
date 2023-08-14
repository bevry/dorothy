#!/usr/bin/env zsh

source "$DOROTHY/themes/oz"
precmd() {
	local last_command_exit_status=$?
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
