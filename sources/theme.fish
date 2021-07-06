#!/usr/bin/env fish

if ! test -z "$DOROTHY_THEME" -o "$DOROTHY_THEME"  = 'system'
	if test "$DOROTHY_THEME" = 'oz'
		function fish_prompt
			"$DOROTHY/themes/oz" fish "$status"
		end
	else if test "$DOROTHY_THEME" = 'starship'
		starship init fish | source
	else if test "$DOROTHY_THEME" = 'trial'
		function fish_prompt
			echo -n 'DorothyTrial> '
		end
	else
		stderr echo "dorothy does not understand the theme [$DOROTHY_THEME]"
	end
end
