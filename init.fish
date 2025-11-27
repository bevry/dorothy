#!/usr/bin/env fish

# this should be consistent with:
# $DOROTHY/init.*
# $DOROTHY/commands/dorothy
if ! set -q DOROTHY
	set -xg DOROTHY (dirname (status -f))
end

if status --is-login
	source "$DOROTHY/sources/environment.fish"
	if status --is-interactive
		source "$DOROTHY/sources/interactive.fish"
	end
end
