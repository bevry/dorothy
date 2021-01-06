#!/usr/bin/env fish

if is-equal "$DOROTHY_THEME" "oz"
	function fish_prompt
		"$DOROTHY/themes/oz" fish "$status"
	end
end
