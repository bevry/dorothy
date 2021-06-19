#!/usr/bin/env fish

if test "$DOROTHY_THEME" = "oz"
	function fish_prompt
		"$DOROTHY/themes/oz" fish "$status"
	end
end
