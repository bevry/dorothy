#!/usr/bin/env fish

eval (env -i DOROTHY="$DOROTHY" DOROTHY_USER_HOME="$DOROTHY_USER_HOME" USER="$USER" HOME="$HOME" PATH="$PATH" "$DOROTHY/commands/setup-editor-commands" fish)
function edit
	if is-ssh
		if test -z "$TERMINAL_EDITOR"
			echo "TERMINAL_EDITOR must be configured"
		else
			eval "$TERMINAL_EDITOR" '"'$argv'"'
		end
	else
		if test -z "$GUI_EDITOR"
			echo "GUI_EDITOR must be configured"
		else
			eval "$GUI_EDITOR" '"'$argv'"'
		end
	end
end