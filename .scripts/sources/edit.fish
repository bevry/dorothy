#!/usr/bin/env fish

eval (setup-editor-commands fish)
function edit
	if is-ssh
		if is-empty-string "$TERMINAL_EDITOR"
			echo "TERMINAL_EDITOR must be configured"
		else
			eval "$TERMINAL_EDITOR" '"'$argv'"'
		end
	else
		if is-empty-string "$TERMINAL_EDITOR"
			echo "GUI_EDITOR must be configured"
		else
			eval "$GUI_EDITOR" '"'$argv'"'
		end
	end
end