#!/usr/bin/env fish

# Theme
if is-equal "$THEME" "baltheme"
	function fish_prompt
		"$BDIR/themes/baltheme" fish "$status"
	end
end
