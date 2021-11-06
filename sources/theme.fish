#!/usr/bin/env fish

if test -n "$DOROTHY_THEME" -a "$DOROTHY_THEME"  != 'system'
	if test "$DOROTHY_THEME" = 'oz'
		function fish_prompt
			set last_command_exit_status "$status"
			if test ! -d "$DOROTHY"
				echo 'DOROTHY has been moved, please re-open your shell'
				return 1
			end
			"$DOROTHY/themes/oz" fish "$last_command_exit_status"
		end
	else if test "$DOROTHY_THEME" = 'starship'
		starship init fish | source
	else if test "$DOROTHY_THEME" = 'trial'
		function fish_prompt
			printf 'DorothyTrial> '
		end
	else
		stderr echo "dorothy does not understand the theme [$DOROTHY_THEME]"
	end
end
