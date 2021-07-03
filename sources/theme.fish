#!/usr/bin/env fish

if test "$DOROTHY_THEME" = 'oz'
	function fish_prompt
		"$DOROTHY/themes/oz" fish "$status"
	end
else if test "$DOROTHY_THEME" = 'starship'
	starship init fish | source
end
