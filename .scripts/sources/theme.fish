#!/usr/bin/env fish

# Theme
if is-equal "$THEME" "baltheme"
	function fish_prompt
		~/.scripts/themes/baltheme fish $status
	end
end
