#!/usr/bin/env fish
set -xg DOROTHY (dirname (status -f))
if status --is-login
	source "$DOROTHY/sources/essentials.fish"
	source "$DOROTHY/sources/extras.fish"
end
