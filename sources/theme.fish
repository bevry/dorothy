#!/usr/bin/env fish

if test -n "$DOROTHY_THEME" -a "$DOROTHY_THEME" != 'system'
	if test -f "$DOROTHY/user/themes/$DOROTHY_THEME.fish"
		source "$DOROTHY/user/themes/$DOROTHY_THEME.fish"
	else if test -f "$DOROTHY/themes/$DOROTHY_THEME.fish"
		source "$DOROTHY/themes/$DOROTHY_THEME.fish"
	else
		echo-style --notice="Dorothy theme [$DOROTHY_THEME] is not supported by this shell [fish]" >/dev/stderr
	end
end
