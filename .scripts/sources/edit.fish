#!/usr/bin/env fish

eval (setup-editor-commands)
function edit
	if is_ssh
		if test -z "$TERMINAL_EDITOR"
			echo "\$TERMINAL_EDITOR is undefined"
		else
			eval "$TERMINAL_EDITOR" '"'$argv'"'
		end
	else
		if test -z "$TERMINAL_EDITOR"
			echo "\$GUI_EDITOR is undefined"
		else
			eval "$GUI_EDITOR" '"'$argv'"'
		end
	end
end