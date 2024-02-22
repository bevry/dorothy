#!/usr/bin/env fish

function fish_prompt
	set last_command_exit_status "$status"
	if test ! -d "$DOROTHY"
		echo 'DOROTHY has been moved, please re-open your shell'
		return 1
	end
	"$DOROTHY/themes/oz" fish "$last_command_exit_status"
end
